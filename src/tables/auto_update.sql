/*
Vao SQL Server Agent -> New Job 
->  Tab general: nhap ten Job, chon owner la account connect voi server
->  Tab steps: Tao 2 steps, cach tao 1 step: New..... -> nhap Name, Type (TSQL), Database (la database chua cai bang nay).
				Command: paste code cho step tuong ung

->  Tab schedules: tao 1 schedule moi, dat ten
				Thong so:
				- Schedule type: recurring
				- Frequency: occurs daily, recurs every 1 day
				- Daily frequence: occurs every 1 minute
				- Start day: ngay hien tai
				- No end date
==> Nhap OK

Luu y: phai chay server vao luc 0h thi moi thay nha, de test thi ong co the doi sang minute :v 
*/


-- step 1: cap nhat tien lai khi den ky




-- step 2:  auto insert phieuGT moi vao transactions vao 0h ngay hom sau ngay gui 


GO
UPDATE NGUOIDUNG 
SET SoDuNguoiDung = SoDuNguoiDung + (
	SELECT COALESCE(SUM(TienGui * LaiSuatApDung / 365 * KyHanApDung), 0)
	FROM PHIEUGUI 
	WHERE MaNguoiDung = MaKH AND LoaiTaiTuc = 0 AND DATEDIFF(day, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(day, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL
)

GO
UPDATE PHIEUGUI 
SET TienLai = TienLai + (TienGui + TienLai) * LaiSuatApDung / 365 * KyHanApDung
WHERE LoaiTaiTuc = 1 AND DATEDIFF(day, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(day, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL

GO
UPDATE NGUOIDUNG 
SET SoDuNguoiDung = SoDuNguoiDung + (
	SELECT COALESCE(SUM(TienGui * LaiSuatApDung / 365 * KyHanApDung) + SUM(TienGui), 0)
	FROM PHIEUGUI 
	WHERE MaNguoiDung = MaKH AND LoaiTaiTuc = 2 AND DATEDIFF(day, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(day, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL
)

GO
UPDATE PHIEUGUI
SET TienLai = 0, NgayDong = (select DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))
WHERE LoaiTaiTuc = 2 AND DATEDIFF(day, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(day, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL




--------------------------------------- DEMO
GO
UPDATE NGUOIDUNG 
SET SoDuNguoiDung = SoDuNguoiDung + (
	SELECT COALESCE(SUM(TienGui * LaiSuatApDung / 365 * KyHanApDung), 0)
	FROM PHIEUGUI 
	WHERE MaNguoiDung = MaKH AND LoaiTaiTuc = 0 AND DATEDIFF(SECOND, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(SECOND, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL
)

GO
UPDATE PHIEUGUI 
SET TienLai = TienLai + (TienGui + TienLai) * LaiSuatApDung / 365 * KyHanApDung
WHERE LoaiTaiTuc = 1 AND DATEDIFF(SECOND, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(SECOND, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL

GO
UPDATE NGUOIDUNG 
SET SoDuNguoiDung = SoDuNguoiDung + (
	SELECT COALESCE(SUM(TienGui * LaiSuatApDung / 365 * KyHanApDung) + SUM(TienGui), 0)
	FROM PHIEUGUI 
	WHERE MaNguoiDung = MaKH AND LoaiTaiTuc = 2 AND DATEDIFF(SECOND, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(SECOND, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL AND KyHanApDung != 0
)

GO
UPDATE PHIEUGUI
SET TienLai = 0, NgayDong = (select DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))
WHERE LoaiTaiTuc = 2 AND DATEDIFF(SECOND, GETDATE(), NgayGui) % KyHanApDung = 0 AND DATEDIFF(SECOND, GETDATE(), NgayGui) != 0 AND NgayDong IS NULL AND KyHanApDung != 0