IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\53579780')
CREATE LOGIN [PGWC\53579780] FROM WINDOWS
GO
CREATE USER [PGWC\53579780] FOR LOGIN [PGWC\53579780]
GO
