SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[usp_SQLServerAllObjectPermissionProd]
AS
--	Run this in Dev Enrironment...
IF OBJECT_ID('DBA..tblSQLServerAllObjectPermissionProd') IS NOT NULL
	TRUNCATE TABLE DBA..tblSQLServerAllObjectPermissionProd

IF OBJECT_ID('DBA..tblSQLServerAllObjectPermissionProd') IS NULL
BEGIN
	CREATE TABLE DBA..tblSQLServerAllObjectPermissionProd(
		
		ServerName		VARCHAR(75),
		DatabaseName	VARCHAR(75),
		login_name		VARCHAR(75),
		UserName		VARCHAR(75),
		UserType		VARCHAR(75),
		RoleName		VARCHAR(75),
		Permission_Type	VARCHAR(75),
		Permission_State VARCHAR(75),
		Objecct_Type  VARCHAR(75),
		Object_Name		VARCHAR(150),
		Date_Modified datetime,
		Date_Created datetime,
		Date_Added datetime,
		Is_Disabled int

	)
END

DECLARE	@VarQuery VARCHAR(MAX) 

SELECT	@VarQuery = 'USE ? 

	INSERT	INTO DBA..tblSQLServerAllObjectPermissionProd
	SELECT  @@SERVERNAME	AS ServerName, ''?'' AS DatabaseName, [LoginName] = ulogin.[name],
	[DatabaseUserName] = princ.[name], 
    [UserType] = CASE princ.[type]
                    WHEN ''S'' THEN ''SQL User''
                    WHEN ''U'' THEN ''Windows User''
                    WHEN ''G'' THEN ''Windows Group''
                 END,  
        
    [Role] = null,      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = CASE perm.[class] 
                        WHEN 1 THEN obj.type_desc               -- Schema-contained objects
                        ELSE perm.[class_desc]                  -- Higher-level objects
                   END,       
    [ObjectName] = CASE perm.[class] 
                        WHEN 1 THEN OBJECT_NAME(perm.major_id)  -- General objects
                        WHEN 3 THEN schem.[name]                -- Schemas
                        WHEN 4 THEN imp.[name]                  -- Impersonations
                   END,
	princ.modify_date as [Date_Modified]
	,princ.create_date as [Date_Created]
	,GETDATE() as [Date_Added]
	,ulogin.is_disabled as [Is_Disabled?]
FROM sys.database_principals princ  
LEFT JOIN
    sys.server_principals ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN        
    sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN
    sys.columns col ON col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
LEFT JOIN
    sys.schemas schem ON schem.[schema_id] = perm.[major_id]
LEFT JOIN
    sys.database_principals imp ON imp.[principal_id] = perm.[major_id]
WHERE princ.[type] IN (''S'',''U'',''G'') AND princ.[name] NOT IN (''sys'', ''INFORMATION_SCHEMA'') AND princ.[name] NOT IN (''dbo'', ''guest'') AND princ.[name] NOT LIKE ''NT%'' AND princ.[name] NOT LIKE ''##%'' '

EXEC sp_MSforeachdb @VarQuery 


GO
GRANT ALTER ON  [dbo].[usp_SQLServerAllObjectPermissionProd] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[usp_SQLServerAllObjectPermissionProd] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[usp_SQLServerAllObjectPermissionProd] TO [db_sp_viewer]
GO
