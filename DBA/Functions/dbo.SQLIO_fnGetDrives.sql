SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[SQLIO_fnGetDrives] ()
RETURNS TABLE (
[drive] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[volume_label] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drive_type] [int] NULL,
[drive_type_desc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drive_format] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_size] [bigint] NULL,
[free_space] [bigint] NULL)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLServerIO].[SQLServerIO.Functions].[SQLIO_fnGetDrives]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetDrives', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'Functions.vb', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetDrives', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=15
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnGetDrives', NULL, NULL
GO
