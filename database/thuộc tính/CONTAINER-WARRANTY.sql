USE [AR_IMMS];
GO
-----------------------------------
--CONTAINER
-----------------------------------

-- Nạp Container với tên dịch vụ và loại Container hoàn toàn khác nhau cho từng Server
INSERT INTO [CONTAINER] (container_name, container_type, status, server_id_fk)
-- Workload 1: App Service chính (Mọi Server đều có)
SELECT 
    CASE (S.server_id % 4)
        WHEN 0 THEN CONCAT('nginx-ingress-srv', S.server_id)
        WHEN 1 THEN CONCAT('api-gateway-srv', S.server_id)
        WHEN 2 THEN CONCAT('frontend-web-srv', S.server_id)
        ELSE CONCAT('auth-service-srv', S.server_id)
    END AS container_name,
    CASE (S.server_id % 4)
        WHEN 0 THEN N'Reverse Proxy'
        WHEN 1 THEN N'API Service'
        WHEN 2 THEN N'Web Application'
        ELSE N'Authentication'
    END AS container_type,
    'RUNNING' AS status,
    S.server_id AS server_id_fk
FROM [SERVER] S

UNION ALL

-- Workload 2: Backend/Database Service (Chỉ gán cho Server có ID chia hết cho 2 hoặc 3)
SELECT 
    CASE (S.server_id % 3)
        WHEN 0 THEN CONCAT('redis-cache-srv', S.server_id)
        WHEN 1 THEN CONCAT('postgres-db-srv', S.server_id)
        ELSE CONCAT('rabbitmq-node-srv', S.server_id)
    END AS container_name,
    CASE (S.server_id % 3)
        WHEN 0 THEN N'In-Memory Cache'
        WHEN 1 THEN N'Database Workload'
        ELSE N'Message Queue'
    END AS container_type,
    CASE (S.server_id % 5)
        WHEN 0 THEN 'PAUSED'
        WHEN 1 THEN 'STOPPED'
        ELSE 'RUNNING'
    END AS status,
    S.server_id AS server_id_fk
FROM [SERVER] S
WHERE S.server_id % 2 = 0 OR S.server_id % 3 = 0;
GO

-----------------------------
--WARRANTY
-----------------------------
-- Nạp dữ liệu bảo hành đa dạng cho từng Server
INSERT INTO [WARRANTY] (provider, warranty_start, warranty_end, status, server_id_fk)
SELECT 
    -- Phân bổ nhà cung cấp dựa trên server_id
    CASE (S.server_id % 4)
        WHEN 0 THEN N'Dell Technologies Việt Nam'
        WHEN 1 THEN N'HPE Vietnam (Hewlett Packard Enterprise)'
        WHEN 2 THEN N'Lenovo Enterprise Solutions'
        ELSE N'Cisco Systems Vietnam'
    END AS provider,
    
    -- Ngày bắt đầu bảo hành (từ 2022 đến 2024)
    DATEADD(DAY, -(S.server_id * 5), '2024-01-01') AS warranty_start,
    
    -- Ngày kết thúc bảo hành (1 đến 3 năm sau ngày bắt đầu)
    DATEADD(YEAR, CASE WHEN S.server_id % 3 = 0 THEN 1 WHEN S.server_id % 3 = 1 THEN 2 ELSE 3 END, DATEADD(DAY, -(S.server_id * 5), '2024-01-01')) AS warranty_end,
    
    -- Trạng thái bảo hành
    CASE 
        WHEN DATEADD(YEAR, CASE WHEN S.server_id % 3 = 0 THEN 1 WHEN S.server_id % 3 = 1 THEN 2 ELSE 3 END, DATEADD(DAY, -(S.server_id * 5), '2024-01-01')) < GETDATE() THEN N'Expired'
        WHEN DATEADD(YEAR, CASE WHEN S.server_id % 3 = 0 THEN 1 WHEN S.server_id % 3 = 1 THEN 2 ELSE 3 END, DATEADD(DAY, -(S.server_id * 5), '2024-01-01')) BETWEEN GETDATE() AND DATEADD(MONTH, 3, GETDATE()) THEN N'Pending Renewal'
        ELSE N'Active'
    END AS status,
    
    S.server_id AS server_id_fk
FROM [SERVER] S;
GO

