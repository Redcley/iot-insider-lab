SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 18 August 2016
-- Description:	Persists the passed Argonne Impression message.
--
-- Change log:
-- 31 Aug 2016  jm Added FacesForImpressions.FaceId.
--  6 Sep 2016  jm Added CampaignId to Impressions, dropped CampaignsForDevices.
-- 23 Sep 2016  jm Added checking for no faces.
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =============================================================================

ALTER PROCEDURE PersistImpression

	 @json  NVARCHAR(4000)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	-- We ignore empty parameter.
	IF @json IS NULL OR LEN(@json) = 0
		RETURN 0
	;

	-- Check whether the passed JSON is valid.
	if ISJSON(@json) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'Invalid JSON.')
		;
		RETURN -1

	END

	-- This is an often-repeated phrase:
	DECLARE @isMissing VARCHAR(50) = ' attribute or value is missing.'
	;
	-- Check whether this is an Impression message.
	DECLARE @messageType NVARCHAR(100) = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.messageType'), '')))
	;
	IF LEN(@messageType) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'messageType' + @isMissing)
		;
		RETURN -1

	END
	IF @messageType <> 'impression'
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'messageType ''' + @messageType + ''' passed to PersistImpression.')
		;
		RETURN -1

	END

	-- Impression values:
	DECLARE @deviceId       UNIQUEIDENTIFIER
	       ,@messageId      UNIQUEIDENTIFIER = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.messageId'),     '')))
	       ,@campaignId     UNIQUEIDENTIFIER = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.campaignId'),    '')))
	       ,@displayedAdId  UNIQUEIDENTIFIER = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.displayedAdId'), '')))
	       ,@timestamp      DATETIME
		   ,@testValue      VARCHAR(100)
	;

	-- Check whether the values we got are valid.
	SET @testValue = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.deviceId'), '')))
	;
	IF LEN(@testValue) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'deviceId' + @isMissing)
		;
		RETURN -1

	END

	BEGIN TRY

		SET @deviceId = @testValue

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, '''' + @testvalue + ''' is not a valid deviceId.')
		;
		RETURN -1

	END CATCH

	SET @testValue = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.messageId'), '')))
	;
	IF LEN(@testValue) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'messageId' + @isMissing)
		;
		RETURN -1

	END

	BEGIN TRY

		SET @messageId = @testValue

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, '''' + @testvalue + ''' is not a valid messageId.')
		;
		RETURN -1

	END CATCH

	SET @testValue = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.campaignId'), '')))
	;
	IF LEN(@testValue) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'campaignId' + @isMissing)
		;
		RETURN -1

	END

	BEGIN TRY

		SET @campaignId = @testValue

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, '''' + @testvalue + ''' is not a valid campaignId.')
		;
		RETURN -1

	END CATCH

	SET @testValue = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.displayedAdId'), '')))
	;
	IF LEN(@testValue) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'displayedAdId' + @isMissing)
		;
		RETURN -1

	END

	BEGIN TRY

		SET @displayedAdId = @testValue

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, '''' + @testvalue + ''' is not a valid displayedAdId.')
		;
		RETURN -1

	END CATCH

	SET @testValue = LTRIM(RTRIM(COALESCE(JSON_VALUE(@json, '$.timestamp'), '')))
	;
	IF LEN(@timestamp) = 0
	BEGIN

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'timestamp' + @isMissing)
		;
		RETURN -1

	END

	BEGIN TRY

		SET @timestamp = @testValue

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, '''' + @testvalue + ''' is not a valid timestamp.')
		;
		RETURN -1

	END CATCH

	-- We should not get from the same device messages with the same time stamp,
	-- but we do. We consider them duplicates but we log the offending device.
	IF 0 < ( SELECT COUNT(*)
	         FROM   Impressions 
			 WHERE  DeviceId = @deviceId 
			        AND 
					DeviceTimestamp = @timestamp )
	BEGIN
		
		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'Duplicate device ID and timestamp.')
		;
		RETURN 0
	
	END

	-- Values look OK and are not a duplicate - we can try to persist them.
	DECLARE @error INTEGER
	;
	BEGIN TRANSACTION

	BEGIN TRY

		INSERT INTO Impressions
		(
			 DeviceId
			,MessageId
			,CampaignId
			,DisplayedAdId
			,DeviceTimestamp
		)
		VALUES
		(
			 @deviceId
			,@messageId
			,@campaignId
			,@displayedAdId
			,@timestamp
		);

		DECLARE @impressionId BIGINT = SCOPE_IDENTITY()
		;

	END TRY
	BEGIN CATCH

		SET @error = @@ERROR
		;
		IF @error <> 0
		BEGIN

			ROLLBACK TRANSACTION
			;
			INSERT INTO ErrorLog (JSON, Error)
			VALUES (@json, 'Error ' + CAST(@error AS VARCHAR(10)) + ' on INSERT INTO Impressions.')
			;
			RETURN @error

		END

	END CATCH

	-- Get and process faces. JSON allows indexing of arrays but JSON_VALUE
	-- accepts only an explicit constant string as its second parameter, so
	-- we have to "roll our own." (Grr...)
	DECLARE @faces NVARCHAR(4000) = LTRIM(RTRIM(COALESCE(JSON_QUERY(@json, '$.faces'), '')))
	;
	IF LEN(@faces) = 0
	BEGIN

		ROLLBACK TRANSACTION
		;
		INSERT INTO ErrorLog (JSON, Error)
		VALUES (@json, 'faces' + @isMissing)
		;
		RETURN -1

	END

	SET @faces = REPLACE(@faces, '[', '')
	SET @faces = REPLACE(@faces, ']', '')
	SET @faces = LTRIM(RTRIM(@faces))
	;
	-- Check for an empty list.
	IF LEN(@faces) = 0
	BEGIN

		ROLLBACK TRANSACTION
		;
		RETURN 0

	END
	-- We will massage JSON to make for the DelimitedSplit4K function.
	-- We will make sure that there are no spaces between curly brackets.
	WHILE CHARINDEX(' {', @faces) > 0
		SET @faces = REPLACE(@faces, ' {', '{')
	;
	-- We separate faces by verical bars.
	SET @faces = REPLACE(@faces, '},{', '}|{')
	;
	-- Now we can do the split.
	DECLARE @split TABLE
	(
		 Sequence BIGINT
		,Face     NVARCHAR(1000)
	);
	INSERT INTO @split
	SELECT *
	FROM   dbo.DelimitedSplit4K(@faces, '|')
	;
	BEGIN TRY

		INSERT INTO FacesForImpressions
		(
			 ImpressionId
			,Sequence
			,FaceId
			,Age
			,Gender
			,ScoreAnger
			,ScoreContempt
			,ScoreDisgust
			,ScoreFear
			,ScoreHappiness
			,ScoreNeutral
			,ScoreSadness
			,ScoreSurprise
		)
		SELECT @impressionId
			  ,Sequence
			  ,JSON_VALUE(Face, '$.faceId')
			  ,JSON_VALUE(Face, '$.age')
			  ,JSON_VALUE(Face, '$.gender')
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.anger'))     > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.anger'),     3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.contempt'))  > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.contempt'),  3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.disgust'))   > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.disgust'),   3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.fear'))      > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.fear'),      3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.happiness')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.happiness'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.neutral'))   > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.neutral'),   3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.sadness'))   > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.sadness'),   3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.surprise'))  > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.surprise'),  3), NULL)
		FROM @split AS s

	END TRY
	BEGIN CATCH

		SET @error = @@ERROR
		;
		IF @error <> 0
		BEGIN

			ROLLBACK TRANSACTION
			;
			INSERT INTO ErrorLog (JSON, Error)
			VALUES (@json, 'Error ' + CAST(@error AS VARCHAR(10)) + ' on INSERT INTO FacesForImpressions.')
			;
			RETURN -1

		END

	END CATCH

	COMMIT TRANSACTION

	RETURN 0

END
GO
