IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\C1771115')
CREATE LOGIN [PGWC\C1771115] FROM WINDOWS
GO
CREATE USER [PGWC\C1771115] FOR LOGIN [PGWC\C1771115]
GO
