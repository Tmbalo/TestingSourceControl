IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\19800701')
CREATE LOGIN [PGWC\19800701] FROM WINDOWS
GO
CREATE USER [PGWC\19800701] FOR LOGIN [PGWC\19800701]
GO
