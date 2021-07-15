SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_ErrorLog](@NumDays int)
AS
/* 
	Returns HTML for "ErrorLog.htm" attachment of DBA Checks Report
*/ 
SET NOCOUNT ON
CREATE TABLE #ErrorLog(
	LogDate datetime,
	ErrorSource nvarchar(max),
	ErrorMessage nvarchar(max)
)

CREATE TABLE #ErrorLogs(
	ID INT primary key not null,
	LogDate DateTime NOT NULL,
	LogFileSize bigint
)
DECLARE @MinDate datetime
SET @MinDate = CONVERT(datetime,CONVERT(varchar,DATEADD(d,-@NumDays,GetDate()),112),112)

--Get a list of available error logs
INSERT INTO #ErrorLogs(ID,LogDate,LogFileSize)
EXEC master.dbo.xp_enumerrorlogs

DECLARE @ErrorLogID int

DECLARE cErrorLogs CURSOR FOR
	SELECT ID
	FROM #ErrorLogs
	WHERE LogDate >= @MinDate

OPEN cErrorLogs
FETCH NEXT FROM cErrorLogs INTO @ErrorLogID
-- Read applicable error logs into the #errorlog table
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #ErrorLog(LogDate,ErrorSource,ErrorMessage)
	exec sp_readerrorlog @ErrorLogID
	FETCH NEXT FROM cErrorLogs INTO @ErrorLogID
END

CLOSE cErrorLogs
DEALLOCATE cErrorLogs

SELECT '<HTML>
<HEAD>
<style type="text/css">
table {
/*width:100%;*/
font:8pt tahoma,arial,sans-serif;
border-collapse:collapse;
}
th {
color:#FFFFFF;
font:bold 8pt tahoma,arial,sans-serif;
background-color:#204c7d;
padding-left:5px;
padding-right:5px;
}
td {
color:#000000;
font:8pt tahoma,arial,sans-serif;
border:1px solid #DCDCDC;
border-collapse:collapse;
}
.Warning {
background-color:#FFFF00; 
color:#2E2E2E;
}
.Critical {
background-color:#FF0000;
color:#FFFFFF;
}
.Healthy {
background-color:#458B00;
color:#FFFFFF;
}
</style>
</HEAD>
<BODY>
<table><tr><th>Log Date</th><th>Source</th><th>Message</th></tr>' + 
(SELECT CONVERT(varchar,LogDate,120) td,
	CAST('<div><![CDATA[' + ErrorSource + N']]></div>' as XML) td,
	CAST('<div' + 
		CASE WHEN (ErrorMessage LIKE '%error%' OR ErrorMessage LIKE '%exception%' 
					OR ErrorMessage LIKE '%stack dump%' OR ErrorMessage LIKE '%fail%') 
				AND ErrorMessage NOT LIKE '%DBCC%' THEN ' Class="Critical"' 
		WHEN ErrorMessage LIKE '%warning%' THEN ' Class="Warning"'
		ELSE '' END 
		+ '><![CDATA[' + ErrorMessage + N']]></div>' as XML) td
FROM #ErrorLog
WHERE LogDate >= @MinDate
/*	Remove any error log records that we are not interested in
	ammend the where clause as appropriate
*/
AND ErrorMessage NOT LIKE '%This is an informational message%'
AND ErrorMessage NOT LIKE 'Authentication mode is%'
AND ErrorMessage NOT LIKE 'System Manufacturer%'
AND ErrorMessage NOT LIKE 'All rights reserved.'
AND ErrorMessage NOT LIKE 'Server Process ID is%'
AND ErrorMessage NOT LIKE 'Starting up database%'
AND ErrorMessage NOT LIKE 'Registry startup parameters%'
AND ErrorMessage NOT LIKE '(c) 2005 Microsoft%'
AND ErrorMessage NOT LIKE 'Server is listening on%'
AND ErrorMessage NOT LIKE 'Server local connection provider is ready to accept connection on%'
AND ErrorMessage NOT LIKE 'Logging SQL Server messages in file%'
AND ErrorMessage <> 'Clearing tempdb database.'
AND ErrorMessage <> 'Using locked pages for buffer pool.'
AND ErrorMessage <> 'Service Broker manager has started.'
ORDER BY LogDate DESC
FOR XML RAW('tr'),ELEMENTS XSINIL)
+ '</table></HEAD></BODY>' as HTML

DROP TABLE #ErrorLog
DROP TABLE #ErrorLogs
GO
GRANT ALTER ON  [dbo].[DBAChecks_ErrorLog] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_ErrorLog] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_ErrorLog] TO [db_sp_viewer]
GO
