IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'pgwc\adm-c0860623')
CREATE LOGIN [pgwc\adm-c0860623] FROM WINDOWS
GO
CREATE USER [pgwc\adm-c0860623] FOR LOGIN [pgwc\adm-c0860623]
GO
