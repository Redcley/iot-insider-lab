SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 31 May 2016
-- Description:	Calculates and persists 10 minute averages of environmental values.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ================================================================================
ALTER PROCEDURE [dbo].[CalculateEnvironment10MinuteAvgs]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering
	-- with SELECT statements.
	SET NOCOUNT ON;

	-- We do not need old data.
	DELETE Environment10MinuteAvgs
	WHERE  Interval < DATEADD( d, -1, GETUTCDATE() )
	;
	BEGIN TRY

		WITH cte
			( DeviceId
			 ,Interval
			 ,AvgHumidity
			 ,AvgPressure
			 ,AvgTemperature )
		AS
		(
			SELECT TOP 100000000  -- overkill
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
		)
		MERGE Environment10MinuteAvgs AS t
		USING cte
		ON ( t.DeviceId = cte.DeviceId
			 AND
			 t.Interval = cte.Interval ) 

		WHEN NOT MATCHED BY TARGET
		THEN 
			INSERT ( DeviceId
					,Interval
					,AvgHumidity
					,AvgPressure
					,AvgTemperature )
			VALUES ( cte.DeviceId
					,cte.Interval
					,cte.AvgHumidity
					,cte.AvgPressure
					,cte.AvgTemperature )

		WHEN MATCHED 
		THEN 
			UPDATE SET t.AvgHumidity    = cte.AvgHumidity
					  ,t.AvgPressure    = cte.AvgPressure
					  ,t.AvgTemperature = cte.AvgTemperature
		;
		RETURN 0
	
	END TRY
	BEGIN CATCH

		RETURN @@ERROR

	END CATCH

END
