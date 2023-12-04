﻿USE master
GO
IF DB_ID('QLPK_CSDL') IS NOT NULL
	DROP DATABASE QLPK_CSDL
GO
CREATE DATABASE QLPK_CSDL
GO

USE QLPK_CSDL
GO

CREATE TABLE HOSOBENHNHAN
(
	IDBENHNHAN CHAR(8),
	TENBN NVARCHAR(50) NOT NULL,
	IDPHONGKHAM CHAR(3) NOT NULL,                    
	NAMSINHBN DATE NOT NULL,
	GIOITINHBN NVARCHAR(3) NOT NULL,
	TUOI INT NOT NULL,
	SODIENTHOAIBN CHAR(10) NOT NULL CHECK (LEN(SODIENTHOAIBN) = 10 AND SODIENTHOAIBN      NOT LIKE '%[^0-9]%'),
	EMAIL VARCHAR(50),
	DIACHI NVARCHAR(200) NOT NULL,
	MATKHAU VARCHAR(10),

	BACSIMD CHAR(8),

	TTTONGQUAN NVARCHAR(100),
	TINHTRANGDIUNG NVARCHAR(100),
	THUOCCHONGCHIDINH NVARCHAR(30),
	TONGTIEN FLOAT, 
	DATHANHTOAN FLOAT,


	CONSTRAINT PK_BN
	PRIMARY KEY(IDBENHNHAN),
	CONSTRAINT CK_BENHNHAN_PHAI
	CHECK (GIOITINHBN = N'NAM' OR GIOITINHBN = N'NỮ'),
	CONSTRAINT UC_BENHNHAN_SDT UNIQUE (SODIENTHOAIBN),
	CONSTRAINT CK_THANHTOAN_HSBN
	CHECK (DATHANHTOAN <= TONGTIEN)
)

ALTER TABLE HOSOBENHNHAN 
ADD CONSTRAINT CK_NAMSINH
	CHECK (NAMSINHBN < GETDATE())

CREATE TABLE NHANVIEN
(
	IDNHANVIEN CHAR(8),
	TENNV NVARCHAR(50) NOT NULL,
	NAMSINHNV DATE NOT NULL,
	GIOITINHNV NVARCHAR(3) NOT NULL,
	SODIENTHOAINV CHAR(10) NOT NULL CHECK (LEN(SODIENTHOAINV) = 10 AND SODIENTHOAINV NOT LIKE '%[^0-9]%'),
	MATKHAU VARCHAR(10),
	LOAINV CHAR(2) NOT NULL,

	IDPHONGKHAM CHAR(3) NOT NULL,

	CONSTRAINT PK_NV
	PRIMARY KEY(IDNHANVIEN),
	CONSTRAINT CK_PHAI_NV
	CHECK (GIOITINHNV = N'NAM' OR GIOITINHNV = 'NỮ'),
	CONSTRAINT UC_SDT_NV UNIQUE (SODIENTHOAINV)
)

CREATE TABLE KEHOACHDIEUTRI 
(
	IDDIEUTRI CHAR(10),
	MOTAKHDT NVARCHAR(100) NOT NULL,
	TRANGTHAI NCHAR(15) NOT NULL,
	GHICHUKHDT NVARCHAR(100) NOT NULL, 
	TONGGIA FLOAT NOT NULL,

	BENHNHAN CHAR(8) NOT NULL,
	BSPHUTRACH CHAR(8) NOT NULL,
	
	CONSTRAINT PK_KHDIEUTRI
	PRIMARY KEY(IDDIEUTRI),
	CONSTRAINT CK_KHDT
	CHECK (TRANGTHAI = N'KẾ HOẠCH' OR TRANGTHAI = N'ĐÃ HOÀN THÀNH' OR TRANGTHAI = N'ĐÃ HỦY')
)

