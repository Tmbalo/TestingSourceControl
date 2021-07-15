SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_DiskWriteIO_sec]
AS
SELECT 
    CounterName, 
    InstanceName, 
    CounterValue, 
   CAST(LEFT(CounterDateTime, CHARINDEX('.', CounterDateTime) -1) AS datetime) AS Date
   
FROM dbo.CounterDetails CDetails
    INNER JOIN dbo.CounterData CData ON CData.CounterID = CDetails.CounterID
    INNER JOIN DisplayToID DToID ON DToID.GUID = CData.GUID
WHERE ObjectName = 'MSSQL$INST_SQL_BIOL01:Resource Pool Stats' AND 
   CDetails.CounterName = 'Disk Write IO/sec' AND CounterValue <> 0
--WHERE CDetails.CounterName = 'Disk Read IO/sec'
--ORDER BY CounterDateTime;
GO
