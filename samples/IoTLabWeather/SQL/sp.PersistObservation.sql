SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 12 April 2016
-- Description:	Persists one observation for a particular location.
-- Returns:     0 if succeeded, error code if failed.
--
-- Change log:
-- 27 Apr 2016: Corrected handling of multiple sky conditions.
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE dbo.PersistObservation
	-- All parameters are passed as strings.
	@locationCode      NVARCHAR(50),
	@observedOn        NVARCHAR(50),
	@wind              NVARCHAR(50),
	@visibility        NVARCHAR(50),
	@weather           NVARCHAR(50),
	@skyConditions     NVARCHAR(50),
	@temperatureAir    NVARCHAR(50),
	@dewpoint          NVARCHAR(50),
	@relativeHumidity  NVARCHAR(50),
	@windChill         NVARCHAR(50),
	@heatIndex         NVARCHAR(50),
	@pressureAltimeter NVARCHAR(50),
	@pressureSeaLevel  NVARCHAR(50),
	@precipitation1hr  NVARCHAR(50),
	@precipitation3hr  NVARCHAR(50),
	@precipitation6hr  NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ASSUMPTION -------------------------------------------------------
	-- NAs are passed as empty strings and all passed values are trimmed.
	-- ------------------------------------------------------------------

	-- Find whether we already have this observation.
	DECLARE @observedDate DATETIME = CONVERT(DATETIME, @observedOn)
	;
	IF (SELECT 
			COUNT (*)
		FROM
			Observations
		WHERE
			LocationCode = @locationCode
			AND
			ObservedOn = @observedDate )
		> 0
	BEGIN
		SELECT 0;  -- not having to insert is a success
		RETURN
	END

	-- We do not have this observation - we have to persist it.
	-- Get the new ID.
	DECLARE @id BIGINT = COALESCE(
		(SELECT MAX(ObservationId) FROM Observations),
		-1 ) + 1 -- this starts the sequence from 0
	;

	-- Relative humidity includes a percent sign which we do not want.
	SET @relativeHumidity = REPLACE(@relativeHumidity, '%', '')
	;

	BEGIN TRY

		-- First the observation.
		INSERT INTO Observations
			(ObservationId
			,LocationCode
			,ObservedOn
			,Wind
			,Visibility
			,Weather
			,TemperatureAir
			,Dewpoint
			,RelativeHumidity
			,WindChill
			,HeatIndex
			,PressureAltimeter
			,PressureSeaLevel
			,Precipitation1hr
			,Precipitation3hr
			,Precipitation6hr)
		VALUES
			(@id
			,@locationCode
			,@observedOn
			,@wind
			,IIF(LEN(@visibility) = 0,        NULL, @visibility)
			,@weather
			,IIF(LEN(@temperatureAir) = 0,    NULL, @temperatureAir)
			,IIF(LEN(@dewpoint) = 0,          NULL, @dewpoint)
			,IIF(LEN(@relativeHumidity) = 0,  NULL, @relativeHumidity)
			,IIF(LEN(@windChill) = 0,         NULL, @windChill)
			,IIF(LEN(@heatIndex) = 0,         NULL, @heatIndex)
			,IIF(LEN(@pressureAltimeter) = 0, NULL, @pressureAltimeter)
			,IIF(LEN(@pressureSeaLevel) = 0,  NULL, @pressureSeaLevel)
			,IIF(LEN(@precipitation1hr) = 0,  NULL, @precipitation1hr)
			,IIF(LEN(@precipitation3hr) = 0,  NULL, @precipitation3hr )
			,IIF(LEN(@precipitation6hr) = 0,  NULL, @precipitation6hr) )
		;
		-- Now the conditions.
		WHILE LEN(@skyConditions) > 0
		BEGIN

			-- We know that conditions are 6 characters long and are
			-- separated by spaces.
			INSERT INTO SkyConditions
				(ObservationId
				,SkyCondition)
			VALUES
				(@id
				,SUBSTRING(@skyConditions, 1, 6))
			;
			-- Prepare the next token for the next pass; if this was the last one, we wipe it out.
			SET @skyConditions = IIF(LEN(@skyConditions) < 8, '', SUBSTRING(@skyConditions, 8, LEN(@skyConditions) - 7))
			;
		END

		SELECT 0
	END TRY
	BEGIN CATCH

		SELECT @@ERROR
	
	END CATCH
END
GO
