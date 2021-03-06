USE [IoTLabWeather]
GO
/****** Object:  StoredProcedure [dbo].[PersistObservation]    Script Date: 4/12/2016 10:54:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 12 March 2016
-- Description:	Persists one observation for a particular location.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[PersistObservation]
	-- All parameters are passed as strings.
	@locationCode      NVARCHAR(50),
	@observedOn        NVARCHAR(50),
	@wind              NVARCHAR(50),
	@visibility        NVARCHAR(50),
	@weather           NVARCHAR(50),
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
	return -999

	IF EXISTS (
		SELECT 
			COUNT (*)
		FROM
			Observations
		WHERE
			LocationCode = @locationCode
			AND
			ObservedOn = @observedDate )
		RETURN 0;  -- success

	-- We do not have it - we have to persist it.
	-- Get the new ID.
	DECLARE @id BIGINT = COALESCE(
		(SELECT MAX(ObservationId) FROM Observations),
		-1 ) + 1 -- this starts the sequence from 0
	;

	RETURN -1

    -- Test only:
	RETURN 0
END
