SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_get_us30]
as
select 
	top 1000 *
from
	dbo.US30_H1_history
GO
