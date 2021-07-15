SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[SQLIO_CreateTextFile] (@path [nvarchar] (4000), @value [nvarchar] (max))
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [SQLServerIO].[SQLServerIO.StoredProcedures].[SQLIO_CreateTextFile]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_CreateTextFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'StoredProcedures.vb', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_CreateTextFile', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=66
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_CreateTextFile', NULL, NULL
GO
