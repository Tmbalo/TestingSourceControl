SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_Services](@HTML varchar(max) out)
AS
/* 
	Returns HTML for "Services status" section of DBA Checks Report
*/ 
--Check SQL Server Services Status

   


SET NOCOUNT ON

IF OBJECT_ID ('tempdb.dbo.RegResult') IS NOT NULL
	DROP TABLE tempdb.dbo.RegResult

CREATE TABLE tempdb.dbo.RegResult
   (
   ResultValue NVARCHAR(4)
   )

IF OBJECT_ID ('tempdb.dbo.ServicesServiceStatus') IS NOT NULL
	DROP TABLE tempdb.dbo.ServicesServiceStatus

CREATE TABLE tempdb.dbo.ServicesServiceStatus  
   (
   RowID INT IDENTITY(1,1)
   ,ServerName NVARCHAR(128)
   ,ServiceName NVARCHAR(128)
   ,ServiceStatus VARCHAR(128)
   ,StatusDateTime DATETIME DEFAULT (GETDATE())
   ,PhysicalSrverName NVARCHAR(128)
   )

DECLARE
    @ChkInstanceName NVARCHAR(128)   /*Stores SQL Instance Name*/
   ,@ChkSrvName NVARCHAR(128)        /*Stores Server Name*/
   ,@TrueSrvName NVARCHAR(128)       /*Stores where code name needed */
   ,@SQLSrv NVARCHAR(128)            /*Stores server name*/
   ,@PhysicalSrvName NVARCHAR(128)   /*Stores physical name*/
   ,@DTS NVARCHAR(128)               /*Store SSIS Service Name */
   ,@FTS NVARCHAR(128)               /*Stores Full Text Search Service name*/
   ,@RS NVARCHAR(128)                /*Stores Reporting Service name*/
   ,@SQLAgent NVARCHAR(128)          /*Stores SQL Agent Service name*/
   ,@OLAP NVARCHAR(128)              /*Stores Analysis Service name*/
   ,@REGKEY NVARCHAR(128)            /*Stores Registry Key information*/


SET @PhysicalSrvName = CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128))
SET @ChkSrvName = CAST(SERVERPROPERTY('INSTANCENAME') AS VARCHAR(128))
SET @ChkInstanceName = @@serverName

IF @ChkSrvName IS NULL        /*Detect default or named instance*/
BEGIN
   SET @TrueSrvName = 'MSSQLSERVER'
   SELECT @OLAP = 'MSSQLServerOLAPService'  /*Setting up proper service name*/
   SELECT @FTS = 'MSFTESQL'
   SELECT @RS = 'ReportServer'
   SELECT @SQLAgent = 'SQLSERVERAGENT'
   SELECT @SQLSrv = 'MSSQLSERVER'
END
ELSE
BEGIN
   SET @TrueSrvName =  CAST(SERVERPROPERTY('INSTANCENAME') AS VARCHAR(128))
   SET @SQLSrv = '$'+@ChkSrvName
   SELECT @OLAP = 'MSOLAP' + @SQLSrv /*Setting up proper service name*/
   SELECT @FTS = 'MSFTESQL' + @SQLSrv
   SELECT @RS = 'ReportServer' + @SQLSrv
   SELECT @SQLAgent = 'SQLAgent' + @SQLSrv
   SELECT @SQLSrv = 'MSSQL' + @SQLSrv
END


/* ---------------------------------- SQL Server Service Section ----------------------------------------------*/

SET @REGKEY = 'System\CurrentControlSet\Services\'+@SQLSrv

INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of SQL Sever service*/
   EXEC xp_servicecontrol N'QUERYSTATE',@SQLSrv
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'MS SQL Server Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'MS SQL Server Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END

/* ---------------------------------- SQL Server Agent Service Section -----------------------------------------*/

SET @REGKEY = 'System\CurrentControlSet\Services\'+@SQLAgent

INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of SQL Agent service*/
   EXEC xp_servicecontrol N'QUERYSTATE',@SQLAgent
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'SQL Server Agent Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus  SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'SQL Server Agent Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END


/* ---------------------------------- SQL Browser Service Section ----------------------------------------------*/

SET @REGKEY = 'System\CurrentControlSet\Services\SQLBrowser'

INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of SQL Browser Service*/
   EXEC MASTER.dbo.xp_servicecontrol N'QUERYSTATE',N'sqlbrowser'
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'SQL Browser Service - Instance Independent' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'SQL Browser Service - Instance Independent' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END

/* ---------------------------------- Integration Service Section ----------------------------------------------*/

