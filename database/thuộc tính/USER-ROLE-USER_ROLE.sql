USE AR_IMMS;
GO

-- ============================================================
-- 1. BẢNG [ROLE]
-- ============================================================
INSERT INTO [ROLE] (role_name, description)
VALUES
(N'Administrator', N'Quản trị viên toàn quyền hệ thống'),
(N'Operator', N'Nhân viên vận hành và giám sát hạ tầng Data Center'),
(N'Technician', N'Kỹ thuật viên phụ trách xử lý sự cố và bảo trì thiết bị'),
(N'Viewer', N'Tài khoản chỉ có quyền xem báo cáo và trạng thái hệ thống');
GO

-- ============================================================
-- BẢNG [USER]
-- ============================================================
INSERT INTO [USER] (username, password_hash, full_name, email, status)
VALUES
('phuonganh_le', 'PhuongAnh123456', N'Lê Ngọc Phương Anh', 'phuonganh.lengoc@gmail.com', 'ACTIVE'),
('duyan_le', 'DuyAn123456', N'Lê Hoàng Duy Ân', 'duyan.lehoang@gmail.com', 'ACTIVE'),
('tuankhang_nguyen', 'TuanKhang123456', N'Nguyễn Tuấn Khang', 'tuankhang.nguyen@gmail.com', 'ACTIVE'),
('hungvuong_do', 'HungVuong123456', N'Đỗ Quốc Hùng Vương', 'hungvuong.doquoc@gmail.com', 'ACTIVE'),
('thanhthao_tran', 'ThanhThao123456', N'Trần Thị Thanh Thảo', 'thanhthao.tran@gmail.com', 'ACTIVE'),
('minhtri_pham', 'MinhTri123456', N'Phạm Minh Trí', 'minhtri.pham@gmail.com', 'ACTIVE'),
('mylinh_vo', 'MyLinh123456', N'Võ Thị Mỹ Linh', 'mylinh.vo@gmail.com', 'INACTIVE');
GO

-- ============================================================
-- BẢNG [USER_ROLE]
-- ============================================================
INSERT INTO [USER_ROLE] (user_id_fk, role_id_fk)
VALUES
(1, 1), -- Lê Ngọc Phương Anh: Administrator (Role 1)
(2, 2), -- Lê Hoàng Duy Ân: Operator (Role 2)
(3, 1), -- Nguyễn Tuấn Khang: Administrator (Role 1)
(3, 2), -- Nguyễn Tuấn Khang: Operator (Gán 2 vai trò)
(4, 3), -- Đỗ Quốc Hùng Vương: Technician (Role 3)
(5, 2), -- Trần Thị Thanh Thảo: Operator (Role 2)
(6, 3), -- Phạm Minh Trí: Technician (Role 3)
(7, 4); -- Võ Thị Mỹ Linh: Viewer (Role 4)
GO
