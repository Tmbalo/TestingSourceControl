IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\C4810803')
CREATE LOGIN [PGWC\C4810803] FROM WINDOWS
GO
CREATE USER [PGWC\C4810803] FOR LOGIN [PGWC\C4810803]
GO
