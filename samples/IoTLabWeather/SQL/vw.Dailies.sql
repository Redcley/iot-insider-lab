USE [IoTLabWeather]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 4 May 2016
-- Description:	Measured values, averaged per day.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER VIEW [dbo].[Dailies]
AS
	SELECT TOP 10000000
		 LocationCode
		,CAST(CONVERT(char(11), ObservedOn, 113) AS DATETIME) AS ObservedDate
		,ROUND(AVG(Visibility), 1) AS AverageVisibility
		,ROUND(AVG(TemperatureAir), 1) AS AverageTemperature
		,ROUND(AVG(Dewpoint), 1) AS AverageDewpoint
		,ROUND(AVG(RelativeHumidity / 100), 3) AS AverageHumidity
	FROM
		Observations
	GROUP BY
		 LocationCode
		,CAST(CONVERT(char(11), ObservedOn, 113) AS DATETIME)
	ORDER BY
		 LocationCode
		,CAST(CONVERT(char(11), ObservedOn, 113) AS DATETIME)
GO


