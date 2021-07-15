IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PGWC\srv_sql_phdc')
CREATE LOGIN [PGWC\srv_sql_phdc] FROM WINDOWS
GO
CREATE USER [PGWC\srv_sql_phdc] FOR LOGIN [PGWC\srv_sql_phdc]
GO
