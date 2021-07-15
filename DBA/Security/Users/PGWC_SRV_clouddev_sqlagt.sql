IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\SRV_clouddev_sqlagt')
CREATE LOGIN [PGWC\SRV_clouddev_sqlagt] FROM WINDOWS
GO
CREATE USER [PGWC\SRV_clouddev_sqlagt] FOR LOGIN [PGWC\SRV_clouddev_sqlagt]
GO
