SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_get_restore_status](@HTML varchar(max) out)
as

set nocount on;

with lastrestores as
(
select
    databasename = [d].[name] ,
    r.restore_date,
    rownum = row_number() over (partition by d.name order by r.[restore_date] desc)
	from master.sys.databases d
left outer join msdb.dbo.[restorehistory] r on r.[destination_database_name] = d.name

)
select 
		databasename, 
		restore_date,
		--case when cast(restore_date as date) >= '2021-02-06' then 'Restored'
		case when cast(restore_date as date) >= cast(getdate() as date) then 'Restored'
		else 'Not-Restored'
		end 'RestoreStatus'
into 
		#restore

from 
		[lastrestores] lr
inner join 
		dba.dbo.alm_refresh_databases d
on
		lr.databasename = d.database_name
where 
		[rownum] = 1 

		
		

select @HTML = 
	'<h2>Restore Status</h2>
	<table>' +
	(select 'Database Name' th,
			'Restore date' th,
			'Restore status' th			
	for xml raw('tr'),elements) 
	+
	(select DatabaseName td,
		restore_date td,
	
	cast(case when RestoreStatus = 'Not-Restored' then '<div class="Critical">' + RestoreStatus + '</div>'
			else '<div class="Healthy">' + RestoreStatus + '</div>' END as XML) td
			
from #restore
order by DatabaseName 
	for xml raw('tr'),elements xsinil)
	+ '</table>'

drop table #restore
GO
GRANT ALTER ON  [dbo].[usp_get_restore_status] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[usp_get_restore_status] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[usp_get_restore_status] TO [db_sp_viewer]
GO
