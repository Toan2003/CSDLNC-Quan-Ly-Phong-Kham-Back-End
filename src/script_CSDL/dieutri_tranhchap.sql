﻿--DIRTY READ: THÊM CHI TIẾT TRƯỚC (THÊM CHI TIẾT SAI - ĐÃ CÓ TRƯỚC ĐÓ), RỒI XEM CHI TIẾT BUỔI ĐIỀU TRỊ
CREATE OR ALTER PROC XEMCHITIETBDT
	@IDBUOIDIEUTRI CHAR(10)
AS
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		--THỰC THI

		SELECT BDT.IDBUOIDIEUTRI, BDT.KEHOACHDT, BDT.NGAYDT, BDT.MOTABDT, BDT.GHICHUBDT, BDT.TONGTIEN,
			BSCHINH.IDNHANVIEN N'KHAMCHINH_ID', BSCHINH.TENNV N'KHAMCHINH_HT',TROKHAM.IDNHANVIEN N'TROKHAM_ID', TROKHAM.TENNV N'TROKHAM_HT',
			DT.IDDONTHUOC, HD.IDHOADON,
			BN.IDBENHNHAN, BN.TENBN
		FROM BUOIDIEUTRI BDT
			left JOIN NHANVIEN BSCHINH ON BDT.KHAMCHINH = BSCHINH.IDNHANVIEN
			left JOIN NHANVIEN TROKHAM ON BDT.TROKHAM = TROKHAM.IDNHANVIEN
			LEFT JOIN DONTHUOC DT ON DT.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI
			left JOIN HOSOBENHNHAN BN ON BDT.BNKHAMLE = BN.IDBENHNHAN
			LEFT JOIN HOADON HD ON HD.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI
		WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI


		--LẤY THÔNG TIN CHI TIẾT
		SELECT CTDT.MADIEUTRI, LDT.TENDIEUTRI, CTRDT.TENRANG, CTRDT.MATDIEUTRI
		FROM  BUOIDIEUTRI BDT
			left JOIN CHITIETDIEUTRI CTDT ON BDT.IDBUOIDIEUTRI = CTDT.IDBUOIDIEUTRI
			left JOIN LOAIDIEUTRI LDT ON CTDT.MADIEUTRI = LDT.MADIEUTRI
			left JOIN CHITIETRANGDIEUTRI CTRDT ON CTDT.MADIEUTRI = CTRDT.MADIEUTRI AND CTDT.IDBUOIDIEUTRI = CTRDT.IDBUOIDIEUTRI
		WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		--WAITFOR DELAY '0:0:03' --UNREPEATABLE READ

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