DECLARE @version as table (VersionN varchar(20))
DECLARE @DST varchar(128)
DECLARE @v varchar(20)
INSERT INTO @version
SELECT
  CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%' THEN 'SQL2017' 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '15%' THEN 'SQL2019' 
     ELSE 'unknown'
  END AS MajorVersion
  --SERVERPROPERTY('ProductLevel') AS ProductLevel,
 -- SERVERPROPERTY('Edition') AS Edition,
  --SERVERPROPERTY('ProductVersion') AS ProductVersion

  SELECT @v = VersionN FROM @version

  IF @v = 'SQL2000' 
  BEGIN
	SET @DST = 'MsDtsServer80'
  END

  IF @v = 'SQL2005' 
  BEGIN
	SET @DST = 'MsDtsServer90'
  END

  IF @v = 'SQL2008' 
  BEGIN
	SET @DST = 'MsDtsServer100'
  END

  IF @v = 'SQL2012' 
  BEGIN
	SET @DST = 'MsDtsServer110'
  END

  IF @v = 'SQL2014' 
  BEGIN
	SET @DST = 'MsDtsServer120'
  END

  IF @v = 'SQL2016' 
  BEGIN
	SET @DST = 'MsDtsServer130'
  END

  IF @v = 'SQL2017' 
  BEGIN
	SET @DST = 'MsDtsServer140'
  END

  IF @v = 'SQL2019' 
  BEGIN
	SET @DST = 'MsDtsServer150'
  END
  


SET @REGKEY = 'System\CurrentControlSet\Services\' +@DST


INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of Intergration Service*/
   EXEC MASTER.dbo.xp_servicecontrol N'QUERYSTATE',@DST
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Integration Service - Instance Independent' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Integration Service - Instance Independent' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END

/* ---------------------------------- Reporting Service Section ------------------------------------------------*/

SET @REGKEY = 'System\CurrentControlSet\Services\'+@RS

INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of Reporting service*/
   EXEC MASTER.dbo.xp_servicecontrol N'QUERYSTATE',@RS
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Reporting Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Reporting Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END

/* ---------------------------------- Analysis Service Section -------------------------------------------------*/
IF @ChkSrvName IS NULL        /*Detect default or named instance*/
   BEGIN
   SET @OLAP = 'MSSQLServerOLAPService'
END
ELSE
   BEGIN
   SET @OLAP = 'MSOLAP'+'$'+@ChkSrvName
   SET @REGKEY = 'System\CurrentControlSet\Services\'+@OLAP
END

INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of Analysis service*/
   EXEC MASTER.dbo.xp_servicecontrol N'QUERYSTATE',@OLAP
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Analysis Services' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Analysis Services' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END

/* ---------------------------------- Full Text Search Service Section -----------------------------------------*/

SET @REGKEY = 'System\CurrentControlSet\Services\'+@FTS

INSERT tempdb.dbo.RegResult ( ResultValue ) EXEC MASTER.sys.xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key= @REGKEY

IF (SELECT ResultValue FROM tempdb.dbo.RegResult) = 1
BEGIN
   INSERT tempdb.dbo.ServicesServiceStatus (ServiceStatus)  /*Detecting staus of Full Text Search service*/
   EXEC MASTER.dbo.xp_servicecontrol N'QUERYSTATE',@FTS
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Full Text Search Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END
ELSE
BEGIN
   INSERT INTO tempdb.dbo.ServicesServiceStatus (ServiceStatus) VALUES ('NOT INSTALLED')
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServiceName = 'Full Text Search Service' WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET ServerName = @TrueSrvName WHERE RowID = @@identity
   UPDATE tempdb.dbo.ServicesServiceStatus SET PhysicalSrverName = @PhysicalSrvName WHERE RowID = @@identity
   TRUNCATE TABLE tempdb.dbo.RegResult
END

/* -------------------------------------------------------------------------------------------------------------*/


/* -------------------------------------------------------------------------------------------------------------*/

/* --Send DB Mail - Uncomment this section if you want to send email of the service(s) status

EXEC msdb.dbo.sp_send_dbmail @profile_name='SQLAdmin',
@recipients='pearlknows@yahoo.com',
@subject='SQL Service(s) Status Update',
@body='This is the latest SQL Server Service(s) Status Report. Please review and take appropriate action if necessary:',
@query='SET NOCOUNT ON SELECT  ServiceName AS ''SQL Server Service''
   ,ServiceStatus AS ''Current Service Status''
   FROM tempdb.dbo.ServicesServiceStatus'
*/

--SELECT  ServiceName AS 'SQL Server Service'
--   ,ServiceStatus AS 'Current Service Status'
--   --,StatusDateTime AS 'Date/Time Service Status Checked'
--FROM tempdb.dbo.ServicesServiceStatus


SELECT @HTML = 
	'<h2>SQL Server related services running</h2>
	<table>' +
	(SELECT 'Service Name' th,
			'Status' th
			
	FOR XML RAW('tr'),ELEMENTS) 
	+
	(SELECT ServiceName td,
			CAST(CASE WHEN ServiceStatus = 'Stopped.' THEN '<div class="Critical">' + CAST(ServiceStatus as varchar) + '</div>'
			ELSE '<div class="Healthy">' + CAST(ServiceStatus as varchar) + '</div>' END as XML) td
	FROM tempdb.dbo.ServicesServiceStatus 
	FOR XML RAW('tr'),ELEMENTS XSINIL)
	+ '</table>'


DROP TABLE tempdb.dbo.ServicesServiceStatus    /*Perform cleanup*/
DROP TABLE tempdb.dbo.RegResult

GO
GRANT ALTER ON  [dbo].[DBAChecks_Services] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_Services] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_Services] TO [db_sp_viewer]
GO
