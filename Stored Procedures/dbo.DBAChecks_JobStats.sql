SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_JobStats](@NumDays int,@HTML nvarchar(max) out)
AS
/* 
	Returns HTML for "Agent Jobs Stats in the last 'X' days" section of DBA Checks Report
*/ 
SET ANSI_WARNINGS OFF
DECLARE @FromDate char(8)
SET @FromDate = CONVERT(char(8), (select dateadd (day,(-1*@NumDays), getdate())), 112);

WITH nextRun as (
	SELECT js.job_id, 
		MAX(CONVERT(datetime,CONVERT(CHAR(8), NULLIF(next_run_date,0), 112) 
			+ ' ' 
			+ STUFF(STUFF(RIGHT('000000' 
			+ CONVERT(VARCHAR(8), next_run_time), 6), 5, 0, ':'), 3, 0, ':') )
			) as next_run_time
	FROM msdb..sysjobschedules js
	GROUP BY js.job_id
),
lastRun as (
	SELECT jh.job_id,CONVERT(datetime,CONVERT(CHAR(8), run_date, 112) 
		+ ' ' 
		+ STUFF(STUFF(RIGHT('000000' 
		+ CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':') ) as last_run_time,
		run_status as last_run_status,
		CAST(message as nvarchar(max)) as last_result,
		ROW_NUMBER() OVER(PARTITION BY job_id ORDER BY run_date DESC,run_time DESC) rnum
	FROM msdb..sysjobhistory jh
	WHERE run_status IN(0,1,3) --Succeeded/Failed/Cancelled
)
,JobStats AS (
	select name,
			MAX(enabled) enabled,
			SUM(CASE WHEN run_status = 1 THEN 1 ELSE 0 END) as SucceededCount,
			SUM(CASE WHEN run_status = 0 THEN 1 ELSE 0 END) as FailedCount,
			SUM(CASE WHEN run_status = 3 THEN 1 ELSE 0 END) as CancelledCount,
			MAX(last_run_time) last_run_time,
			MAX(next_run_time) next_run_time,
			MAX(last_run_status) last_run_status,
			COALESCE(MAX(last_result),'Unknown') last_result
	from msdb..sysjobs j
	LEFT JOIN msdb..sysjobhistory jh ON j.job_id = jh.job_id AND jh.run_date >= @FromDate and jh.step_id = 0
	LEFT JOIN nextrun ON j.job_id = nextrun.job_id
	LEFT JOIN lastRun ON j.job_id = lastRun.job_id AND rnum=1
	GROUP BY name
)
SELECT @HTML =N'<h2>Agent Job Stats in the last ' + CAST(@NumDays as varchar) + N' days</h2>
	<table>' +
	(SELECT 'Name' th,
	'Enabled' th,
	'Succeeded' th,
	'Failed' th,
	'Cancelled' th,
	'Last Run Time' th,
	'Next Run Time' th,
	'Last Result' th
	FOR XML RAW('tr'),ELEMENTS) 
	+ (SELECT name td,
			CAST(CASE WHEN enabled = 1 THEN N'<div class="Healthy">Yes</div>'
					ELSE N'<div class="Warning">No</div>' END as XML) td,
			CAST(CASE WHEN SucceededCount = 0 THEN  N'<div class="Warning">'
					ELSE N'<div>' END
					+ CAST(SucceededCount as varchar) + '</div>' as XML) td,
			CAST(CASE WHEN FailedCount >0 THEN  N'<div class="Critical">'
					ELSE N'<div class="Healthy">' END
					+ CAST(FailedCount as varchar) + N'</div>' as XML) td,
			CAST(CASE WHEN CancelledCount >0 THEN  N'<div class="Critical">'
					ELSE N'<div class="Healthy">' END
					+ CAST(CancelledCount as varchar) + N'</div>' as XML) td,
			LEFT(CONVERT(varchar,last_run_time,13),17) td,
			LEFT(CONVERT(varchar,next_run_time,13),17) td,
			CAST(CASE WHEN last_run_status = 1 THEN N'<span class="Healthy"><![CDATA[' + last_result + N']]></span>' 
					ELSE N'<span class="Critical"><![CDATA[' + last_result + N']]></span>' END  AS XML)  td 
		FROM JobStats
		ORDER BY last_run_time DESC
		FOR XML RAW('tr'),ELEMENTS XSINIL
	) + N'</table>'
GO
GRANT ALTER ON  [dbo].[DBAChecks_JobStats] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_JobStats] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_JobStats] TO [db_sp_viewer]
GO