CREATE TABLE BUOIDIEUTRI
(
	IDBUOIDIEUTRI CHAR(10),
	MOTABDT NVARCHAR(100) NOT NULL,
	GHICHUBDT NVARCHAR(100) NOT NULL,
	NGAYDT DATE NOT NULL,

	TROKHAM CHAR(8),
	KHAMCHINH CHAR(8) NOT NULL,
	BNKHAMLE CHAR(8) NOT NULL,
	KEHOACHDT CHAR(10) NOT NULL,

	CONSTRAINT PK_BUOIDT
	PRIMARY KEY(IDBUOIDIEUTRI)
)

ALTER TABLE BUOIDIEUTRI
ADD CONSTRAINT CK_NGAYDT
	CHECK (NGAYDT >= GETDATE())

CREATE TABLE HOADON
(
	IDHOADON CHAR(15),
	TONGTIEN FLOAT NOT NULL,
	TIENDATRA FLOAT NOT NULL,
	LOAITHANHTOAN NVARCHAR(12) NOT NULL,
	GHICHUHOADON NVARCHAR(100),
	NGAYGIAODICH DATE NOT NULL,
	
	IDBENHNHAN CHAR(8) NOT NULL,
	IDBUOIDIEUTRI CHAR(10) NOT NULL
	
	CONSTRAINT PK_HOADON
	PRIMARY KEY(IDHOADON),
	CONSTRAINT CK_THANHTOAN_HOADON
	CHECK (LOAITHANHTOAN = N'TIỀN MẶT' OR LOAITHANHTOAN = N'ONLINE'),
)

ALTER TABLE HOADON
ADD CONSTRAINT CK_NGAYGD_HOADON
	CHECK (NGAYGIAODICH = GETDATE())

CREATE TABLE DONTHUOC
(
	IDDONTHUOC CHAR(12),
	NGAYCAP DATE NOT NULL,

	IDBUOIDIEUTRI CHAR(10)

	CONSTRAINT PK_DONTHUOC
	PRIMARY KEY(IDDONTHUOC)
)

ALTER TABLE DONTHUOC
ADD CONSTRAINT CK_NGAYCAP
	CHECK(NGAYCAP = GETDATE())

CREATE TABLE CHITIETDONTHUOC
(
	IDTHUOC CHAR(8),
	IDDONTHUOC CHAR(12),
	SOLUONG INT NOT NULL

	CONSTRAINT PK_CTDONTHUOC
	PRIMARY KEY(IDTHUOC, IDDONTHUOC)
)

CREATE TABLE THUOC
(
	IDTHUOC CHAR(8),
	TENTHUOC NCHAR(30) NOT NULL,
	THANHPHAN NCHAR(30) NOT NULL,
	DONVITINH NCHAR(10) NOT NULL,
	GIATHUOC FLOAT NOT NULL,

	CONSTRAINT PK_THUOC
	PRIMARY KEY(IDTHUOC),
	CONSTRAINT CK_DONVI_THUOC
	CHECK (DONVITINH = N'mg' OR DONVITINH = N'viên' OR DONVITINH = N'g' OR DONVITINH = N'liều' OR DONVITINH = N'ống')
)

CREATE TABLE CHITIETDIEUTRI
(
	IDBUOIDIEUTRI CHAR(10) NOT NULL,
	MADIEUTRI CHAR(5) NOT NULL,

	CONSTRAINT PK_CTDIEUTRI
	PRIMARY KEY(IDBUOIDIEUTRI, MADIEUTRI)
)

CREATE TABLE CHITIETRANGDIEUTRI
(
	IDBUOIDIEUTRI CHAR(10) NOT NULL,
	MADIEUTRI CHAR(5) NOT NULL,
	TENRANG NCHAR(20) NOT NULL,
	MATDIEUTRI CHAR(1) NOT NULL

	CONSTRAINT PK_CTRANGDT
	PRIMARY KEY (IDBUOIDIEUTRI, MADIEUTRI, TENRANG, MATDIEUTRI)
)

