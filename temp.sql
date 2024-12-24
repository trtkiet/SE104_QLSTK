USE master
GO
DROP DATABASE IF EXISTS QLSTK
CREATE DATABASE QLSTK
GO
USE QLSTK
GO

/*====================================================================
THAMSO
======================================================================*/
CREATE TABLE THAMSO(
	TienGuiToiThieu MONEY NOT NULL,
	NgayRutToiThieu INT NOT NULL
)
GO
INSERT INTO THAMSO VALUES(1000000, 15)
GO

/*====================================================================
LOAITK
======================================================================*/
CREATE TABLE LOAITK(
	-- Keys
	MaLoaiTK INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	-- Non-keys
	KyHan SMALLINT NOT NULL,
	LaiSuat FLOAT NOT NULL
)
GO

INSERT INTO LOAITK VALUES(1, 0.005)
INSERT INTO LOAITK VALUES(90, 0.05)
INSERT INTO LOAITK VALUES(180, 0.055)

/*====================================================================
CHUCNANG
======================================================================*/
CREATE TABLE CHUCNANG(
	-- Keys
	MaCN INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	-- Non-keys
	TenCN NVARCHAR(20) NOT NULL,
	TenManHinhDuocLoad NVARCHAR(20) NOT NULL
)
GO

/*====================================================================
NHOMNGUOIDUNG
======================================================================*/
CREATE TABLE NHOMNGUOIDUNG(
	-- Keys
	MaNhom INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	-- Non-keys
	TenNhom NVARCHAR(20) NOT NULL
)
GO
INSERT INTO NHOMNGUOIDUNG VALUES(N'Khách hàng')
INSERT INTO NHOMNGUOIDUNG VALUES(N'Nhân viên')
INSERT INTO NHOMNGUOIDUNG VALUES(N'Quản trị viên')
GO

/*====================================================================
PHANQUYEN
======================================================================*/
CREATE TABLE PHANQUYEN(
	-- Keys
	MaNhom INT NOT NULL FOREIGN KEY REFERENCES NHOMNGUOIDUNG(MaNhom),
	MaCN INT NOT NULL FOREIGN KEY REFERENCES CHUCNANG(MaCN),
	CONSTRAINT PK_PhanQuyen PRIMARY KEY(MaNhom, MaCN)
	-- Non-keys
)
GO

/*====================================================================
NGUOIDUNG
======================================================================*/
CREATE TABLE NGUOIDUNG(
	-- Keys
	MaNguoiDung NVARCHAR(20) NOT NULL PRIMARY KEY,
	MaNhom INT NOT NULL FOREIGN KEY REFERENCES NHOMNGUOIDUNG(MaNhom),
	-- Non-keys
	MatKhau NVARCHAR(255) NOT NULL,
	TenNguoiDung NVARCHAR(40) NOT NULL,
	DinhDanh VARCHAR(40) NOT NULL,
	DiaChi NVARCHAR(40) NOT NULL,
	SoDuNguoiDung MONEY NOT NULL
)
GO

/*====================================================================
PHIEUGUI
======================================================================*/
CREATE TABLE PHIEUGUI (
	-- Keys
	MaPhieu INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	MaLoaiTK INT NOT NULL FOREIGN KEY REFERENCES LOAITK(MaLoaiTK),
	MaKH NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES NGUOIDUNG(MaNguoiDung),
	-- Non-keys
	KyHanApDung SMALLINT NOT NULL,
	LaiSuatApDung FLOAT NOT NULL,
	NgayDaoHan SMALLDATETIME NOT NULL,
	LoaiTaiTuc INT NOT NULL, -- (0 = Tai tuc goc, 1 = Tai tuc toan bo, 2 = Khong tai tuc)
	NgayGui SMALLDATETIME NOT NULL,
	TienGui MONEY NOT NULL,
	TienLai MONEY NOT NULL,
	NgayDong SMALLDATETIME
)
GO

/*====================================================================
BAOCAODOANHSO
======================================================================*/
CREATE TABLE BAOCAODOANHSO(
	-- Keys
	MaDS INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	MaLoaiTK INT NOT NULL FOREIGN KEY REFERENCES LOAITK(MaLoaiTK),
	-- Non-keys
	NgayDS SMALLDATETIME NOT NULL,
	TongThu MONEY NOT NULL,
	TongChi MONEY NOT NULL,
	ChenhLechDS MONEY NOT NULL,
)
GO

GO
CREATE PROCEDURE dbo.getInterestType
			@KyHan SMALLINT = NULL,
			@LaiSuat FLOAT = NULL,
			@MaLoaiTK INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF (@MaLoaiTK IS NULL AND @KyHan IS NULL AND @LaiSuat IS NULL)
		BEGIN
			SELECT * 
			FROM LOAITK 
		END
	ELSE IF (@MaLoaiTK IS NULL AND @Kyhan IS NOT NULL AND @LaiSuat IS NOT NULL)
		BEGIN
			SELECT * 
			FROM LOAITK
			WHERE KyHan = @KyHan AND LaiSuat = @LaiSuat
		END
