SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[SQLIO_fnReadFile] (@path [nvarchar] (4000))
RETURNS [varbinary] (max)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLServerIO].[SQLServerIO.Functions].[SQLIO_fnReadFile]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnReadFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'Functions.vb', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnReadFile', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=97
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnReadFile', NULL, NULL
GO
