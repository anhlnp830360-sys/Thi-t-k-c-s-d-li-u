USE [AR_IMMS];
GO

--ALERT_THRESHOLD

-- 2. Nạp dữ liệu ngưỡng cảnh báo cho từng Server
INSERT INTO [ALERT_THRESHOLD] (metric_name, warning_value, critical_value, is_active, server_id_fk)
-- Ngưỡng CPU Usage (%)
SELECT 
    'CPU' AS metric_name,
    70.0 + (S.server_id % 5) AS warning_value,    -- 70% đến 74%
    85.0 + (S.server_id % 5) AS critical_value,   -- 85% đến 89%
    1 AS is_active,
    S.server_id AS server_id_fk
FROM [SERVER] S

UNION ALL

-- Ngưỡng RAM Usage (%)
SELECT 
    'RAM' AS metric_name,
    75.0 + (S.server_id % 4) AS warning_value,    -- 75% đến 78%
    90.0 AS critical_value,
    1 AS is_active,
    S.server_id AS server_id_fk
FROM [SERVER] S

UNION ALL

-- Ngưỡng Temperature (°C)
SELECT 
    'Temperature' AS metric_name,
    65.0 AS warning_value,
    75.0 AS critical_value,
    1 AS is_active,
    S.server_id AS server_id_fk
FROM [SERVER] S;
GO

--ALERT
-- 2. Nạp dữ liệu Alert dựa trên các bản ghi vượt ngưỡng từ TELEMETRY
INSERT INTO [ALERT] (alert_type, severity, description, status, created_at, server_id_fk)
-- Cảnh báo Nhiệt độ (Temperature)
SELECT TOP 25
    'High Temperature' AS alert_type,
    CASE WHEN T.temperature >= 75.0 THEN 'CRITICAL' ELSE 'WARNING' END AS severity,
    CONCAT(N'Nhiệt độ máy chủ vượt ngưỡng: ', ROUND(T.temperature, 1), N'°C (Ngưỡng cảnh báo: 65°C)'),
    CASE (T.telemetry_id % 3)
        WHEN 0 THEN 'OPEN'
        WHEN 1 THEN 'ACKNOWLEDGED'
        ELSE 'RESOLVED'
    END AS status,
    T.recorded_at AS created_at,
    T.server_id_fk
FROM [TELEMETRY] T
WHERE T.temperature >= 65.0

UNION ALL

-- Cảnh báo Quá tải CPU (CPU Usage)
SELECT TOP 25
    'High CPU Usage' AS alert_type,
    CASE WHEN T.cpu_usage >= 85.0 THEN 'CRITICAL' ELSE 'WARNING' END AS severity,
    CONCAT(N'Sử dụng CPU vượt mức an toàn: ', ROUND(T.cpu_usage, 1), N'% (Ngưỡng cảnh báo: 70%)'),
    CASE (T.telemetry_id % 3)
        WHEN 0 THEN 'OPEN'
        WHEN 1 THEN 'ACKNOWLEDGED'
        ELSE 'RESOLVED'
    END AS status,
    T.recorded_at AS created_at,
    T.server_id_fk
FROM [TELEMETRY] T
WHERE T.cpu_usage >= 70.0

UNION ALL

-- Cảnh báo Quá tải RAM (RAM Usage)
SELECT TOP 20
    'High RAM Usage' AS alert_type,
    CASE WHEN T.ram_usage >= 90.0 THEN 'CRITICAL' ELSE 'WARNING' END AS severity,
    CONCAT(N'Dung lượng RAM sắp đầy: ', ROUND(T.ram_usage, 1), N'% (Ngưỡng cảnh báo: 75%)'),
    'OPEN' AS status,
    T.recorded_at AS created_at,
    T.server_id_fk
FROM [TELEMETRY] T
WHERE T.ram_usage >= 75.0;
GO

--INCIDENT

INSERT INTO [INCIDENT] (incident_title, description, priority, status, created_at, alert_id_fk)
SELECT 
    CONCAT(N'Sự cố: ', A.alert_type, N' tại Server #', A.server_id_fk),
    CONCAT(N'Hệ thống ghi nhận sự cố từ Alert #', A.alert_id, N': ', A.description),
    CASE WHEN A.severity = 'CRITICAL' THEN 'HIGH' ELSE 'MEDIUM' END,
    CASE (A.alert_id % 3) WHEN 0 THEN 'OPEN' WHEN 1 THEN 'IN_PROGRESS' ELSE 'RESOLVED' END,
    A.created_at,
    A.alert_id
