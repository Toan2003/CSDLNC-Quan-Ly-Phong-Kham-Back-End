﻿---------------------------------------------------TOOLS
--XEM CLUSTERED INDEX CỦA TỪNG BẢNG
EXEC sp_helpindex 'LICHLAMVIEC'

--XEM ĐỀ XUẤT INDEX CỦA DBMS
SELECT * FROM sys.dm_db_missing_index_details

--XÓA PLANCACHE PROCEDURE
EXEC sp_recompile 'timhosobenhnhanquaten'

--XÓA INDEX
DROP INDEX LICHHEN_NGAYHEN
ON LICHHEN;

DROP INDEX HS_TEN
ON HOSOBENHNHAN;

---------------------------------------------------TẠO INDEX
--LỊCH HẸN
CREATE NONCLUSTERED INDEX LICHHEN_NGAYHEN
ON LICHHEN (NGAYHEN DESC)

--ĐIỀU TRỊ
CREATE NONCLUSTERED INDEX BDT_BN
ON BUOIDIEUTRI (BNKHAMLE DESC)

CREATE NONCLUSTERED INDEX BDT_KH
ON BUOIDIEUTRI ( KEHOACHDT DESC)

CREATE NONCLUSTERED INDEX KH_BENHNHAN
ON KEHOACHDIEUTRI (BENHNHAN DESC)

--ĐƠN THUỐC
CREATE NONCLUSTERED INDEX DT_BDT
ON DONTHUOC (IDBUOIDIEUTRI DESC)

--HÓA ĐƠN
CREATE NONCLUSTERED INDEX HD_BDT
ON HOADON (IDBUOIDIEUTRI DESC)

CREATE NONCLUSTERED INDEX HD_BN
ON HOADON (IDBENHNHAN DESC)

--HỒ SƠ BỆNH NHÂN
CREATE NONCLUSTERED INDEX HS_TEN
ON HOSOBENHNHAN (TENBN DESC)

--KHÔNG TẠO
--CREATE NONCLUSTERED INDEX BDT_NGAY
--ON BUOIDIEUTRI (NGAYDT DESC)