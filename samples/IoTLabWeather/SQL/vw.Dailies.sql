USE [IoTLabWeather]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[Dailies]
AS
	SELECT TOP 100000
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


