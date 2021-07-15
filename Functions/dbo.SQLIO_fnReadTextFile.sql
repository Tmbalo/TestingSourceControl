SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[SQLIO_fnReadTextFile] (@path [nvarchar] (4000))
RETURNS [nvarchar] (max)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLServerIO].[SQLServerIO.Functions].[SQLIO_fnReadTextFile]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnReadTextFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'Functions.vb', 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnReadTextFile', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=102
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'SQLIO_fnReadTextFile', NULL, NULL
GO
