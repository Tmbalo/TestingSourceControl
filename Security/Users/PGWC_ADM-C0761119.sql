IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\ADM-C0761119')
CREATE LOGIN [PGWC\ADM-C0761119] FROM WINDOWS
GO
CREATE USER [PGWC\ADM-C0761119] FOR LOGIN [PGWC\ADM-C0761119]
GO