CREATE TABLE LOAIDIEUTRI
(
	MADIEUTRI CHAR(5),
	TENDIEUTRI NVARCHAR(50),
	GIA FLOAT,

	MADANHMUC CHAR(2)

	CONSTRAINT PK_LOAIDT
	PRIMARY KEY (MADIEUTRI)
)

CREATE TABLE DANHMUCDIEUTRI
(
	MADANHMUC CHAR(2),
	TENDM NVARCHAR(15),

	CONSTRAINT PK_DMDIEUTRI
	PRIMARY KEY (MADANHMUC)
)

CREATE TABLE CALAM 
(
	IDCALAM CHAR(2),
	KHUNGGIO CHAR(20),

	CONSTRAINT PK_CALAM
	PRIMARY KEY (IDCALAM)
)

CREATE TABLE LICHLAMVIEC
(
	IDNHANVIEN CHAR(8),
	NGAY INT,
	THANG INT,
	NAM INT,

	IDCALAM CHAR(2)

	CONSTRAINT PK_LICHLAMVIEC
	PRIMARY KEY (IDNHANVIEN, NGAY, THANG, NAM, IDCALAM)
)

CREATE TABLE LICHHEN
(
	NGAYHEN DATE,
	THOIGIANHEN TIME,
	TINHTRANG NVARCHAR(10),
	PHONG CHAR(3),
	VAITRO CHAR(2),
	GHICHULICHHEN NVARCHAR(100),

	BACSI CHAR(8),
	BENHNHAN CHAR(8)

	CONSTRAINT PK_LICHHEN
	PRIMARY KEY (BACSI, BENHNHAN, NGAYHEN, THOIGIANHEN),
	CONSTRAINT CK_VAITRO_LICHHEN
	CHECK (VAITRO = 'BS' OR VAITRO = 'TK'),
	CONSTRAINT CK_TINHTRANG_LICHHEN
	CHECK (TINHTRANG = N'CUỘC HẸN MỚI' OR TINHTRANG = N'TÁI KHÁM')
)

CREATE TABLE PHONGKHAM
(
	IDPHONGKHAM CHAR(3),
	TENPK NVARCHAR(50),
	DIACHIPK NVARCHAR(200),
	LIENHE CHAR(10),

	CONSTRAINT PK_PHONGKHAM
	PRIMARY KEY (IDPHONGKHAM)
)



--ADD KHOA NGOAI
ALTER TABLE HOSOBENHNHAN 
ADD CONSTRAINT FK_BS_BN
	FOREIGN KEY (BACSIMD)
	REFERENCES NHANVIEN(IDNHANVIEN)
ALTER TABLE HOSOBENHNHAN 
ADD CONSTRAINT FK_PK_BN
	FOREIGN KEY (IDPHONGKHAM)
	REFERENCES PHONGKHAM(IDPHONGKHAM)

ALTER TABLE NHANVIEN
ADD CONSTRAINT FK_NV_PK
	FOREIGN KEY (IDPHONGKHAM)
	REFERENCES PHONGKHAM(IDPHONGKHAM)

ALTER TABLE KEHOACHDIEUTRI
ADD CONSTRAINT FK_KHDT_BN
	FOREIGN KEY (BENHNHAN)
	REFERENCES HOSOBENHNHAN(IDBENHNHAN)

ALTER TABLE KEHOACHDIEUTRI
ADD CONSTRAINT FK_KHDT_BS
	FOREIGN KEY (BSPHUTRACH)
	REFERENCES NHANVIEN(IDNHANVIEN)

ALTER TABLE BUOIDIEUTRI
ADD CONSTRAINT FK_BDT_TROKHAM
	FOREIGN KEY (TROKHAM)
	REFERENCES NHANVIEN(IDNHANVIEN)

