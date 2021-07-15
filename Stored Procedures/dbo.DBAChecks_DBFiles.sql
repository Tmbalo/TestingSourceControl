SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DBAChecks_DBFiles](
	@IncludeDBs varchar(max)=NULL,
	@ExcludeDBs varchar(max)='master,model,msdb,tempdb',
	@WarningThresholdPCT int=90,
	@CriticalThresholdPCT int=95,
	@HTML varchar(max) output
)
AS
/* 
	Returns HTML for "Database Files" section of DBA Checks Report
*/ 
CREATE TABLE #FileStats(
	[db] sysname not null,
	[name] [sysname] not null,
	[file_group] [sysname] null,
	[physical_name] [nvarchar](260) NOT NULL,
	[type_desc] [nvarchar](60) NOT NULL,
	[size] [varchar](33) NOT NULL,
	[space_used] [varchar](33)  NULL,
	[free_space] [varchar](33)  NULL,
	[pct_used] [float]  NULL,
	[max_size] [varchar](33) NOT NULL,
	[growth] [varchar](33) NOT NULL
) 
DECLARE @IncludeXML XML
DECLARE @ExcludeXML XML
DECLARE @DB sysname

IF @IncludeDBs = ''
BEGIN
	SET @HTML = ''
	DROP TABLE #FileStats
	RETURN
END

SELECT @IncludeXML = '<a>' + REPLACE(@IncludeDBs,',','</a><a>') + '</a>'
SELECT @ExcludeXML = '<a>' + REPLACE(@ExcludeDBs,',','</a><a>') + '</a>'

DECLARE cDBs CURSOR FOR
			SELECT name FROM sys.databases
			WHERE (name IN(SELECT n.value('.','sysname')
						FROM @IncludeXML.nodes('/a') T(n))
						OR @IncludeXML IS NULL)
				AND (name NOT IN(SELECT n.value('.','sysname')
						FROM @ExcludeXML.nodes('/a') T(n))
						OR @ExcludeXML IS NULL)
			AND source_database_id IS NULL
			AND state = 0 --ONLINE
			ORDER BY name
			
OPEN cDBs
FETCH NEXT FROM cDBs INTO @DB
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @SQL nvarchar(max)
	SET @SQL =		 N'USE ' + QUOTENAME(@DB) + ';
					INSERT INTO #FileStats(db,name,file_group,physical_name,type_desc,size,space_used,free_space,[pct_used],max_size,growth)
					select DB_NAME() db,
					f.name,
					fg.name as file_group,
					f.physical_name,
					f.type_desc,
					CASE WHEN (f.size/128) < 1024 THEN CAST(f.size/128 as varchar) + '' MB'' 
						ELSE CAST(CAST(ROUND(f.size/(128*1024.0),1) as float) as varchar) + '' GB'' 
						END as size,
					CASE WHEN FILEPROPERTY(f.name,''spaceused'')/128 < 1024 THEN CAST(FILEPROPERTY(f.name,''spaceused'')/128 as varchar) + '' MB''
						ELSE CAST(CAST(ROUND(FILEPROPERTY(f.name,''spaceused'')/(128*1024.0),1) as float) as varchar) + '' GB'' 
						END space_used,
					CASE WHEN (f.size - FILEPROPERTY(f.name,''spaceused''))/128 < 1024 THEN CAST((f.size - FILEPROPERTY(f.name,''spaceused''))/128 as varchar) + '' MB''
						ELSE CAST(CAST(ROUND((f.size - FILEPROPERTY(f.name,''spaceused''))/(128*1024.0),1) as float) as varchar) + '' GB''
						END free_space,
					ROUND((FILEPROPERTY(f.name,''spaceused''))/CAST(size as float)*100,2) as [pct_used],
					CASE WHEN f.max_size =-1 THEN ''unlimited'' 
						WHEN f.max_size/128 < 1024 THEN CAST(f.max_size/128 as varchar) + '' MB'' 
						ELSE CAST(f.max_size/(128*1024) as varchar) + '' GB''
						END as max_size,
					CASE WHEN f.is_percent_growth=1 THEN CAST(f.growth as varchar) + ''%''
						WHEN f.growth = 0 THEN ''none''
						WHEN f.growth/128 < 1024 THEN CAST(f.growth/128 as varchar) + '' MB'' 
						ELSE CAST(CAST(ROUND(f.growth/(128*1024.0),1) as float) as varchar) + '' GB''
						END growth
					from sys.database_files f
					LEFT JOIN sys.filegroups fg on f.data_space_id = fg.data_space_id
					where f.type_desc <> ''FULLTEXT'''
	exec sp_executesql @SQL	
					
	FETCH NEXT FROM cDBs INTO @DB
END
CLOSE cDBs
DEALLOCATE cDBs

SELECT @HTML = '<h2>Database Files</h2><table>' + 
		(SELECT 'Database' th,
		'Name' th,
		'File Group' th,
		'File Path' th,
		'Type' th,
		'Size' th,
		'Used' th,
		'Free' th,
		'Used %' th,
		'Max Size' th,
		'Growth' th
		FOR XML RAW('tr'),ELEMENTS ) +		
		(SELECT db td,
					name td,
					file_group td,
					physical_name td,
					type_desc td,
					size td,
					space_used td,
					free_space td,
					CAST(CASE WHEN pct_used > @CriticalThresholdPCT 
						THEN '<div class="Critical">' + CAST(pct_used as varchar) + '</div>'
						WHEN pct_used > @WarningThresholdPCT  
						THEN '<div class="Warning">' + CAST(pct_used as varchar) + '</div>'
						ELSE '<div class="Healthy">' + CAST(pct_used as varchar) + '</div>'
						END as XML) td,
					max_size td,
					CAST(CASE WHEN growth='none' THEN '<div class="Warning">' + growth + '</div>'
					ELSE growth END as XML) td
				FROM #FileStats
				ORDER BY db,type_desc DESC,file_group,name
				FOR XML RAW('tr'),ELEMENTS XSINIL) + '</table>'
				
DROP TABLE #FileStats
GO
GRANT ALTER ON  [dbo].[DBAChecks_DBFiles] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[DBAChecks_DBFiles] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[DBAChecks_DBFiles] TO [db_sp_viewer]
GO
