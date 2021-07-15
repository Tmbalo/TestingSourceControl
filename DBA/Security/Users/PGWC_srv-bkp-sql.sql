IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\srv-bkp-sql')
CREATE LOGIN [PGWC\srv-bkp-sql] FROM WINDOWS
GO
CREATE USER [PGWC\srv-bkp-sql] FOR LOGIN [PGWC\srv-bkp-sql]
GO
