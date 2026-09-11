USE [AR_IMMS];
GO

USE [AR_IMMS];
GO

---------------------------------------------------------
-- 1. SITE (2 Sites)
---------------------------------------------------------
INSERT INTO [SITE] (site_name, location)
VALUES 
    (N'DC Tân Thuận', N'Quận 7, TP. Hồ Chí Minh'),
    (N'DC Hòa Lạc', N'Thạch Thất, Hà Nội');

---------------------------------------------------------
-- 2. ROOM (Đúng 6 Rooms: 3 Tân Thuận + 3 Hòa Lạc)
---------------------------------------------------------
INSERT INTO [ROOM] (room_name, site_id_fk)
SELECT N'TT-Room-01', site_id FROM [SITE] WHERE site_name = N'DC Tân Thuận' UNION ALL
SELECT N'TT-Room-02', site_id FROM [SITE] WHERE site_name = N'DC Tân Thuận' UNION ALL
SELECT N'TT-Room-03', site_id FROM [SITE] WHERE site_name = N'DC Tân Thuận' UNION ALL
SELECT N'HL-Room-01', site_id FROM [SITE] WHERE site_name = N'DC Hòa Lạc' UNION ALL
SELECT N'HL-Room-02', site_id FROM [SITE] WHERE site_name = N'DC Hòa Lạc' UNION ALL
SELECT N'HL-Room-03', site_id FROM [SITE] WHERE site_name = N'DC Hòa Lạc';

---------------------------------------------------------
-- 3. RACK (Đúng 60 Racks: 6 Rooms x 10 Racks/Room)
---------------------------------------------------------
INSERT INTO [RACK] (rack_name, room_id_fk)
SELECT r.room_name + N'-Rack-01', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-02', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-03', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-04', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-05', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-06', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-07', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-08', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-09', r.room_id FROM [ROOM] r UNION ALL
SELECT r.room_name + N'-Rack-10', r.room_id FROM [ROOM] r;
GO

-- NẠP SERVER: Tự động phân bổ ngẫu nhiên Rack (1-150) và HĐH cho từng Server
INSERT INTO [SERVER] (server_name, ip_address, operating_system, status, rack_id_fk)
SELECT 
    CONCAT(R.rack_name, '-S0', S.slot) AS server_name,
    CONCAT('10.', ((R.room_id_fk - 1) * 2) + S.slot, '.', R.room_id_fk, '.', (R.rack_id % 250) + 1) AS ip_address,
    CASE (R.rack_id + S.slot) % 4
        WHEN 0 THEN N'Red Hat Enterprise Linux 8.8'
        WHEN 1 THEN N'Ubuntu 22.04.3 LTS'
        WHEN 2 THEN N'CentOS Stream 9'
        ELSE N'Windows Server 2022 Datacenter'
    END AS operating_system,
    'ACTIVE' AS status,
    R.rack_id AS rack_id_fk
FROM [RACK] R
CROSS JOIN (VALUES (1), (2)) AS S(slot)
ORDER BY R.rack_id, S.slot;
GO
---------------------------------------------------------
--TELEMETRY
---------------------------------------------------------
INSERT INTO AR_IMMS.dbo.[TELEMETRY] (cpu_usage, ram_usage, disk_usage, network_usage, temperature, recorded_at, server_id_fk)
SELECT 
    T.cpu_usage,
    T.ram_usage,
    T.disk_usage,
    CAST(ABS(CHECKSUM(NEWID())) % 60 + 10 AS FLOAT) AS network_usage,
    T.temperature,
    TRY_CAST(T.recorded_at AS DATETIME2) AS recorded_at,
    S.server_id AS server_id_fk
FROM data_sample.dbo.telemetry_120_servers T
JOIN AR_IMMS.dbo.[SERVER] S ON S.server_name = T.server_name;
