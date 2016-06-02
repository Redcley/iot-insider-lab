SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 17 May 2016
-- Description:	Window of the last 5 minutes.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER VIEW [dbo].[FiveMinutesDetail]
AS

	SELECT TOP 100000000
		   DeviceId
		  ,UtcStamp
	      ,CAST( ROUND(Humidity,1)    AS DECIMAL (4,1) ) AS Humidity
		  ,CAST( ROUND(Pressure,1)    AS DECIMAL (8,1) ) AS Pressure
		  ,CAST( ROUND(Temperature,1) AS DECIMAL (4,1) ) AS Temperature
	FROM [Messages] m
	     INNER JOIN Environments e
	             ON e.MessageId = m.MessageId
	WHERE UtcStamp >= DATEADD( s, -300, GETUTCDATE() )
	ORDER BY DeviceId, UtcStamp

GO