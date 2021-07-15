SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[SQLIO_DeleteFilesOlderThan] (@path [nvarchar] (4000), @searchPattern [nvarchar] (4000), @includeSubFolders [bit], @maxAge [datetime])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [SQLServerIO].[SQLServerIO.StoredProcedures].[SQLIO_DeleteFilesOlderThan]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_DeleteFilesOlderThan', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'StoredProcedures.vb', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_DeleteFilesOlderThan', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=42
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_DeleteFilesOlderThan', NULL, NULL
GO
