SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 12 May 2016
-- Description:	10-minute aggregations of the measured values.
--
-- Change log:
-- 19 May 2016  jm Performance review - comparing straight UTC stamp.
-- 23 May 2016  jm Window extended to 24 hours.
--                 PST/PDT no longer a concern.
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================
ALTER VIEW [dbo].[TenMinutes]
AS
	SELECT TOP 100000000
		   DeviceId
		  ,CAST(SUBSTRING(FORMAT(UtcStamp,'yyyy-MM-ddTHH:mm'),1,15) + '0:00' AS DATETIME) AS Interval
		  ,AVG(Humidity) AS [Avg humidity]
		  ,AVG(Pressure) AS [Avg pressure]
		  ,AVG(Temperature) AS [Avg temperature]
	FROM [Messages] m
	     INNER JOIN Environments e
	             ON e.MessageId = m.MessageId
	WHERE UtcStamp >= DATEADD( d, -1, GETUTCDATE() )
	GROUP BY DeviceId, CAST(SUBSTRING(FORMAT(UtcStamp,'yyyy-MM-ddTHH:mm'),1,15) + '0:00' AS DATETIME)
	ORDER BY DeviceId, CAST(SUBSTRING(FORMAT(UtcStamp,'yyyy-MM-ddTHH:mm'),1,15) + '0:00' AS DATETIME)
GO