SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[usp_DailyChecks]
as

	/* Agent Jobs related Params */
DECLARE	@AgentJobsNumDays int=3, --Num of days to report failed jobs over
	/* Database Files related Params */
	@FileStatsIncludedDatabases varchar(max)=NULL, -- Comma sep list of databases to report filestats for. NULL=All, '' = None
	@FileStatsExcludedDatabases varchar(max)=NULL, -- Comma sep list of databases to report filestats for. NULL=No Exclusions
	@FileStatsPctUsedWarning int=90, -- Warn (Yellow) if free space in a database file is less than this threshold (Just for database specified in @FileStatsDatabases)
	@FileStatsPctUsedCritical int=95, -- Warn (Red) if free space in a database file is less than this threshold (Just for database specified in @FileStatsDatabases)
	/* Backup related Params */
	@DiffWarningThresholdDays int=3, -- Backup warning if no diff backup for "x" days
	@FullWarningThresholdDays int=7, -- Backup warning if no full backup for "x" days
	@TranWarningThresholdHours int=4, -- Backup warning if no tran backup for "x" hours
	/* Disc Drive related params*/
	@FreeDiskSpacePercentWarningThreshold int=15, -- Warn (Yellow) if free space is less than this threshold
	@FreeDiskSpacePercentCriticalThreshold int=10, -- Warn (Red) if free space is less than this threshold
	/* General related params */
	@UptimeCritical int = 1440, -- Critical/Red if system uptime (in minutes) is less than this value
	@UptimeWarning int = 2880, -- Warn/Yellow if system uptime (in minutes) is less than this value,
	/* Error Log Params */
	@ErrorLogDays int = 1,
	/* Email/Profile params */
	@Recipients nvarchar(max), -- Email list
	@MailProfile sysname=NULL

/*	Created By David Wiseman
	Version: 1.0
	http://www.wisesoft.co.uk
	Generates a DBA Checks HTML email report
*/
SET NOCOUNT ON
DECLARE @AgentJobsHTML varchar(max)
DECLARE @AgentJobStatsHTML varchar(max)
DECLARE @FileStatsHTML varchar(max)
DECLARE @DisksHTML varchar(max)
DECLARE @BackupsHTML varchar(max)
DECLARE @HTML varchar(max)
DECLARE @Uptime varchar(max)
DECLARE @Services varchar(max)
DECLARE @LogonFailure varchar(max)
DECLARE @Errorlogs varchar(max)
DECLARE @IndexFrag varchar(max)

SELECT @Uptime = 
	CASE WHEN DATEDIFF(mi,create_date,GetDate()) < @UptimeCritical THEN '<span class="Critical">'
	WHEN DATEDIFF(mi,create_date,GetDate()) < @Uptimewarning THEN '<span class="Warning">'
	ELSE '<span class="Healthy">' END + 
	-- get system uptime
	COALESCE(NULLIF(CAST((DATEDIFF(mi,create_date,GetDate())/1440 ) as varchar),'0') + ' day(s), ','')
	+ COALESCE(NULLIF(CAST(((DATEDIFF(mi,create_date,GetDate())%1440)/60) as varchar),'0') + ' hour(s), ','')
	+ CAST((DATEDIFF(mi,create_date,GetDate())%60) as varchar) + 'min'
	--
	+ '</span>'
FROM sys.databases 
WHERE NAME='tempdb'

exec [dbo].[DBAChecks_Services] @HTML = @Services out

exec [dbo].[DBAChecks_LogonFailures] @HTML = @LogonFailure out

exec [dbo].[DBAChecks_ErrorLogDaily] @HTML = @Errorlogs out, @NumDays = @ErrorLogDays

exec dbo.DBAChecks_FailedAgentJobs @HTML=@AgentJobsHTML out,@NumDays=@AgentJobsNumDays

exec [dbo].[DBAChecks_IndexFragDaily] @HTML=@IndexFrag out

exec dbo.DBAChecks_JobStats @HTML=@AgentJobStatsHTML out,@NumDays=@AgentJobsNumDays

exec dbo.DBAChecks_DBFiles 
	@IncludeDBs=@FileStatsIncludedDatabases,
	@ExcludeDBs=@FileStatsExcludedDatabases,
	@WarningThresholdPCT=@FileStatsPctUsedWarning,
	@CriticalThresholdPCT=@FileStatsPctUsedCritical,
	@HTML=@FileStatsHTML out


