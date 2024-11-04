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

/*====================================================================
NGUOIDUNG
======================================================================*/
CREATE TABLE NGUOIDUNG(
	-- Keys
	MaNguoiDung NVARCHAR(20) NOT NULL PRIMARY KEY,
	MaNhom INT NOT NULL FOREIGN KEY REFERENCES NHOMNGUOIDUNG(MaNhom),
	-- Non-keys
	MatKhau NVARCHAR(255) NOT NULL,
	TenNguoiDung VARCHAR(40) NOT NULL,
	DinhDanh VARCHAR(40) NOT NULL,
	DiaChi VARCHAR(40) NOT NULL,
	SoDuKH MONEY NOT NULL
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
	LoaiTaiTuc INT NOT NULL, -- (0 = Tai tuc goc, 1 = Tai tuc toan bo, 3 = Khong tai tuc)
	TienGui MONEY NOT NULL,
	NgayGui SMALLDATETIME NOT NULL,
	NgayRut SMALLDATETIME,
	SoTienRut MONEY
)
GO

/*====================================================================
CTPHIEUGUI
======================================================================*/
CREATE TABLE CTPHIEUGUI (
	-- Keys
	MaCT INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	MaPhieu INT NOT NULL FOREIGN KEY REFERENCES PHIEUGUI(MaPhieu),
	-- Non-keys
	SoDu MONEY NOT NULL,
	SoThayDoi MONEY NOT NULL,
	SoRutVe MONEY NOT NULL,
	NgayThayDoi SMALLDATETIME NOT NULL
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


/*====================================================================
BAOCAOGUIRUT 
======================================================================*/
CREATE TABLE BAOCAOGUIRUT(
	-- Keysd
	MaGR INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	MaLoaiTK INT NOT NULL FOREIGN KEY REFERENCES LOAITK(MaLoaiTK),
	--Non-keys
	NgayBC TINYINT NOT NULL,
	ThangBC TINYINT NOT NULL,
	NamBC SMALLINT NOT NULL,
	SLGui INT NOT NULL,
	SLRut INT NOT NULL,
	ChenhLechGR INT NOT NULL,
)
GO



	
