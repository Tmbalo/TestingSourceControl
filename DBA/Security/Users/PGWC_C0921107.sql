IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\C0921107')
CREATE LOGIN [PGWC\C0921107] FROM WINDOWS
GO
CREATE USER [PGWC\C0921107] FOR LOGIN [PGWC\C0921107]
GO
