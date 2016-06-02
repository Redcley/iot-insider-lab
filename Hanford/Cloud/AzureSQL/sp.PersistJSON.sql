SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 28 April 2016
-- Description:	Persists a passed Hanford JSON message.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[PersistJSON]

	 @message  NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- We log the message whether it is OK or not.
	-- We will delete it later if there is no error.
	INSERT INTO ErrorLog (Message) Values (@message)
	;
	-- Our app-specific error codes:
	DECLARE @IS_NOT_JSON				INT = -1,
	        @MISSING_GUID				INT = -2,
			@MISSING_DATESTAMP			INT = -3,
			@MISSING_DEVICE_ID			INT = -4,
			@MISSING_RESPONSE_TYPE		INT = -5,
	        @INVALID_GUID				INT = -6,
			@INVALID_DATESTAMP			INT = -7,
			@INVALID_RESPONSE_TYPE		INT = -8,

		    -- Config-specific error codes:
		    @MISSING_UPDATE_FREQUENCY	INT = -10,
		    @INVALID_UPDATE_FREQUENCY	INT = -11,

		    -- Environment-specific error codes:
			@MISSING_HUMIDITY	        INT = -20,
			@MISSING_PRESSURE			INT = -21,
			@MISSING_TEMPERATURE		INT = -22,
		    @INVALID_HUMIDITY			INT = -23,
		    @INVALID_PRESSURE			INT = -24,
			@INVALID_TEMPERATURE		INT = -25
	;
	-- Values of common attributes:
	DECLARE @messageGUID		NVARCHAR(50),
	        @datestamp			NVARCHAR(50),
			@deviceId			NVARCHAR(50),
			@response			NVARCHAR(50),

			@updateFrequency	NVARCHAR(50),

			@humidity			NVARCHAR(50),
			@pressure			NVARCHAR(50),
			@temperature		NVARCHAR(50),

			@soundPlay			NVARCHAR(50),
			@soundName			NVARCHAR(50),
			@soundDuration		NVARCHAR(50),

			@dials				NVARCHAR(2000),
			@lights             NVARCHAR(2000),
			@switches			NVARCHAR(2000)
	;
	-- Did we get a valid JSON string?
	IF ISJSON(@message) = 0
		RETURN @IS_NOT_JSON
	;	
	-- JSON is valid, we can get values of all common attributes.
	SET @messageGUID = JSON_VALUE(@message, '$.messageId')
	SET @datestamp   = JSON_VALUE(@message, '$.datestamp')
	SET @deviceId    = JSON_VALUE(@message, '$.deviceId')
	SET @response    = JSON_VALUE(@message, '$.response')
	;
	-- Check whether the values we got are valid.
	IF @messageGUID IS NULL OR LEN(@messageGUID) = 0	RETURN @MISSING_GUID
	IF @datestamp   IS NULL OR LEN(@datestamp)   = 0	RETURN @MISSING_DATESTAMP
	IF @deviceId    IS NULL OR LEN(@deviceId)    = 0	RETURN @MISSING_DEVICE_ID
	IF @response    IS NULL OR LEN(@response)    = 0	RETURN @MISSING_RESPONSE_TYPE
	;
	-- Normalize the case of the response value.
	SET @response = LOWER(@response)
	;
	-- Check the GUID.
	BEGIN TRY
		DECLARE @testGUID UNIQUEIDENTIFIER = @messageGUID
	END TRY
	BEGIN CATCH
		RETURN @INVALID_GUID
	END CATCH

	-- Check the datestamp.
	BEGIN TRY
		DECLARE @testDate DATETIME = @datestamp
	END TRY
	BEGIN CATCH
		RETURN @INVALID_DATESTAMP
	END CATCH

	-- Get the message (response) type.
	DECLARE @messageType SMALLINT =
		( SELECT MessageType
		  FROM   MessageTypes
		  WHERE  Description = @response )
	;
	IF @messageType IS NULL
		RETURN @INVALID_RESPONSE_TYPE
	;
	-- Error code to check.
	DECLARE @error INT = 0
	;
	-- Check for a possible duplicate.
	IF 0 < ( SELECT COUNT(*)
	         FROM   Messages 
			 WHERE  MessageGUID = @messageGUID )
		-- It is a duplicate: do not process, report success.
		RETURN 0
	;
	-- Get the ID of the new Messages row, with due caution.
	BEGIN TRANSACTION
	;
	DECLARE @messageId BIGINT =
		( SELECT MAX(MessageId)
		  FROM   Messages
		  WITH   (TABLOCKX) )
	;
	-- This starts the sequence from 0:
	SET @messageId = COALESCE(@messageId, -1) + 1
	; 
	-- Insert the Messages row.
	INSERT
		INTO Messages (
			 MessageId
			,MessageGUID
			,DeviceId
			,DeviceTimestamp
			,MessageType)
		VALUES (
			 @messageId
			,@messageGUID
			,@deviceId
			,@datestamp
			,@messageType)
	;
	SET @error = @@ERROR
	;
	COMMIT TRANSACTION
	;
	IF @error <> 0
		RETURN @error
	;	

	-- --------------------------------------------------------------------------------------
	-- At this point we do not have an error - if we did, we have returned.
	-- From now on we have to keep the error code and, if needed, roll back the message.
	-- --------------------------------------------------------------------------------------

	-- Config and Status --------------------------------------------------------------------
	IF @response IN ('config', 'status')
	BEGIN

		-- Config-specific attribute:
		SET @updateFrequency = JSON_VALUE(@message, '$.environmentUpdateFrequency')
		;
		-- Check whether the value we got is valid.
		IF @updateFrequency IS NULL OR LEN(@updateFrequency) = 0
		BEGIN

			-- It is not good...
			SET @error = @MISSING_UPDATE_FREQUENCY
			
		END
		ELSE BEGIN

			BEGIN TRY

				-- Is the value numeric?
				DECLARE @testFrequency INT = @updateFrequency

				INSERT INTO	UpdateFrequencies
					(MessageId
					,UpdateFrequency)
				VALUES
					(@messageId
					,@updateFrequency)
				;
				SET @error = @@ERROR
				;

			END TRY
			BEGIN CATCH

				-- Value is not numeric.
				SET @error = @INVALID_UPDATE_FREQUENCY
			
			END CATCH
		END
	END

	-- Environment and Status ---------------------------------------------------------------
	IF @response IN ('environment', 'status') AND @error = 0
	BEGIN

		-- Environment-specific attributes:
		SET @humidity    = JSON_VALUE(@message, '$.humidity')
		SET @pressure    = JSON_VALUE(@message, '$.pressure')
		SET @temperature = JSON_VALUE(@message, '$.temperature')
		;
		-- All values must be present and non-null.
		-- Checking them in reverse order of the expected appearance;
		-- therefore, we report the first one that is missing.
		IF LEN(COALESCE(@temperature, '')) = 0

				SET @error = @MISSING_TEMPERATURE
		
		ELSE
			BEGIN TRY

				DECLARE @testTemperature DECIMAL(18, 4) = @temperature

			END TRY
			BEGIN CATCH

				SET @error = @INVALID_TEMPERATURE

			END CATCH
		;
		IF LEN(COALESCE(@pressure, '')) = 0

			SET @error = @MISSING_PRESSURE

		ELSE
			BEGIN TRY

				DECLARE @testPressure DECIMAL(18, 4) = @pressure

			END TRY
			BEGIN CATCH

				SET @error = @INVALID_PRESSURE

			END CATCH
		;
		IF LEN(COALESCE(@humidity, '')) = 0

			SET @error = @MISSING_HUMIDITY

		ELSE
			BEGIN TRY

				DECLARE @testHumidity DECIMAL(18, 4) = @humidity

			END TRY
			BEGIN CATCH
				
				SET @error = @INVALID_HUMIDITY

			END CATCH
		;
		IF @error = 0
		BEGIN

			-- Insert the row.
			INSERT
				INTO Environments (
						MessageId
					,Humidity
					,Pressure
					,Temperature )
				VALUES (
						@messageId
					,IIF(LEN(COALESCE(@humidity, '')) > 0,    @humidity, NULL)
					,IIF(LEN(COALESCE(@pressure, '')) > 0,    @pressure, NULL)
					,IIF(LEN(COALESCE(@temperature, '')) > 0, @temperature, NULL) )
			;
			SET @error = @@ERROR

		END -- if
	
	END -- Environment and/or Status

	-- Input and Status ---------------------------------------------------------------------
	IF @response IN ('input', 'status') AND @error = 0
	BEGIN

		-- Input-specific attributes:
		SET @dials    = JSON_VALUE(@message, '$.dials')
		SET @switches = JSON_VALUE(@message, '$.switches')
		;
		-- Strip the square brackets.
		SET @dials    = LTRIM(RTRIM(REPLACE(REPLACE(@dials,    '[', ''), ']', '')))
		SET @switches = LTRIM(RTRIM(REPLACE(REPLACE(@switches, '[', ''), ']', '')))
		;
		IF LEN(@dials) > 0
		BEGIN

			-- Use CROSS APPLY to persist all split Dial elements in their rows.
			INSERT
			INTO   Dials
			SELECT *
			FROM
				(
					SELECT @messageId AS MessageId
				) temp
				CROSS APPLY
				(
					SELECT ItemNumber, Item
					FROM   dbo.DelimitedSplit4k(@dials,',')
				) split
			;
			SET @error = @@ERROR
	
		END
	
		IF LEN(@switches) > 0 AND @error = 0
		BEGIN

			-- Use CROSS APPLY to persist all split Switches elements in their rows.
			INSERT
			INTO   Switches
			SELECT *
			FROM
				(
					SELECT @messageId AS MessageId
				) temp
				CROSS APPLY
				(
					SELECT ItemNumber, Item
					FROM   dbo.DelimitedSplit4k(@switches,',')
				) split
			;
			SET @error = @@ERROR

		END
	
	END -- Input and/or Status

	-- Output and Status --------------------------------------------------------------------
	IF @response IN ('output', 'status') AND @error = 0
	BEGIN

		-- Output-specific attributes:
		SET @lights        = JSON_VALUE(@message, '$.lights')
		SET @soundPlay     = JSON_VALUE(@message, '$.sound.play')
		SET @soundName     = JSON_VALUE(@message, '$.sound.name')
		SET @soundDuration = JSON_VALUE(@message, '$.sound.duration')
		;
		-- Strip the square brackets: we will do our own parsing.
		SET @lights = LTRIM(RTRIM(REPLACE(REPLACE(@lights, '[', ''), ']', '')))
		;
		-- Make separators of individual lights pipes to make them distinct
		-- from parameter separators.
		SET @lights = REPLACE(@lights, '},{', '|')
		;
		-- The passed string now looks as follows:
		-- {"power":true,"color":red,|"power":false}
		-- Strip the curly brackets.
		SET @lights = REPLACE(@lights, '{', '')
		SET @lights = REPLACE(@lights, '}', '')
		;
		-- Process Lights values only if we have any.
		IF LEN(@lights) > 0
		BEGIN 

			-- Use CROSS APPLY to persist all split elements in their rows.
			INSERT
			INTO   Lights
			SELECT MessageId
				  ,ItemNumber
				  ,dbo.GetLightsParam(Item, 'power')
				  ,dbo.GetLightsParam(Item, 'color')
			FROM
				(
					SELECT @messageId AS MessageId
				) temp
				CROSS APPLY
				(
					SELECT ItemNumber, Item
					FROM   dbo.DelimitedSplit4k(@lights,'|')
				) split
			;
			SET @error = @@ERROR
			
		END

		-- Process Sound only if we have it.
		IF LEN(@soundPlay) > 0 AND @error = 0
		BEGIN

			IF @soundPlay IN ('0', 'false', '')
			BEGIN

				-- This should never fail but we do error checking anyway.
				INSERT INTO	Sounds
					(MessageId
					,Play)
				VALUES
					(@messageId
					,0)
				;
				SET @error = @@ERROR

			END
			ELSE
			BEGIN

				-- If we do not have a name of the sound...
				SET @soundName = IIF(@soundName IS NULL OR LEN(@soundName) = 0, '?', @soundName)
				;
				INSERT INTO	Sounds
					(MessageId
					,Play
					,Name
					,Duration)
				VALUES
					(@messageId
					,@soundPlay
					,@soundName
					,IIF(LEN(@soundDuration) = 0, NULL, @soundDuration))
				;
				SET @error = @@ERROR

			END

		END -- sound
	
	END -- Output and/or Status

	IF @error = 0

		-- If there was no error, error log entry is not needed.
		DELETE ErrorLog WHERE Message = @message

	ELSE

		-- If there was an error, we have to roll back the inserted Messages row.
		DELETE Messages WHERE MessageId = @messageId
	;
	RETURN @error
	
END
