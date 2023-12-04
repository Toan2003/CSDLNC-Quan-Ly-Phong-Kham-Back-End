﻿--TRUY VẤN LỊCH HẸN THEO ID BỆNH NHÂN, ID NHA SĨ VÀ NGÀY HẸN, SẮP XẾP THEO THỨ TỰ NGÀY HẸN MỚI NHẤT TRƯỚC
--Truy vấn theo ID Bệnh nhân
SELECT *
FROM LICHHEN
WHERE BENHNHAN = 'Điền IDBENHNHAN ở đây'
ORDER BY NGAYHEN DESC;
--Truy vấn theo ID Nha sĩ
SELECT *
FROM LICHHEN
WHERE BACSI = 'Điền IDNHANVIEN ở đây'
ORDER BY NGAYHEN DESC;
-- Truy vấn theo ngày hẹn
SELECT *
FROM LICHHEN
WHERE NGAYHEN = 'Điền NGAYHEN ở đây'
ORDER BY NGAYHEN DESC;

--TRUY VẤN LỊCH HẸN THEO ID NHA SĨ VÀ NGÀY LÀM VIỆC, SẮP XẾP THEO THỨ TỰ NGÀY HẸN MỚI NHẤT TRƯỚC
--Truy vấn theo ID Nha sĩ
SELECT *
FROM LICHLAMVIEC
WHERE IDNHANVIEN = 'Điền IDNHANVIEN ở đây'
ORDER BY NAM DESC, THANG DESC, NGAY DESC;

-- Truy vấn theo ngày làm việc
SELECT *
FROM LICHLAMVIEC
WHERE CONVERT(DATE, CONVERT(VARCHAR, NAM) + '-' + CONVERT(VARCHAR, THANG) + '-' + CONVERT(VARCHAR, NGAY), 23) = 'Điền ngày làm việc ở đây theo kiểu DATE'
ORDER BY NAM DESC, THANG DESC, NGAY DESC;
