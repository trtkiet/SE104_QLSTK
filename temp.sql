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
	TenNguoiDung VARCHAR(40) NOT NULL,
	DinhDanh VARCHAR(40) NOT NULL,
	DiaChi VARCHAR(40) NOT NULL,
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
	LoaiTaiTuc INT NOT NULL, -- (0 = Tai tuc goc, 1 = Tai tuc toan bo, 3 = Khong tai tuc)
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




	
USE master
GO
xp_readerrorlog 0, 1, N'Server is listening on' 
GO