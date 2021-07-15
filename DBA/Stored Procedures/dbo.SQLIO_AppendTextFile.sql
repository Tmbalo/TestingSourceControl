SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[SQLIO_AppendTextFile] (@path [nvarchar] (4000), @value [nvarchar] (max))
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [SQLServerIO].[SQLServerIO.StoredProcedures].[SQLIO_AppendTextFile]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_AppendTextFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'StoredProcedures.vb', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_AppendTextFile', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=71
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_AppendTextFile', NULL, NULL
GO
