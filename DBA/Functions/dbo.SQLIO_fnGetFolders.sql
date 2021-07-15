SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[SQLIO_fnGetFolders] (@path [nvarchar] (4000), @searchPattern [nvarchar] (4000), @includeSubFolders [bit])
RETURNS TABLE (
[path] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_time] [datetime] NULL,
[created_time_utc] [datetime] NULL,
[last_accessed_time] [datetime] NULL,
[last_accessed_time_utc] [datetime] NULL)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLServerIO].[SQLServerIO.Functions].[SQLIO_fnGetFolders]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetFolders', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'Functions.vb', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetFolders', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=67
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetFolders', NULL, NULL
GO
