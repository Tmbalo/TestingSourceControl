IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\adm-19800701')
CREATE LOGIN [PGWC\adm-19800701] FROM WINDOWS
GO
CREATE USER [PGWC\adm-19800701] FOR LOGIN [PGWC\adm-19800701]
GO
