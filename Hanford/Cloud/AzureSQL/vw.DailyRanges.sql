SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 12 May 2016
-- Description:	Extremes of measured values, since 7 AM.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER VIEW [dbo].[DailyRanges]
AS

	SELECT DeviceId
	      ,[Min humidity]
		  ,( SELECT TOP 1
		            dbo.UtcToLocal(UtcStamp)
		     FROM   [Messages] mm
			        INNER JOIN Environments ee
						   ON ee.MessageId = mm.MessageId
			 WHERE  mm.DeviceId = s.DeviceId
			        AND
			        dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
					AND
					ee.Humidity = ( SELECT MIN(Humidity) 
					                FROM   [Messages] mmm INNER JOIN Environments eee on eee.MessageId = mmm.MessageId
									WHERE  mmm.DeviceId = mm.DeviceId AND dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' ) ) ) AS [Min humidity time]
	      ,[Max humidity]
		  ,( SELECT TOP 1
		            dbo.UtcToLocal(UtcStamp)
		     FROM   [Messages] mm
			        INNER JOIN Environments ee
						   ON ee.MessageId = mm.MessageId
			 WHERE  mm.DeviceId = s.DeviceId
			        AND
			        dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
					AND
					ee.Humidity = ( SELECT MAX(Humidity) 
					                FROM   [Messages] mmm INNER JOIN Environments eee on eee.MessageId = mmm.MessageId
									WHERE  mmm.DeviceId = mm.DeviceId AND dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' ) ) ) AS [Max humidity time]
		  ,[Min pressure]
		  ,( SELECT TOP 1
		            dbo.UtcToLocal(UtcStamp)
		     FROM   [Messages] mm
			        INNER JOIN Environments ee
						   ON ee.MessageId = mm.MessageId
			 WHERE  mm.DeviceId = s.DeviceId
			        AND
			        dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
					AND
					ee.Pressure = ( SELECT MIN(Pressure) 
					                FROM   [Messages] mmm INNER JOIN Environments eee on eee.MessageId = mmm.MessageId
									WHERE  mmm.DeviceId = mm.DeviceId AND dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' ) ) ) AS [Min pressure time]
		  ,[Max pressure]
		  ,( SELECT TOP 1
		            dbo.UtcToLocal(UtcStamp)
		     FROM   [Messages] mm
			        INNER JOIN Environments ee
						   ON ee.MessageId = mm.MessageId
			 WHERE  mm.DeviceId = s.DeviceId
			        AND
			        dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
					AND
					ee.Pressure = ( SELECT MAX(Pressure) 
					                FROM   [Messages] mmm INNER JOIN Environments eee on eee.MessageId = mmm.MessageId
									WHERE  mmm.DeviceId = mm.DeviceId AND dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' ) ) ) AS [Max pressure time]
		  ,[Min temperature]
		  ,( SELECT TOP 1
		            dbo.UtcToLocal(UtcStamp)
		     FROM   [Messages] mm
			        INNER JOIN Environments ee
						   ON ee.MessageId = mm.MessageId
			 WHERE  mm.DeviceId = s.DeviceId
			        AND
			        dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
					AND
					ee.Temperature = ( SELECT MIN(Temperature) 
					                   FROM   [Messages] mmm INNER JOIN Environments eee on eee.MessageId = mmm.MessageId
									   WHERE  mmm.DeviceId = mm.DeviceId AND dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' ) ) ) AS [Min temp time]
		  ,[Max temperature]
		  ,( SELECT TOP 1
		            dbo.UtcToLocal(UtcStamp)
		     FROM   [Messages] mm
			        INNER JOIN Environments ee
						   ON ee.MessageId = mm.MessageId
			 WHERE  mm.DeviceId = s.DeviceId
			        AND
			        dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
					AND
					ee.Temperature = ( SELECT MAX(Temperature) 
					                   FROM   [Messages] mmm INNER JOIN Environments eee on eee.MessageId = mmm.MessageId
									   WHERE  mmm.DeviceId = mm.DeviceId AND dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' ) ) ) AS [Max temp time]
	FROM   ( SELECT TOP 1000000
				    DeviceId
				   ,MIN(Humidity) AS [Min humidity]
				   ,MAX(Humidity) AS [Max humidity]
				   ,MIN(Pressure) AS [Min pressure]
				   ,MAX(Pressure) AS [Max pressure]
				   ,MIN(Temperature) AS [Min temperature]
				   ,MAX(Temperature) AS [Max temperature]
			 FROM [Messages] m
			  	  INNER JOIN Environments e
						  ON e.MessageId = m.MessageId
			 WHERE dbo.UtcToLocal(UtcStamp) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
			 GROUP BY DeviceId
			 ORDER BY DeviceId ) AS s
GO


