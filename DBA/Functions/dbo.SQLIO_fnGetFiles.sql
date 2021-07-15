SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[SQLIO_fnGetFiles] (@path [nvarchar] (4000), @searchPattern [nvarchar] (4000), @includeSubfolders [bit])
RETURNS TABLE (
[path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[file_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extension] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[directory_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_time] [datetime] NULL,
[created_time_utc] [datetime] NULL,
[modified_time] [datetime] NULL,
[modified_time_utc] [datetime] NULL,
[last_accessed_time] [datetime] NULL,
[last_accessed_time_utc] [datetime] NULL,
[file_length] [bigint] NULL,
[is_read_only] [bit] NULL)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLServerIO].[SQLServerIO.Functions].[SQLIO_fnGetFiles]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetFiles', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'Functions.vb', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetFiles', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=36
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetFiles', NULL, NULL
GO
