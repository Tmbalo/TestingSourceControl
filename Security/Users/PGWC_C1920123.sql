IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\C1920123')
CREATE LOGIN [PGWC\C1920123] FROM WINDOWS
GO
CREATE USER [PGWC\C1920123] FOR LOGIN [PGWC\C1920123]
GO