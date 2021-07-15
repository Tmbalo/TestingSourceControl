SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[SQLIO_MoveFile] (@source [nvarchar] (4000), @destination [nvarchar] (4000))
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [SQLServerIO].[SQLServerIO.StoredProcedures].[SQLIO_MoveFile]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_MoveFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'StoredProcedures.vb', 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_MoveFile', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=76
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'SQLIO_MoveFile', NULL, NULL
GO
