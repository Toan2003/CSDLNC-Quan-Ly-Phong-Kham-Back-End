﻿----Cập nhật chi tiết đơn thuốc (THÊM 1 ĐƠN THUỐC)   ---dIRTY READ
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
		WAITFOR DELAY '0:0:5'
		
		INSERT CHITIETDONTHUOC(IDDONTHUOC, IDTHUOC, SOLUONG)
		VALUES (@IDDONTHUOC, @IDTHUOC, @SOLUONG)
	-------
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

CREATE OR ALTER PROC SP_XEMCHITIETHOADON 
	@IDHOADON CHAR(15)
AS
SET TRAN ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM HOADON WHERE IDHOADON = @IDHOADON)
	BEGIN
		PRINT @IDHOADON + ' KHONG TON TAI'
		ROLLBACK TRAN
		RETURN
	END
	DECLARE @IDBUOIDIEUTRI CHAR(10)
	SET @IDBUOIDIEUTRI = (SELECT BDT.IDBUOIDIEUTRI FROM HOADON HD JOIN BUOIDIEUTRI BDT ON HD.IDBUOIDIEUTRI = BDT.IDBUOIDIEUTRI 
							WHERE HD.IDHOADON = @IDHOADON)

	--SET @TONGTIEN = (SELECT SUM(CT.SOLUONG * T.GIATHUOC) FROM CHITIETDONTHUOC CT JOIN THUOC T ON CT.IDTHUOC = T.IDTHUOC
	--				WHERE CT.IDDONTHUOC = @IDDONTHUOC GROUP BY IDDONTHUOC)

	--SELECT HD.* 
	--FROM HOADON HD, CHITIETDONTHUOC CT
	--WHERE HD.IDHOADON = @IDHOADON AND CT.IDDONTHUOC=@IDDONTHUOC
	SELECT HD.IDHOADON, HD.TONGTIEN, HD.LOAITHANHTOAN, HD.GHICHUHOADON, HD.NGAYGIAODICH
	FROM HOADON HD WHERE HD.IDHOADON = @IDHOADON

	SELECT CTDT.IDBUOIDIEUTRI, LDT.MADIEUTRI, LDT.TENDIEUTRI, LDT.GIA
	FROM CHITIETDIEUTRI CTDT JOIN LOAIDIEUTRI LDT ON CTDT.MADIEUTRI = LDT.MADIEUTRI
	WHERE CTDT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI

	SELECT T.IDTHUOC, T.TENTHUOC, CT.SOLUONG, T.GIATHUOC * CT.SOLUONG 'GIATHUOC'
	FROM DONTHUOC DT JOIN CHITIETDONTHUOC CT ON CT.IDDONTHUOC = DT.IDDONTHUOC
	JOIN THUOC T ON T.IDTHUOC=CT.IDTHUOC
	WHERE DT.IDBUOIDIEUTRI = @IDBUOIDIEUTRI
	END TRY
	
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0


----TEST THỬ
----