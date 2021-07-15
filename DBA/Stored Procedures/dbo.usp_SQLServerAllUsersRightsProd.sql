SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[usp_SQLServerAllUsersRightsProd]
AS

--	All from Prod Environment...
IF OBJECT_ID('DBA..tblSQLServerAllUsersRightsProd') IS NOT NULL
	TRUNCATE TABLE DBA..tblSQLServerAllUsersRightsProd

IF OBJECT_ID('DBA..tblSQLServerAllUsersRightsProd') IS NULL
BEGIN
	CREATE TABLE DBA..tblSQLServerAllUsersRightsProd (
		ServerName		VARCHAR(75),
		DatabaseName	VARCHAR(75),
		UserName		VARCHAR(75),
		UserType		VARCHAR(75),
		RoleName		VARCHAR(75),
		RoleType		VARCHAR(75) 
	)
END

DECLARE	@VarQuery VARCHAR(MAX) 

SELECT	@VarQuery = 'USE ? 

	INSERT	INTO DBA..tblSQLServerAllUsersRightsProd
	SELECT  @@SERVERNAME	AS ServerName,
			''?''			AS DatabaseName,
			b.[Name]		AS UserName,
			b.[Type_Desc]	AS UserType,
			c.[Name]		AS RoleName,
			c.[Type_Desc]	AS RoleType  
	FROM    sys.Database_Role_Members AS a
			INNER JOIN sys.Database_Principals AS b ON a.member_principal_id = b.principal_id
			INNER JOIN sys.Database_Principals AS c ON a.role_principal_id = c.principal_id  
	WHERE	b.[Type_Desc] IN (''WINDOWS_USER'', ''SQL_USER'')  
	UNION
	SELECT  @@SERVERNAME	AS ServerName,
			''?''			AS DatabaseName,
			b.[Name]		COLLATE SQL_Latin1_General_CP1_CI_AS	AS UserName,
			b.[Type_Desc]	COLLATE SQL_Latin1_General_CP1_CI_AS	AS UserType,
			c.[Name]		COLLATE SQL_Latin1_General_CP1_CI_AS	AS RoleName,
			c.[Type_Desc]	COLLATE SQL_Latin1_General_CP1_CI_AS 	AS RoleType
	FROM    sys.Server_Role_Members AS a
			INNER JOIN sys.Server_Principals AS b ON a.member_principal_id = b.principal_id
			INNER JOIN sys.Server_Principals AS c ON a.role_principal_id = c.principal_id  
	WHERE	b.[Type_Desc] IN (''WINDOWS_LOGIN'', ''SQL_LOGIN'')  '

EXEC sp_MSforeachdb @VarQuery 
GO
GRANT ALTER ON  [dbo].[usp_SQLServerAllUsersRightsProd] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[usp_SQLServerAllUsersRightsProd] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[usp_SQLServerAllUsersRightsProd] TO [db_sp_viewer]
GO
