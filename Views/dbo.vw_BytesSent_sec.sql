SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_BytesSent_sec]
as
SELECT  
    CounterName, 
    InstanceName, 
  try_cast(  TRY_CAST(FORMAT(round((CounterValue) / 1048576.0, 2,1), 'n2') AS decimal(5,2)) as int) AS 'ValueMB' , 
	--COUNTERVALUE  ,
   CAST(LEFT(CounterDateTime, CHARINDEX('.', CounterDateTime) -1) AS datetime) AS Date
--into network_1
FROM dbo.CounterDetails CDetails
    INNER JOIN dbo.CounterData CData ON CData.CounterID = CDetails.CounterID
    INNER JOIN DisplayToID DToID ON DToID.GUID = CData.GUID
WHERE ObjectName = 'Network Interface' AND 
    CDetails.CounterName = 'Bytes Sent/sec' AND CounterValue <> 0
--WHERE CDetails.CounterName = 'Disk Read IO/sec'
--ORDER BY CounterDateTime;
GO
