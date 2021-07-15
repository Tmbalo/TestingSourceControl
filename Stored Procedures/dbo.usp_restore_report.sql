SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[usp_restore_report](

	
	/* Email/Profile params */
	@recipients nvarchar(max), -- email list
	@mailprofile sysname=null
)
as

set nocount on

declare @html varchar(max)
declare @restore varchar(max)



exec usp_get_restore_status @html = @restore out




set @HTML = 
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

'
 
+ COALESCE(@restore,'<div class="Critical">Error collecting restore Info</div>')

+ '</body></html>'


declare @subject varchar(50)
set @subject = 'Restore Status on (' + @@SERVERNAME + ')'


exec msdb.dbo.sp_send_dbmail
	
	@attach_query_result_as_file = 0,
	@query_result_header = 0,
	@query_no_truncate = 0,
	--@query_result_width=32767,
	@recipients =@Recipients,
	@body = @HTML,
	@body_format ='HTML',
	@subject = @subject,
	@profile_name = @MailProfile
GO
GRANT ALTER ON  [dbo].[usp_restore_report] TO [db_sp_alter]
GO
GRANT EXECUTE ON  [dbo].[usp_restore_report] TO [db_sp_executor]
GO
GRANT VIEW DEFINITION ON  [dbo].[usp_restore_report] TO [db_sp_viewer]
GO
