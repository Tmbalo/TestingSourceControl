SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_DiskDrives2](@PCTFreeWarningThreshold2 int,@PCTFreeCriticalThreshold2 int,@HTML varchar(max) out)
AS
/* 
	Returns HTML for "Disk Drives" section of DBA Checks Report
*/ 
DECLARE @BytesToTB float,@BytesToGB float,@BytesToMB float
SELECT @BytesToTB =  1099511627776,@BytesToGB = 1073741824,@BytesToMB=1048576.0;

WITH DriveInfo AS (
	SELECT drive,
		volume_label,
		CASE WHEN total_size > @BytesToTB THEN CAST(ROUND(total_size /@BytesToTB,1) as varchar) + 'TB'
			WHEN total_size > @BytesToGB THEN CAST(ROUND(total_size /@BytesToGB,1) as varchar) + 'GB'
			ELSE CAST(ROUND(total_size / @BytesToMB,1) as varchar) + 'MB' END as Size,
		CASE WHEN free_space > @BytesToTB THEN CAST(ROUND(free_space /@BytesToTB,1) as varchar) + 'TB'
			WHEN free_space > @BytesToGB THEN CAST(ROUND(free_space /@BytesToGB,1) as varchar) + 'GB'
			ELSE CAST(ROUND(free_space / @BytesToMB,1) as varchar) + 'MB' END as Free,
		ROUND(free_space/cast(total_size as float)*100,2) as PercentFree
	FROM dbo.SQLIO_fnGetDrives()
	WHERE drive_type=3 --Fixed
)
SELECT @HTML = 
	'<h2>Disk Drives 2</h2>
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
			CAST(CASE WHEN PercentFree < @PCTFreeCriticalThreshold2 THEN '<div class="Critical">' + CAST(PercentFree as varchar) + '</div>'
			WHEN PercentFree < @PCTFreeWarningThreshold2 THEN '<div class="Warning">' + CAST(PercentFree as varchar) + '</div>'
			ELSE '<div class="Healthy">' + CAST(PercentFree as varchar) + '</div>' END as XML) td
	FROM DriveInfo 
	FOR XML RAW('tr'),ELEMENTS XSINIL)
	+ '</table>'
GO
GRANT ALTER ON  [dbo].[DBAChecks_DiskDrives2] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_DiskDrives2] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_DiskDrives2] TO [db_sp_viewer]
GO
