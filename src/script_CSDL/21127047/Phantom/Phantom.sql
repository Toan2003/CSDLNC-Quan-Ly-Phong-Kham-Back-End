﻿CREATE OR ALTER PROC SP_XEMCHITIETDONTHUOC
	@IDDONTHUOC CHAR(12)
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN

	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)
		BEGIN
			PRINT @IDDONTHUOC + 'KHONG TON TAI'
			ROLLBACK TRAN
			RETURN
		END

		DECLARE @SOLUONGTHUOC INT
		SET @SOLUONGTHUOC = (SELECT COUNT(*) FROM CHITIETDONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)

		SELECT @SOLUONGTHUOC SOLUONGTHUOC
		DECLARE @TONGGIA FLOAT
		SET @TONGGIA = (SELECT SUM(T.GIATHUOC * CT.SOLUONG) FROM CHITIETDONTHUOC CT JOIN THUOC T ON CT.IDTHUOC = T.IDTHUOC WHERE CT.IDDONTHUOC = @IDDONTHUOC GROUP BY CT.IDDONTHUOC)
	
		-----DE TEST
		WAITFOR DELAY '0:0:5'
		-----
		--SELECT * FROM CHITIETDONTHUOC CT JOIN THUOC T ON CT.IDTHUOC = T.IDTHUOC WHERE CT.IDDONTHUOC = @IDDONTHUOC
		SELECT CT.IDTHUOC , T.TENTHUOC, CT.SOLUONG, T.GIATHUOC * CT.SOLUONG as 'GIA', @TONGGIA 'TONGGIA'
		FROM CHITIETDONTHUOC CT, THUOC T, DONTHUOC D
		WHERE D.IDDONTHUOC = @IDDONTHUOC AND CT.IDDONTHUOC = D.IDDONTHUOC AND T.IDTHUOC = CT.IDTHUOC

	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN
	END CATCH
COMMIT TRAN
RETURN
GO
		
----CREATE OR ALTER PROC SP_THEM1CHITIETDONTHUOC
--	@IDDONTHUOC CHAR(12),
--	@IDTHUOC CHAR(8),
--	@SOLUONG INT
	
--AS
--BEGIN TRAN
--	BEGIN TRY
--		IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)
--		BEGIN
--			PRINT @IDDONTHUOC + 'KHONG TON TAI'
--			ROLLBACK TRAN
--			RETURN 1
--		END
--		IF NOT EXISTS (SELECT * FROM THUOC WHERE IDTHUOC = @IDTHUOC)
--		BEGIN
--			PRINT @IDTHUOC + 'KHONG TON TAI'
--			ROLLBACK TRAN
--			RETURN 1
--		END

--		DECLARE @IDBUOIDIEUTRI CHAR(10)
--		SET @IDBUOIDIEUTRI = (SELECT IDBUOIDIEUTRI FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)

--		IF EXISTS (SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI AND NGAYGIAODICH !=NULL)
--		BEGIN
--			PRINT 'DON THUOC DA THANH TOAN KHONG THE THEM'
--			ROLLBACK TRAN
--			RETURN 1
--		END

--		DECLARE @TIEN FLOAT
--		SET @TIEN = (SELECT GIATHUOC * @SOLUONG FROM THUOC WHERE IDTHUOC = @IDTHUOC)
--		UPDATE BUOIDIEUTRI
--		SET TONGTIEN = TONGTIEN + @TIEN
--		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
--		UPDATE HOADON
--		SET TONGTIEN = TONGTIEN + @TIEN
--		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

--	---ĐỂ TEST
--		WAITFOR DELAY '0:0:20'
		
--		INSERT CHITIETDONTHUOC(IDDONTHUOC, IDTHUOC, SOLUONG)
--		VALUES (@IDDONTHUOC, @IDTHUOC, @SOLUONG)
--	-----

--	END TRY
--	BEGIN CATCH
--		PRINT N'LỖI HỆ THỐNG'
--		ROLLBACK TRAN
--		RETURN 1
--	END CATCH
--COMMIT TRAN
--RETURN 0
CREATE OR ALTER PROC SP_THEMCHITIETDONTHUOC
	@IDDONTHUOC CHAR(12),
	@IDTHUOC CHAR(8),
	@SOLUONG INT
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)
		BEGIN
			PRINT @IDDONTHUOC + 'KHONG TON TAI'
			ROLLBACK TRAN
			RETURN 1
		END
		IF NOT EXISTS (SELECT * FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		BEGIN
			PRINT @IDTHUOC + 'KHONG TON TAI'
			ROLLBACK TRAN
			RETURN 1
		END

		DECLARE @IDBUOIDIEUTRI CHAR(10)
		SET @IDBUOIDIEUTRI = (SELECT IDBUOIDIEUTRI FROM DONTHUOC WHERE IDDONTHUOC = @IDDONTHUOC)

		IF NOT EXISTS (SELECT * FROM HOADON WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI AND NGAYGIAODICH IS NULL)
		BEGIN
			PRINT 'DON THUOC DA THANH TOAN KHONG THE THEM'
			ROLLBACK TRAN
			RETURN 1
		END

		DECLARE @TIEN FLOAT
		SET @TIEN = (SELECT GIATHUOC * @SOLUONG FROM THUOC WHERE IDTHUOC = @IDTHUOC)
		UPDATE BUOIDIEUTRI
		SET TONGTIEN = TONGTIEN + @TIEN
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI
		UPDATE HOADON
		SET TONGTIEN = TONGTIEN + @TIEN
		WHERE IDBUOIDIEUTRI = @IDBUOIDIEUTRI

	-----ĐỂ TEST
		--WAITFOR DELAY '0:0:10'
		
		INSERT CHITIETDONTHUOC(IDDONTHUOC, IDTHUOC, SOLUONG)
		VALUES (@IDDONTHUOC, @IDTHUOC, @SOLUONG)
	-------
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO