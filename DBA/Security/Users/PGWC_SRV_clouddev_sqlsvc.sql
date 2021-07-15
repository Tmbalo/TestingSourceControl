IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\SRV_clouddev_sqlsvc')
CREATE LOGIN [PGWC\SRV_clouddev_sqlsvc] FROM WINDOWS
GO
CREATE USER [PGWC\SRV_clouddev_sqlsvc] FOR LOGIN [PGWC\SRV_clouddev_sqlsvc]
GO
