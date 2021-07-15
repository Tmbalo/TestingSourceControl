SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ups_Drop_User]
@user varchar(255)
as
-- ===========================================================================================================================
-- Author: Thozamile Mbalo      
-- Create date: 2021-04-06 11:00 AM
-- Description: This stored proc will drop the user permissions from the instance level to the database object level then drops 
--				the login.

/*****************Change History***********************************************************************************************

Date (yyyy-mm-dd)	Author					    Comments
------------------	--------------------		-------------------------------------------------------------------------------


********************************************************************************************************************************/
-- ==============================================================================================================================
SET NOCOUNT ON;

PRINT '---Drop login from all Server Roles'
select distinct 

---Add serverroles
'EXEC sp_dropsrvrolemember '''  + UserName + ''', ''' + RoleName + ''

FROM DBA..tblSQLServerAllUsersRightsDev p
JOIN [master].sys.databases q on p.DatabaseName = q.name
WHERE RoleType = 'SERVER_ROLE' and UserName = @user
and q.database_id > 4
order by 1



PRINT '---Drop user from all databases'

		select distinct
      'USE ' + p.[DatabaseName] + ';
DROP USER [' + p.UserName + ']
GO
'
FROM DBA..tblSQLServerAllUsersRightsDev p
JOIN [master].sys.databases q on p.DatabaseName = q.name
WHERE UserName = @user
and q.database_id > 4
order by 1


PRINT '---Drop user from all database roles'

		select distinct 
      'USE ' + [DatabaseName] + ';
EXEC sp_droprolemember '''  + RoleName + ''', ''' + UserName + '''

'
FROM DBA..tblSQLServerAllUsersRightsDev p
JOIN [master].sys.databases q on p.DatabaseName = q.name
WHERE RoleType = 'DATABASE_ROLE' and UserName = @user
and q.database_id > 4
order by 1



SET NOCOUNT ON;
PRINT '---Revoke all Database Level Permissions'

DECLARE @dbs2 table (dbname sysname)
DECLARE @Next2 sysname
insert into @dbs2
--Use this for all databases
select p.name from sys.databases p
where p.database_id > 4
order by name 

select top 1 @Next2 = dbname from @dbs2 order by dbname
while (@@rowcount<>0)
begin


exec( 'USE  [' + @Next2 + ']

SELECT	''USE '  + @Next2 + '
'' + '''' +
CASE WHEN perm.state <> ''W'' THEN ''REVOKE'' ELSE ''REVOKE'' END
	+ SPACE(1) + perm.permission_name + SPACE(1)  
	+ SPACE(1) + ''TO'' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
	+ CASE WHEN perm.state <> ''W'' THEN SPACE(0) ELSE SPACE(1) + ''WITH REVOKE OPTION'' END 
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
	WHERE class_desc in (''DATABASE'') and USER_NAME(usr.principal_id) = '''+ @user +'''
ORDER BY perm.permission_name ASC, perm.state_desc ASC

') --UserName = @user
delete @dbs2 where dbname = @Next2
select top 1 @Next2 = dbname from @dbs2 order by dbname
end




PRINT '---Revoke all Schema Permissions'

DECLARE @dbs1 table (dbname sysname)
DECLARE @Next1 sysname
insert into @dbs1
--Use this for all databases
select p.name from sys.databases p
where p.database_id > 4
order by name 

select top 1 @Next1 = dbname from @dbs1 order by dbname
while (@@rowcount<>0)
begin


exec( 'USE  [' + @Next1 + ']

SELECT	''USE '  + @Next1 + '
'' + '''' +
CASE WHEN perm.state <> ''W'' THEN ''REVOKE'' ELSE ''REVOKE'' END
	+ SPACE(1) + perm.permission_name + SPACE(1) + ''ON SCHEMA ::'' + QUOTENAME(s.name)  
	+ SPACE(1) + ''TO'' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
	+ CASE WHEN perm.state <> ''W'' THEN SPACE(0) ELSE SPACE(1) + ''WITH REVOKE OPTION'' END 
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
	INNER JOIN sys.schemas s ON perm.major_id = s.schema_id
	WHERE s.name NOT IN (''sys'') and USER_NAME(usr.principal_id) = ''' + @user + '''
ORDER BY perm.permission_name ASC, perm.state_desc ASC

')
delete @dbs1 where dbname = @Next1
select top 1 @Next1 = dbname from @dbs1 order by dbname
end



PRINT '---Revoke all Database Object Permissions'

DECLARE @dbs table (dbname sysname)
DECLARE @Next sysname
insert into @dbs
--Use this for all databases
select p.name from sys.databases p
where p.database_id > 4
order by name 

select top 1 @Next = dbname from @dbs order by dbname
while (@@rowcount<>0)
begin


exec( 'USE  [' + @Next + ']

SELECT	''USE '  + @Next + '
'' + '''' +
CASE WHEN perm.state <> ''W'' THEN ''REVOKE'' ELSE ''REVOKE'' END
	+ SPACE(1) + perm.permission_name + SPACE(1) + ''ON '' + QUOTENAME(s.name) + ''.'' + QUOTENAME(obj.name) 
	+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE ''('' + QUOTENAME(cl.name) + '')'' END
	+ SPACE(1) + ''TO'' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
	+ CASE WHEN perm.state <> ''W'' THEN SPACE(0) ELSE SPACE(1) + ''WITH REVOKE OPTION'' END 
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.objects AS obj
	ON perm.major_id = obj.[object_id]
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
	LEFT JOIN
	sys.columns AS cl
	ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
	INNER JOIN sys.schemas s ON obj.schema_id = s.schema_id
	WHERE obj.type NOT IN (''S'') AND s.name NOT IN (''sys'') and USER_NAME(usr.principal_id) = ''' + @user + '''
ORDER BY perm.permission_name ASC, perm.state_desc ASC

')
delete @dbs where dbname = @Next
select top 1 @Next = dbname from @dbs order by dbname
end

PRINT '---Drop the login'

select 'DROP LOGIN [' + @user + '];'

GO
GRANT ALTER ON  [dbo].[ups_Drop_User] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[ups_Drop_User] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[ups_Drop_User] TO [db_sp_viewer]
GO
