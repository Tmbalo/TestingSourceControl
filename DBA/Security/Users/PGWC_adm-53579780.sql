IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\adm-53579780')
CREATE LOGIN [PGWC\adm-53579780] FROM WINDOWS
GO
CREATE USER [PGWC\adm-53579780] FOR LOGIN [PGWC\adm-53579780]
GO
