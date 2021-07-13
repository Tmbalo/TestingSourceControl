SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_get_results]
as
select 
	top 10 * 
from 
	dbo.snp500_update
GO
