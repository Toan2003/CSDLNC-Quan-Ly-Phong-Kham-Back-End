﻿-- 1. Xem danh sách lịch hẹn của 1 bệnh nhân trong ngày
CREATE OR ALTER PROC XEM_LICH_HEN_BN
	@ID_BENHNHAN CHAR(8),
	@NGAY DATE
AS
BEGIN TRAN
	BEGIN TRY
		SELECT BN.TENBN, BN.IDBENHNHAN, LH.NGAYHEN, LH.THOIGIANHEN, LH.TINHTRANG, LH.PHONG, LH.GHICHULICHHEN, LH.BACSI, LH.TROKHAM
		FROM LICHHEN LH
		JOIN HOSOBENHNHAN BN ON LH.BENHNHAN = BN.IDBENHNHAN
		WHERE BN.IDBENHNHAN = @ID_BENHNHAN
			AND CONVERT(DATE, LH.NGAYHEN) = @NGAY
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

-- 2. Xem danh sách lịch hẹn của phòng khám trong ngày
CREATE OR ALTER PROC XEM_LICH_HEN_PK
	@ID_PHONGKHAM CHAR(3),
	@NGAY DATE
AS
BEGIN TRAN
	BEGIN TRY
		SELECT PK.TENPK, PK.IDPHONGKHAM, LH.*
		FROM LICHHEN LH
		JOIN HOSOBENHNHAN BN ON LH.BENHNHAN = BN.IDBENHNHAN
		JOIN PHONGKHAM PK ON BN.IDPHONGKHAM = PK.IDPHONGKHAM
		WHERE PK.IDPHONGKHAM = @ID_PHONGKHAM
			AND CONVERT(DATE, LH.NGAYHEN) = @NGAY
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
-- 3. Xem danh sách lịch hẹn của 1 nha sĩ trong ngày
CREATE OR ALTER PROC XEM_LICH_HEN_NS
	@ID_NHASI CHAR(8),
	@NGAY DATE
AS
BEGIN
	SELECT NS.TENNV, NS.IDNHANVIEN, LH.*
	FROM LICHHEN LH
	JOIN NHANVIEN NS ON LH.BACSI = NS.IDNHANVIEN
	WHERE NS.IDNHANVIEN = @ID_NHASI
		AND CONVERT(DATE, LH.NGAYHEN) = @NGAY
END
GO
-- 4. Thêm lịch hẹn
CREATE OR ALTER PROC THEM_LICH_HEN
	@NGAY DATE,
	@THOIGIAN TIME,
	@TINHTRANG NVARCHAR(10),
	@PHONG CHAR(3),
	@VAITRO CHAR(2),
	@GHICHU NVARCHAR(100),
	@BACSI CHAR(8),
	@BENHNHAN CHAR(8)
AS
BEGIN
	DECLARE @ID_LICHHEN NVARCHAR(100)
	SET @ID_LICHHEN = NEWID()

	-- Kiểm tra tình trạng
	IF @TINHTRANG NOT IN (N'CUỘC HẸN MỚI', N'TÁI KHÁM')
	BEGIN
		PRINT N'TÌNH TRẠNG KHÔNG HỢP LỆ'
		RETURN 1
	END

	-- Thêm lịch hẹn
	INSERT INTO LICHHEN (ID_LICHHEN, NGAYHEN, THOIGIANHEN, TINHTRANG, PHONG, VAITRO, GHICHU, BACSI, BENHNHAN)
	VALUES (@ID_LICHHEN, @NGAY, @THOIGIAN, @TINHTRANG, @PHONG, @VAITRO, @GHICHU, @BACSI, @BENHNHAN)

	RETURN 0