ALTER TABLE BUOIDIEUTRI
ADD CONSTRAINT FK_BDT_KHAMCHINH
	FOREIGN KEY (KHAMCHINH)
	REFERENCES NHANVIEN(IDNHANVIEN)

ALTER TABLE BUOIDIEUTRI
ADD CONSTRAINT FK_BDT_BNKL
	FOREIGN KEY (BNKHAMLE)
	REFERENCES HOSOBENHNHAN(IDBENHNHAN)

ALTER TABLE BUOIDIEUTRI
ADD CONSTRAINT FK_BDT_KHDT
	FOREIGN KEY (KEHOACHDT)
	REFERENCES KEHOACHDIEUTRI(IDDIEUTRI)

ALTER TABLE HOADON
ADD CONSTRAINT FK_HD_BN
	FOREIGN KEY (IDBENHNHAN)
	REFERENCES HOSOBENHNHAN(IDBENHNHAN)

ALTER TABLE HOADON
ADD CONSTRAINT FK_HD_BDT
	FOREIGN KEY (IDBUOIDIEUTRI)
	REFERENCES BUOIDIEUTRI(IDBUOIDIEUTRI)

ALTER TABLE DONTHUOC
ADD CONSTRAINT FK_DT_BDT
	FOREIGN KEY (IDBUOIDIEUTRI)
	REFERENCES BUOIDIEUTRI(IDBUOIDIEUTRI)

ALTER TABLE CHITIETDONTHUOC 
ADD CONSTRAINT FK_CTDT_THUOC
	FOREIGN KEY (IDTHUOC)
	REFERENCES THUOC(IDTHUOC)

ALTER TABLE CHITIETDONTHUOC
ADD CONSTRAINT FK_CTDT_DT
	FOREIGN KEY (IDDONTHUOC)
	REFERENCES DONTHUOC(IDDONTHUOC)

ALTER TABLE CHITIETDIEUTRI
ADD CONSTRAINT FK_CTDIEUTRI_BDT
	FOREIGN KEY (IDBUOIDIEUTRI)
	REFERENCES BUOIDIEUTRI(IDBUOIDIEUTRI)

ALTER TABLE CHITIETDIEUTRI
ADD CONSTRAINT FK_CTDIEUTRI_LDT
	FOREIGN KEY (MADIEUTRI)
	REFERENCES LOAIDIEUTRI(MADIEUTRI)

ALTER TABLE CHITIETRANGDIEUTRI
ADD CONSTRAINT FK_CTRDT_BDT
	FOREIGN KEY (IDBUOIDIEUTRI)
	REFERENCES BUOIDIEUTRI(IDBUOIDIEUTRI)

ALTER TABLE CHITIETRANGDIEUTRI
ADD CONSTRAINT FK_CTRDT_LDT
	FOREIGN KEY (MADIEUTRI)
	REFERENCES LOAIDIEUTRI(MADIEUTRI)

ALTER TABLE LICHHEN
ADD CONSTRAINT FK_LH_BS
	FOREIGN KEY (BACSI)
	REFERENCES NHANVIEN(IDNHANVIEN)

ALTER TABLE LICHHEN
ADD CONSTRAINT FK_LH_BN
	FOREIGN KEY (BENHNHAN)
	REFERENCES HOSOBENHNHAN(IDBENHNHAN)

ALTER TABLE LICHLAMVIEC
ADD CONSTRAINT FK_LLV_NV
	FOREIGN KEY (IDNHANVIEN)
	REFERENCES NHANVIEN(IDNHANVIEN)

ALTER TABLE LICHLAMVIEC
ADD CONSTRAINT FK_LLV_CL
	FOREIGN KEY (IDCALAM)
	REFERENCES CALAM(IDCALAM)

ALTER TABLE LOAIDIEUTRI
ADD CONSTRAINT FK_LDT_DM
	FOREIGN KEY (MADANHMUC)
	REFERENCES DANHMUCDIEUTRI(MADANHMUC)