exec dbo.DBAChecks_DiskDrives @HTML=@DisksHTML out,@PCTFreeWarningThreshold=@FreeDiskSpacePercentWarningThreshold,@PCTFreeCriticalThreshold=@FreeDiskSpacePercentCriticalThreshold 

exec dbo.DBAChecks_Backups @HTML=@BackupsHTML OUT,@DiffWarningThresHoldDays=@DiffWarningThresHoldDays,
	@FullWarningThresholdDays=@FullWarningThresholdDays ,@TranWarningThresholdHours=@FullWarningThresholdDays

SET @HTML = 
'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<style type="text/css">
table {
font:8pt tahoma,arial,sans-serif;
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
padding-left:3px;
padding-right:3px;
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
h1 {
color:#FFFFFF;
font:bold 16pt arial,sans-serif;
background-color:#204c7d;
text-align:center;
}
h2 {
color:#204c7d;
font:bold 14pt arial,sans-serif;
}
h3 {
color:#204c7d;
font:bold 12pt arial,sans-serif;
}
body {
color:#000000;
font:8pt tahoma,arial,sans-serif;
margin:0px;
padding:0px;
}
</style>
</head>
<body>

<table>
  <tr>
	<td>Healthy</td>
    <td style="background-color:#458B00">      </td>
  </tr>
  <tr>
	<td>Warning</td>
    <td style="background-color:#FFFF00">      </td>
  </tr>
  <tr>
	<td>Critical</td>
    <td style="background-color:#FF0000">      </td>
  </tr>
</table>
<h1>DBA Checks Report for ' + @@SERVERNAME + '</h1>
<h2>General Health</h2>
<b>System Uptime (SQL Server): ' + @Uptime + '</b><br/>
<b>Version: </b>' + CAST(SERVERPROPERTY('productversion') as nvarchar(max)) + ' ' 
	+ CAST(SERVERPROPERTY ('productlevel') as nvarchar(max))
    + ' ' + CAST(SERVERPROPERTY ('edition') as nvarchar(max)) 
+ COALESCE(@DisksHTML,'<div class="Critical">Error collecting Disk Info</div>')
+ COALESCE(@Services,'<div class="Critical">Error collecting Services Info</div>')
+ COALESCE(@LogonFailure,'<div class="Critical">Error collecting LogonFailure Info</div>')
+ COALESCE(@BackupsHTML,'<div class="Critical">Error collecting Backup Info</div>')
+ COALESCE(@AgentJobStatsHTML,'<div class="Critical">Error collecting Agent Jobs Stats</div>')
+ COALESCE(@AgentJobsHTML,'<div class="Critical">Error collecting Agent Jobs Info</div>')
+ COALESCE(@Errorlogs,'<div class="Critical">Error collecting Errorlogs Info</div>')
+ COALESCE(@IndexFrag,'<div class="Critical">Error collecting Index Frag Info</div>')
+ COALESCE(@FileStatsHTML,'<div class="Critical">Error collecting File Stats Info</div>')
+ '</body></html>'


DECLARE @mes varchar(max) = @HTML

select @mes

--declare @subject varchar(50)
--set @subject = 'DBA Daily Checks (' + @@SERVERNAME + ')'

--DECLARE @ErrorLogSQL nvarchar(max)
--DECLARE @ExecuteQueryDB sysname
--SET @ErrorLogSQL = 'exec DBAChecks_ErrorLog @NumDays=' + CAST(@ErrorLogDays as varchar)
--SET @ExecuteQueryDB = DB_NAME()

--EXEC msdb.dbo.sp_send_dbmail
--	@query=@ErrorLogSQL,
--	@attach_query_result_as_file = 1,
--	@query_attachment_filename = 'ErrorLog.html',
--	@query_result_header = 0,
--	@query_no_truncate = 0,
--	--@query_result_width=32767,
--	@recipients =@Recipients,
--	@body = @HTML,
--	@body_format ='HTML',
--	@subject = @subject,
--	@execute_query_database=@ExecuteQueryDB,
--	@profile_name = @MailProfile

GO
GRANT ALTER ON  [dbo].[usp_DailyChecks] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[usp_DailyChecks] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[usp_DailyChecks] TO [db_sp_viewer]
GO