END
GO
-- 5. Xóa 1 lịch hẹn (chú ý cập nhật các bảng có liên quan như BENHNHAN, NHASI, LICHLAMVIEC)
CREATE OR ALTER PROC XOA_LICH_HEN
	@ID_LICH_HEN CHAR(10)
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		-- Kiểm tra sự tồn tại của lịch hẹn
		IF NOT EXISTS (SELECT IDLICHHEN FROM LICHHEN WHERE IDLICHHEN = @ID_LICH_HEN)
		BEGIN
			PRINT N'Không tìm thấy lịch hẹn.'
			ROLLBACK TRAN
			RETURN 1
		END

		-- Lấy thông tin lịch hẹn để cập nhật các bảng liên quan
		DECLARE @BENHNHAN_ID CHAR(8), @BACSI_ID CHAR(8)
		SELECT @BENHNHAN_ID = BENHNHAN, @BACSI_ID = BACSI FROM LICHHEN WHERE IDLICHHEN = @ID_LICH_HEN

		-- Xóa lịch hẹn
		DELETE FROM LICHHEN WHERE IDLICHHEN = @ID_LICH_HEN

		-- Cập nhật trạng thái lịch làm việc
		UPDATE LICHLAMVIEC
		SET TRANGTHAI = 'CHƯA ĐẾN'
		WHERE IDLICHHEN = @ID_LICH_HEN

		-- Cập nhật trạng thái bệnh nhân
		UPDATE BENHNHAN
		SET TINHTRANG = N'KHÔNG HẸN'
		WHERE IDBENHNHAN = @BENHNHAN_ID

		-- Cập nhật trạng thái nhân viên
		UPDATE NHANVIEN
		SET TRANGTHAI = 'CHƯA LÀM VIEC'
		WHERE IDNHANVIEN = @BACSI_ID
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống.'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT TRAN
	RETURN 0
END
GO
-- 6. Chỉnh sửa 1 lịch hẹn (chú ý cập nhật các bảng có liên quan như BENHNHAN, NHASI, LICHLAMVIEC)
CREATE OR ALTER PROC CHINH_SUA_LICH_HEN
	@ID_LICH_HEN CHAR(10),
	@NGAY_HEN DATE,
	@THOI_GIAN_HEN TIME,
	@TINH_TRANG NVARCHAR(10),
	@PHONG CHAR(3),
	@VAI_TRO CHAR(2),
	@GHICHU NVARCHAR(100)
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		-- Kiểm tra sự tồn tại của lịch hẹn
		IF NOT EXISTS (SELECT IDLICHHEN FROM LICHHEN WHERE IDLICHHEN = @ID_LICH_HEN)
		BEGIN
			PRINT N'Không tìm thấy lịch hẹn.'
			ROLLBACK TRAN
			RETURN 1
		END

		-- Cập nhật thông tin lịch hẹn
		UPDATE LICHHEN
		SET NGAYHEN = @NGAY_HEN,
			THOIGIANHEN = @THOI_GIAN_HEN,
			TINHTRANG = @TINH_TRANG,
			PHONG = @PHONG,
			VAITRO = @VAI_TRO,
			GHICHULICHHEN = @GHICHU
		WHERE IDLICHHEN = @ID_LICH_HEN
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống.'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT TRAN
	RETURN 0
END
GO
-- 7. Xem danh sách lịch hẹn từ ngày A -> ngày B (trả về tên BN, ID BN, tên NS, ID NS và thông tin lịch hẹn tương ứng)
CREATE OR ALTER PROC XEM_LICH_HEN_THEO_NGAY
	@NGAY_A DATE,
	@NGAY_B DATE
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		-- Xem danh sách lịch hẹn
		SELECT 
			BENHNHAN.IDBENHNHAN,
			BENHNHAN.TENBN,
			LICHHEN.NGAYHEN,
			LICHHEN.THOIGIANHEN,
			LICHHEN.TINHTRANG,
			NHASI.IDNHANVIEN AS IDNHASICHINH,
			NHASI.TENNV AS TENNHASICHINH,
			LICHHEN.PHONG,
			LICHHEN.VAITRO,
			LICHHEN.GHICHULICHHEN
		FROM 
			LICHHEN
		JOIN 
			BENHNHAN ON LICHHEN.BENHNHAN = BENHNHAN.IDBENHNHAN
		JOIN 
			NHANVIEN NHASI ON LICHHEN.BACSI = NHASI.IDNHANVIEN
		WHERE 
			LICHHEN.NGAYHEN BETWEEN @NGAY_A AND @NGAY_B
		ORDER BY 
			LICHHEN.NGAYHEN, LICHHEN.THOIGIANHEN
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống.'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT TRAN
	RETURN 0
END
