IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\adm-C0920827')
CREATE LOGIN [PGWC\adm-C0920827] FROM WINDOWS
GO
CREATE USER [PGWC\adm-C0920827] FOR LOGIN [PGWC\adm-C0920827]
GO
