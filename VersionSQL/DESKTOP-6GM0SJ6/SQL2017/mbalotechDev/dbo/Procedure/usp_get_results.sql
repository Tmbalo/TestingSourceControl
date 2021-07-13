/****** Object:  Procedure [dbo].[usp_get_results]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE proc usp_get_results
as
select top 10 * from dbo.snp500_update