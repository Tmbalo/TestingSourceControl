/****** Object:  Procedure [dbo].[usp_get_results]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE proc [dbo].[usp_get_results]
as
select 
	top 100 * 
from 
	dbo.snp500_update