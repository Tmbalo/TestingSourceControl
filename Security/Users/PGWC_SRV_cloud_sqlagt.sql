IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\SRV_cloud_sqlagt')
CREATE LOGIN [PGWC\SRV_cloud_sqlagt] FROM WINDOWS
GO
CREATE USER [PGWC\SRV_cloud_sqlagt] FOR LOGIN [PGWC\SRV_cloud_sqlagt]
GO
