SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[EmailCss_Get]()
RETURNS nvarchar(max)
AS
/*************************************************************************************************
AUTHOR: Andy Mallon
CREATED: 20141001
    This function returns a <style> tag for use in generating formatted HTML emails.
PARAMETERS
* None
**************************************************************************************************
MODIFICATIONS:
    YYYYMMDDD - Initials - Description of changes
**************************************************************************************************
    This code is licensed as part of Andy Mallon's DBA Database.
    https://github.com/amtwo/dba-database/blob/master/LICENSE
    ©2014-2020 ● Andy Mallon ● am2.co
*************************************************************************************************/
BEGIN
    DECLARE @Style nvarchar(max),
            --Use variables for font-family & colors
            --Makes it easier to update them later
            @FontFamily nvarchar(200) = '''Segoe UI'',''Arial'',''Helvetica''',
            @ColorBoldText nvarchar(7) = '#032E57',
            @ColorAlertText nvarchar(7) = '#DC080A',
            @ColorBackground nvarchar(7) = '#D0CAC4',
            @ColorBackground2 nvarchar(7) = '#E4F1FE',
            @ColorBackgroundAlert nvarchar(7) = '#FEF1E4';
    
    
    SET @Style = N'<style>
      body {font-family:' + @FontFamily + '; 
            font-size:''12px''}
      p    {font-family:' + @FontFamily + '; 
            font-size:''12px''}
      div  {font-family:' + @FontFamily + '; 
            font-size:''12px''}
      h1   {color:' + @ColorBoldText + ';
            font-family:' + @FontFamily + '; 
            font-size:''24px''}
      h2   {color:' + @ColorBoldText + ';
            font-family:' + @FontFamily + '; 
            font-size:''18px''}
      h3   {color:' + @ColorBoldText + ';
            font-family:' + @FontFamily + '; 
            font-size:''14px''}
      table,th,td {font-family:' + @FontFamily + ';
                   font-size:''12px'';padding-right: 5px;
          padding-left: 5px;
          border-bottom: thin solid ' + @ColorBoldText + ';}
      tr:nth-child(even) {background-color:' + @ColorBackground2 + '}
      th   {background-color:' + @ColorBackground + ';
            font-size:''13px''}
      .alert    {color: ' + @ColorAlertText + '}
      .alertbg  {color: ' + @ColorAlertText + ';
                font-weight: bold;
                background-color:' + @ColorBackgroundAlert + ' 
</style>';
    RETURN(@Style);
END;
GO
GRANT EXECUTE ON  [dbo].[EmailCss_Get] TO [db_scalar_fn]
GO
