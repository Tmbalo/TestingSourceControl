SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[DBAChecks_DiskDrives](@PCTFreeWarningThreshold int,@PCTFreeCriticalThreshold int,@HTML varchar(max) out)
AS
/* 
	Returns HTML for "Disk Drives" section of DBA Checks Report
*/ 
declare @bytestotb float,@bytestogb float,@bytestomb float
select @bytestotb =  1099511627776,@bytestogb = 1073741824,@bytestomb=1048576.0;

WITH DriveInfo AS (
	select distinct    
		vs.volume_mount_point AS Drive
      ,	vs.logical_volume_name AS volume_label
	  ,	case when vs.total_bytes > @bytestotb then cast(round(vs.total_bytes /@bytestotb,1) as varchar) + ' TB'
			when vs.total_bytes > @bytestogb then cast(round(vs.total_bytes /@bytestogb,1) as varchar) + ' GB'
			else cast(round(vs.total_bytes / @bytestomb,1) as varchar) + ' MB' END as Size,
		case when vs.available_bytes > @bytestotb then cast(round(vs.available_bytes /@bytestotb,1) as varchar) + ' TB'
			when vs.available_bytes > @bytestogb then cast(round(vs.available_bytes /@bytestogb,1) as varchar) + ' GB'
			else cast(round(vs.available_bytes / @bytestomb,1) as varchar) + ' MB' end as Free,
		round(vs.available_bytes/cast(vs.total_bytes as float)*100,2) as PercentFree
from sys.master_files as mf
     cross apply sys.dm_os_volume_stats(mf.database_id, mf.file_id) as vs
)
SELECT @HTML = 
	'<h2>Disk Drives </h2>
	<table>' +
	(SELECT 'Drive' th,
			'Label' th,
			'Size' th,
			'Free' th,
			'Free %' th
	FOR XML RAW('tr'),ELEMENTS) 
	+
	(SELECT drive td,
			volume_label td,
			Size td,
			Free td,
			CAST(CASE WHEN PercentFree < @PCTFreeCriticalThreshold THEN '<div class="Critical">' + CAST(PercentFree as varchar) + '</div>'
			WHEN PercentFree < @PCTFreeWarningThreshold THEN '<div class="Warning">' + CAST(PercentFree as varchar) + '</div>'
			ELSE '<div class="Healthy">' + CAST(PercentFree as varchar) + '</div>' END as XML) td
	FROM DriveInfo 
	FOR XML RAW('tr'),ELEMENTS XSINIL)
	+ '</table>'
GO
GRANT ALTER ON  [dbo].[DBAChecks_DiskDrives] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_DiskDrives] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_DiskDrives] TO [db_sp_viewer]
GO
