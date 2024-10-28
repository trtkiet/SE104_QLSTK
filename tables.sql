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
KHACHHANG
======================================================================*/
CREATE TABLE KHACHHANG(
	-- Keys
	MaKH INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	-- Non-keys
	TenKH VARCHAR(40) NOT NULL,
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
	MaKH INT NOT NULL FOREIGN KEY REFERENCES KHACHHANG(MaKH),
	-- Non-keys
	LoaiTaiTuc INT NOT NULL, -- (0 = Tai tuc goc, 1 = Tai tuc toan bo, 3 = Khong tai tuc)
	TienGui MONEY NOT NULL,
	NgayGui SMALLDATETIME NOT NULL,
	NgayRut SMALLDATETIME NOT NULL,
	SoTienRut MONEY NOT NULL,
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
	NgayCT SMALLDATETIME NOT NULL
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


	
