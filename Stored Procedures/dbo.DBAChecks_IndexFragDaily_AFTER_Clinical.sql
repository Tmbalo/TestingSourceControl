SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_IndexFragDaily_AFTER_Clinical](@HTML varchar(max) out)
AS
/* 
	Returns HTML for "ErrorLog.htm" attachment of DBA Checks Report
*/ 
SET NOCOUNT ON
CREATE TABLE #dbindex (DatabaseName nvarchar(250), TableName nvarchar(500), IndexName nvarchar(550), IndexType nvarchar(200), avg_fragmentation_in_percentage decimal, page_count int)

insert into #dbindex
EXECUTE master.sys.sp_MSforeachdb 'USE [?]
IF ''?'' = ''Clinical'' 

BEGIN



SELECT top 10 
ISNULL(DB_Name(indexstats.database_id), ''UNKNOWN'') AS DatabaseName
, ISNULL(OBJECT_NAME(ind.OBJECT_ID), ''UNKNOWN'') AS TableName 
,ISNULL(ind.name, ''UKNOWN'') AS IndexName
, ISNULL(indexstats.index_type_desc, ''UNKNOWN'') AS IndexType 
,ISNULL(indexstats.avg_fragmentation_in_percent, 0)
,ISNULL(page_count, 0)
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind  
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE indexstats.avg_fragmentation_in_percent > 5 and  indexstats.index_type_desc not in (''HEAP'')
ORDER BY indexstats.avg_fragmentation_in_percent DESC

END'



SELECT @HTML = 
	'<h2>Index Fragmentation After</h2>
	<table>' +
	(SELECT 'Database Name' th,
			'Table Name' th,
			'Index Name' th,
			'Index Type' th,
			'Avg Fragmentation %' th,
			'Page Count' th
			
	FOR XML RAW('tr'),ELEMENTS) 
	+
	(SELECT DatabaseName td,
		TableName td,
		IndexName td,
		IndexType td,
	CAST(CASE WHEN avg_fragmentation_in_percentage > 30 THEN '<div class="Critical">' + CAST(avg_fragmentation_in_percentage as varchar) + '</div>'
			WHEN avg_fragmentation_in_percentage BETWEEN 5 AND 29 THEN '<div class="Warning">' + CAST(avg_fragmentation_in_percentage as varchar) + '</div>'
			ELSE '<div class="Healthy">' + CAST(avg_fragmentation_in_percentage as varchar) + '</div>' END as XML) td,
			page_count td
FROM #dbindex
WHERE IndexName is not null and avg_fragmentation_in_percentage > 0 and page_count > 1000
ORDER BY avg_fragmentation_in_percentage DESC
	FOR XML RAW('tr'),ELEMENTS XSINIL)
	+ '</table>'

DROP TABLE #dbindex
GO
GRANT ALTER ON  [dbo].[DBAChecks_IndexFragDaily_AFTER_Clinical] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_IndexFragDaily_AFTER_Clinical] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_IndexFragDaily_AFTER_Clinical] TO [db_sp_viewer]
GO
