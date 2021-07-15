SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_LogonFailures](@HTML varchar(max) out)
AS
/* 
	Returns HTML for "Logon Failures" section of DBA Checks Report
*/ 
SET NOCOUNT ON

   DECLARE @ErrorLogCount INT 
   DECLARE @LastLogDate DATETIME

   CREATE TABLE #ErrorLogInfo (
       LogDate DATETIME
      ,ProcessInfo NVARCHAR (50)
      ,[Text] NVARCHAR (MAX)
      )
   
   DECLARE @EnumErrorLogs TABLE (
       [Archive#] INT
      ,[Date] DATETIME
      ,LogFileSizeMB INT
      )

   INSERT INTO @EnumErrorLogs
   EXEC sp_enumerrorlogs

   SELECT @ErrorLogCount = MIN([Archive#]), @LastLogDate = MAX([Date])
   FROM @EnumErrorLogs

   WHILE @ErrorLogCount IS NOT NULL
   BEGIN

      INSERT INTO #ErrorLogInfo
      EXEC sp_readerrorlog @ErrorLogCount

      SELECT @ErrorLogCount = MIN([Archive#]), @LastLogDate = MAX([Date])
      FROM @EnumErrorLogs
      WHERE [Archive#] > @ErrorLogCount
      AND @LastLogDate > getdate() - 7 


	  
  
   END

 IF EXISTS (
   select * from #ErrorLogInfo WHERE ProcessInfo = 'Logon'
      AND TEXT LIKE '%fail%'
	  AND LogDate >= getdate() - 1
	  OR LogDate is null AND Text NOT LIKE '%PGWC\VM-BIOL-SQL03$%')

BEGIN
SELECT @HTML = 
	'<h2>Logon Failures</h2>
	<table>' +
	(SELECT 'Log Date' th,
			'Process Info' th,
			'Text' th
			
	FOR XML RAW('tr'),ELEMENTS) 
	+
	(SELECT LogDate td,
			ProcessInfo td,
			Text td
	FROM #ErrorLogInfo WHERE ProcessInfo = 'Logon'
      AND TEXT LIKE '%fail%'
	  AND LogDate >= getdate() - 1 AND Text NOT LIKE '%PGWC\VM-BIOL-SQL03$%'
	  OR LogDate is null 
	FOR XML RAW('tr'),ELEMENTS XSINIL)
	+ '</table>'

END
ELSE
BEGIN
	SET @HTML = '<h2>Logon Failures</h2>
				<span class="Healthy">No failed logins</span><br/>'	
END
	drop table #ErrorLogInfo
GO
GRANT ALTER ON  [dbo].[DBAChecks_LogonFailures] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_LogonFailures] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_LogonFailures] TO [db_sp_viewer]
GO