CREATE OR ALTER PROC THEMCHITIETDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MADIEUTRI IS NULL) OR (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END

		DECLARE @NGAY1 DATE;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		DECLARE @TONGTIEN FLOAT
		SELECT @TONGTIEN = TONGTIEN FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		IF (@NGAY1 IS NULL)
			BEGIN
				PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI'
				ROLLBACK TRAN
				RETURN 1	
			END
		--IF (@NGAY1 < GETDATE()) 
		--	BEGIN 
		--		PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END

		DECLARE @TIEN FLOAT
		SELECT @TIEN = GIA
		FROM LOAIDIEUTRI LDT
		WHERE LDT.MADIEUTRI = @MADIEUTRI

		--THỰC THI
		
		SET @TONGTIEN = @TONGTIEN + @TIEN
		UPDATE BUOIDIEUTRI
		SET TONGTIEN = @TONGTIEN 
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		WAITFOR DELAY '0:0:03' --DIRTY READ

		INSERT CHITIETDIEUTRI(MADIEUTRI,IDBUOIDIEUTRI)
		VALUES
			(@MADIEUTRI, @IDBUOIDIEUTRI)

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO


--PHANTOM: XÓA BUỔI ĐIỀU TRỊ - THÊM HÓA ĐƠN
CREATE OR ALTER PROC XOABUOIDT
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		
		DECLARE @NGAY1 DATE = NULL;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		IF (@NGAY1 IS NULL)
			BEGIN
				PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI';
				ROLLBACK TRAN
				RETURN 1	
			END

		--IF (@NGAY1 < GETDATE()) 
		--	BEGIN 
		--		PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ XÓA';
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END
	
		IF ( EXISTS(SELECT IDHOADON FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI))
			BEGIN
				PRINT N'KIỂM TRA ĐÃ CÓ HÓA ĐƠN KHÔNG THỂ XÓA BUỔI ĐIỀU TRỊ'
				--PRINT @IDBUOIDIEUTRI
				ROLLBACK TRAN
				RETURN 1
			END
		
		DECLARE @IDDONTHUOC NCHAR(12)
		SELECT @IDDONTHUOC = IDDONTHUOC FROM DONTHUOC WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		WAITFOR DELAY '0:0:05'
		--THỰC THI
		DELETE 
			FROM CHITIETRANGDIEUTRI 
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		DELETE
			FROM CHITIETDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		DELETE
			FROM CHITIETDONTHUOC
			WHERE IDDONTHUOC = @IDDONTHUOC
		DELETE
			FROM DONTHUOC
			WHERE IDDONTHUOC = @IDDONTHUOC
		DELETE
			FROM BUOIDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		PRINT N'THÀNH CÔNG'
		--ROLLBACK
		--RETURN 1
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

CREATE OR ALTER PROC SP_THEMHOADON 
	@IDHOADON CHAR(15),
	@LOAITHANHTOAN NVARCHAR(12),
	@GHICHUHOADON NVARCHAR(100),
	@NGAYGIAODICH DATE,
	@IDBENHNHAN CHAR(8),
	@IDBUOIDIEUTRI CHAR(10)
AS
BEGIN TRAN
	BEGIN TRY
		IF EXISTS (SELECT * FROM HOADON WHERE IDHOADON=@IDHOADON)
		BEGIN
			ROLLBACK TRAN
			RETURN 1
		END 
		IF EXISTS (SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI)    --BUODIIEUTRI DA ĐƯỢC THANH TOÁN
		BEGIN
			ROLLBACK TRAN
			RETURN 3
		END
		IF NOT EXISTS (SELECT * FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI AND BNKHAMLE = @IDBENHNHAN )    --BUODIIEUTRI DA ĐƯỢC THANH TOÁN
		BEGIN
			ROLLBACK TRAN
			RETURN 4
		END
		DECLARE @TONGTIEN FLOAT
		SET @TONGTIEN = (SELECT TONGTIEN FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI)

		INSERT HOADON (IDHOADON, TONGTIEN, LOAITHANHTOAN, GHICHUHOADON, NGAYGIAODICH, IDBENHNHAN, IDBUOIDIEUTRI)
		VALUES (@IDHOADON, @TONGTIEN, @LOAITHANHTOAN, @GHICHUHOADON, @NGAYGIAODICH, @IDBENHNHAN, @IDBUOIDIEUTRI)
	END TRY
	 
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage
		ROLLBACK TRAN
		RETURN 2
	END CATCH
COMMIT TRAN
RETURN 0
GO

--CREATE TRIGGER XOABUOIDIEUTRI
--ON BUOIDIEUTRI
--FOR DELETE
--AS
--		IF EXISTS(SELECT * FROM HOADON HD JOIN deleted d ON HD.IDBUOIDIEUTRI = d.IDBUOIDIEUTRI) 
--		BEGIN
--			RAISERROR ('ĐÃ XUẤT HÓA ĐƠN KHÔNG THỂ CHỈNH SỬA',16,1)
--			--;THROW 51000,'LOI R11',1;
--			ROLLBACK --HỦY THAO TÁC UPDATE ĐÃ THỰC HIỆN
--			RETURN
--		END

--		IF EXISTS(SELECT * FROM HOADON HD JOIN deleted d ON HD.IDBUOIDIEUTRI = d.IDBUOIDIEUTRI) 
--		BEGIN
--			RAISERROR ('ĐÃ XUẤT HÓA ĐƠN KHÔNG THỂ CHỈNH SỬA',16,1)
--			--;THROW 51000,'LOI R11',1;
--			ROLLBACK --HỦY THAO TÁC UPDATE ĐÃ THỰC HIỆN
--			RETURN
--		END
--GO

--DROP TRIGGER XOABUOIDIEUTRI
GO

--DEADLOCK: CONVERSION CÙNG THÊM CHI TIẾT ĐIỀU TRỊ CHO MỘT BUỔI ĐIỀU TRỊ
CREATE OR ALTER PROC THEMCHITIETDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10)
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MADIEUTRI IS NULL) OR (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END

		DECLARE @NGAY1 DATE;
		(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		DECLARE @TONGTIEN FLOAT
		SELECT @TONGTIEN = TONGTIEN FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		IF (@NGAY1 IS NULL)
			BEGIN
				PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI';
				ROLLBACK TRAN
				RETURN 1	
			END
		--IF (@NGAY1 < GETDATE()) 
		--	BEGIN 
		--		PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END

		DECLARE @TIEN FLOAT
		SELECT @TIEN = GIA
		FROM LOAIDIEUTRI LDT
		WHERE LDT.MADIEUTRI = @MADIEUTRI

		--THỰC THI
		
		WAITFOR DELAY '0:0:03' -- DEADLOCK

		SET @TONGTIEN = @TONGTIEN + @TIEN
		UPDATE BUOIDIEUTRI
		SET TONGTIEN = @TONGTIEN 
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		--WAITFOR DELAY '0:0:03' --DIRTY READ

		INSERT CHITIETDIEUTRI(MADIEUTRI,IDBUOIDIEUTRI)
		VALUES
			(@MADIEUTRI, @IDBUOIDIEUTRI)

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO


--DEADLOCK: CYCLE XÓA BUỔI ĐIỀU TRỊ - THEM CHI TIET DIEUTRI THEM1CHITIETDONTHUOC

CREATE OR ALTER PROC XOABUOIDT
	@IDBUOIDIEUTRI CHAR(10)
AS
SET TRAN ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END
		
		--DECLARE @NGAY1 DATE = NULL;
		--(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		--IF (@NGAY1 IS NULL)
		--	BEGIN
		--		PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI';
		--		ROLLBACK TRAN
		--		RETURN 1	
		--	END

		--IF (@NGAY1 < GETDATE()) 
		--	BEGIN 
		--		PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ XÓA';
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END
	
		IF ( EXISTS(SELECT IDHOADON FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI))
			BEGIN
				PRINT N'KIỂM TRA ĐÃ CÓ HÓA ĐƠN KHÔNG THỂ XÓA BUỔI ĐIỀU TRỊ'
				--PRINT @IDBUOIDIEUTRI
				ROLLBACK TRAN
				RETURN 1
			END
		
		DECLARE @IDDONTHUOC NCHAR(12)
		SELECT @IDDONTHUOC = IDDONTHUOC FROM DONTHUOC WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		--THỰC THI
		DELETE 
			FROM CHITIETRANGDIEUTRI 
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		DELETE
			FROM CHITIETDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		DELETE
			FROM CHITIETDONTHUOC
			WHERE IDDONTHUOC = @IDDONTHUOC
		
		DELETE
			FROM DONTHUOC
			WHERE IDDONTHUOC = @IDDONTHUOC
		PRINT N'XOABDT HERE'
		WAITFOR DELAY '0:0:02'
		DELETE
			FROM BUOIDIEUTRI
			WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		PRINT N'THÀNH CÔNG'
		ROLLBACK
		RETURN 1
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO


CREATE OR ALTER PROC THEMCHITIETDT
	@MADIEUTRI CHAR(5),
	@IDBUOIDIEUTRI CHAR(10)
AS
SET TRAN ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		--KIỂM TRA ÐIỀU KIỆN
		IF (@MADIEUTRI IS NULL) OR (@IDBUOIDIEUTRI IS NULL)
			BEGIN 
				PRINT N'THIẾU TRƯỜNG CẦN THIẾT'
				ROLLBACK TRAN
				RETURN 1
			END

		--DECLARE @NGAY1 DATE;
		--(SELECT @NGAY1 = NGAYDT FROM BUOIDIEUTRI BDT WHERE BDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI)
		----DECLARE @TONGTIEN FLOAT
		--SELECT @TONGTIEN = TONGTIEN FROM BUOIDIEUTRI WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		--IF (@NGAY1 IS NULL)
		--	BEGIN
		--		PRINT N'BUỔI ĐIỀU TRỊ KHÔNG TỒN TẠI';
		--		ROLLBACK TRAN
		--		RETURN 1	
		--	END
		--IF (@NGAY1 < GETDATE()) 
		--	BEGIN 
		--		PRINT N'BUỔI ĐIỀU TRỊ ĐÃ XẢY RA KHÔNG THỂ CHỈNH SỬA';
		--		ROLLBACK TRAN
		--		RETURN 1
		--	END

		DECLARE @TIEN FLOAT
		SELECT @TIEN = GIA
		FROM LOAIDIEUTRI LDT
		WHERE LDT.MADIEUTRI = @MADIEUTRI

		--THỰC THI
		
		
		--SET @TONGTIEN = @TONGTIEN + @TIEN
		UPDATE BUOIDIEUTRI
		SET TONGTIEN = TONGTIEN + @TIEN
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

		--WAITFOR DELAY '0:0:03' --DIRTY READ
		PRINT N'HEREJDO'
		WAITFOR DELAY '0:0:03' -- DEADLOCK
		INSERT CHITIETDIEUTRI(MADIEUTRI,IDBUOIDIEUTRI)
		VALUES
			(@MADIEUTRI, @IDBUOIDIEUTRI)

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

SELECT resource_type, request_mode, resource_description
FROM sys.dm_tran_locks
WHERE resource_type <> ‘DATABASE’
