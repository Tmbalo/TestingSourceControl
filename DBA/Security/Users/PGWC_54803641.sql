IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\54803641')
CREATE LOGIN [PGWC\54803641] FROM WINDOWS
GO
CREATE USER [PGWC\54803641] FOR LOGIN [PGWC\54803641]
GO