FROM [ALERT] A
WHERE A.severity IN ('CRITICAL', 'WARNING');
GO
--TICKET

-- 2. Nạp dữ liệu Ticket (Chỉ phân công cho USER có role là 'Technician')
INSERT INTO [TICKET] (
    ticket_title, 
    description, 
    priority, 
    status, 
    created_at, 
    incident_id_fk, 
    assigned_user_id_fk
)
SELECT 
    CONCAT(N'Xử lý ', I.incident_title) AS ticket_title,
    I.description,
    
    -- Mức độ ưu tiên
    I.priority,
    
    -- Trạng thái Ticket
    CASE I.status
        WHEN 'OPEN' THEN 'IN_PROGRESS'
        WHEN 'IN_PROGRESS' THEN 'IN_PROGRESS'
        WHEN 'RESOLVED' THEN 'RESOLVED'
        ELSE 'CLOSED'
    END AS status,
    
    I.created_at AS created_at,
    I.incident_id AS incident_id_fk,
    
    -- Lấy ngẫu nhiên user_id của Nhân viên có Role = 'Technician'
    TechList.user_id_fk AS assigned_user_id_fk
FROM [INCIDENT] I
CROSS APPLY (
    SELECT TOP 1 UR.user_id_fk
    FROM [USER_ROLE] UR
    JOIN [ROLE] R ON UR.role_id_fk = R.role_id
    WHERE R.role_name = 'Technician'
    ORDER BY CHECKSUM(NEWID(), I.incident_id) -- Xoay vòng ngẫu nhiên giữa các Kỹ thuật viên
) TechList;
GO


-- 5. MAINTENANCE (Sửa đúng Tên cột theo Schema)
INSERT INTO [MAINTENANCE] (maintenance_type, description, performed_at, result, ticket_id_fk)
SELECT 
    N'Corrective' AS maintenance_type,
    CONCAT(N'Xử lý bởi kỹ thuật viên cho Ticket #', T.ticket_id, N': ', T.ticket_title) AS description,
    DATEADD(HOUR, 2, T.created_at) AS performed_at,
    N'SUCCESS' AS result,
    T.ticket_id AS ticket_id_fk
FROM [TICKET] T;
GO

-- 6. AUDIT_LOG 
INSERT INTO [AUDIT_LOG] (action, entity_type, entity_id, description, created_at, user_id_fk)

-- Thao tác 1: Nhập log Đăng nhập (Lấy từ bảng USER)
SELECT 
    N'USER_LOGIN' AS action,
    N'USER' AS entity_type,
    U.user_id AS entity_id,
    CONCAT(N'Người dùng ', U.username, N' đăng nhập thành công từ IP 192.168.1.', 10 + U.user_id) AS description,
    DATEADD(MINUTE, -(U.user_id * 15), GETDATE()) AS created_at,
    U.user_id AS user_id_fk
FROM [USER] U

UNION ALL

-- Thao tác 2: Nhập log Cập nhật Ngưỡng (Lấy tối đa 20 bản ghi từ ALERT_THRESHOLD)
SELECT TOP 20
    N'UPDATE_THRESHOLD' AS action,
    N'ALERT_THRESHOLD' AS entity_type,
    AT.threshold_id AS entity_id,
    CONCAT(N'Cập nhật ngưỡng ', AT.metric_name, N' cho Server ID #', AT.server_id_fk) AS description,
    DATEADD(DAY, -1, GETDATE()) AS created_at,
    (SELECT TOP 1 user_id FROM [USER]) AS user_id_fk -- Lấy tự động 1 User ID hợp lệ làm Admin
FROM [ALERT_THRESHOLD] AT

UNION ALL

-- Thao tác 3: Nhập log Cập nhật Ticket (Lấy từ bảng TICKET)
SELECT 
    N'UPDATE_TICKET_STATUS' AS action,
    N'TICKET' AS entity_type,
    T.ticket_id AS entity_id,
    CONCAT(N'Kỹ thuật viên đã chuyển trạng thái Ticket #', T.ticket_id, N' thành: ', T.status) AS description,
    T.created_at AS created_at,
    T.assigned_user_id_fk AS user_id_fk
FROM [TICKET] T;
GO
