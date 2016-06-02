USE [IoTLabWeather]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 4 May 2016
-- Description:	Reduced set of observations: mostly-null cols dropped.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ===================================================================
ALTER VIEW [dbo].[ReducedObservations]
AS
	SELECT TOP 10000000
		 Location
		,ObservedOn
		,Visibility
		,Weather
		,SkyConditionsCleansed AS SkyConditions
		,TemperatureAir
		,Dewpoint
		,RelativeHumidity
		,PressureAltimeter
		,REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE (SkyConditionsCleansed, 
		 '0', ''),
         '1', ''),
         '2', ''),
         '3', ''),
         '4', ''),
         '5', ''),
         '6', ''),
         '7', ''),
         '8', ''),
         '9', '') AS Descriptors
	FROM
		Observations o
		INNER JOIN Locations l
		        ON l.LocationCode = o.LocationCode
	ORDER BY
		 Location
		,ObservedOn
GO