END
GO

/*DROP PROCEDURE dbo.addDeposit*/

GO
CREATE PROCEDURE dbo.addDeposit 
					@CustomerID NVARCHAR(20), 
					@InterestTypeID INT, 
					@Fund MONEY,
					@LoaiTT INT
AS
BEGIN
	SET NOCOUNT ON
	-- Check if the customer or the given interest type is in the database 
	IF (NOT EXISTS (SELECT * FROM LoaiTK WHERE @InterestTypeID = MaLoaiTK) -- invalid Type
		OR NOT EXISTS (SELECT * FROM NGUOIDUNG WHERE @CustomerID = MaNguoiDung)) -- invalid customer
		BEGIN
			SELECT 2 AS err -- khong co KhachHang hoac LoaiTK
			RETURN 
		END
	DECLARE @KyHanApDung SMALLINT,
			@LaiSuatApDung FLOAT,
			@NgayDaoHan SMALLDATETIME
	SELECT @KyHanApDung = KyHan, 
			@LaiSuatApDung = LaiSuat
	FROM LOAITK 
	WHERE MaLoaiTK = @InterestTypeID
	SELECT @NgayDaoHan = GETDATE() + @KyHanApDung
	INSERT INTO PHIEUGUI 
	VALUES (@InterestTypeID, @CustomerID, @KyHanApDung, @LaiSuatApDung, @NgayDaoHan, @LoaiTT, GETDATE(), @Fund, 0, NULL);
	SELECT 1 as err
END
GO

DROP PROCEDURE dbo.getAllDeposit

GO
CREATE PROCEDURE dbo.getAllDeposit 
					@CustomerID NVARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	-- Check if the customer or the given interest type is in the database 
	SELECT MaPhieu, DAY(NgayGui) as Ngay, Month(NgayGui) as Thang, Year(NgayGui) as Nam, TienGui, TienLai, KyHanApDung, LaiSuatApDung, LoaiTaiTuc
	FROM PHIEUGUI
	WHERE MaKH = @CustomerID AND NgayDong IS NULL
END
GO
DROP PROCEDURE dbo.getWithdraw
GO
CREATE PROCEDURE dbo.getWithdraw
				@MaPhieu INT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE
			@NgayDaoHan SMALLDATETIME,
			@NgayGui SMALLDATETIME,
			@Tong MONEY,
			@LaiSuatApDung FLOAT
	SET @NgayDaoHan = (
		SELECT NgayDaoHan 
		FROM PHIEUGUI 
		WHERE MaPhieu = @MaPhieu
	)
	SET @NgayGui = (
		SELECT NgayGui 
		FROM PHIEUGUI 
		WHERE MaPhieu = @MaPhieu
	)
	SET @Tong = (
		SELECT TienGui + TienLai 
		FROM PHIEUGUI 
		WHERE MaPhieu = @MaPhieu
	)
	SET @LaiSuatApDung = (
		SELECT LaiSuatApDung 
		FROM PHIEUGUI 
		WHERE MaPhieu = @MaPhieu
	)
	IF (DATEDIFF(day, @NgayDaoHan, @NgayGui) != DATEDIFF(day, GETDATE(), @NgayGui))
	BEGIN
		SELECT @Tong + @Tong * LaiSuat / 365 * DATEDIFF(day, @NgayGui, GETDATE()) as withdraw
		FROM LOAITK
		WHERE KyHan = 1
	END
	ELSE 
	BEGIN
		SELECT @Tong + @Tong * @LaiSuatApDung / 365 * DATEDIFF(day, @NgayGui, GETDATE()) as withdraw
	END
END
GO
DROP PROCEDURE dbo.CreateWithdraw
GO

CREATE PROCEDURE dbo.CreateWithdraw 
				@MaPhieu INT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NgayRutToiThieu INT = (
		SELECT NgayRutToiThieu
		FROM THAMSO
	)
	DECLARE @NgayGui SMALLDATETIME = (
		SELECT NgayGui 
		FROM PHIEUGUI 
		WHERE MaPhieu = @MaPhieu
	)
	DECLARE @MaKH NVARCHAR(20) = (
		SELECT MaKH 
		FROM PHIEUGUI 
		WHERE MaPhieu = @MaPhieu
	)
	IF (DATEDIFF(day, @NgayGui, GETDATE()) < @NgayRutToiThieu)
		BEGIN
			SELECT 1 as err
		END 
	ELSE 
		BEGIN
			UPDATE PHIEUGUI 
			SET NgayDong = GETDATE()
			WHERE MaPhieu = @MaPhieu
			DECLARE @Withdraw Money
			EXEC @Withdraw = dbo.getWithdraw @MaPhieu
			UPDATE NGUOIDUNG 
			SET SoDuNguoiDung = SoDuNguoiDung + @Withdraw
			WHERE MaNguoiDung = @MaKH
			SELECT 0 as err
		END
END