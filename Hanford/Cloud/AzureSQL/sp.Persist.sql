SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 28 April 2016
-- Description:	Persists a passed Hanford JSON message.
-- Returns:     0 if succeeded, -1 if failed.
--
-- Change log:
--  8 May 2016  (jm) Refined checking of the common attributes.
--  6 Sep 2016  (jm) Replaced error codes by error messages.
--
-- MIT License Copyright © 2016 by Microsoft Corporation.
-- =================================================================
ALTER PROCEDURE [dbo].[Persist]

	 @message  NVARCHAR(MAX)

AS
BEGIN

	SET NOCOUNT ON
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
	BEGIN

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Not a valid JSON.')
		;
		RETURN -1

	END
	-- JSON is valid, we can get values of all common attributes.
	SET @messageGUID = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.messageId'), '')))
	SET @datestamp   = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.datestamp'), '')))
	SET @deviceId    = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.deviceId'),  '')))
	SET @response    = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.response'),  '')))
	;
	-- Check whether the values we got are valid.
	IF LEN(@messageGUID) = 0
	BEGIN

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Missing or empty message GUID.')
		;
		RETURN -1
	
	END
	
	IF LEN(@datestamp) = 0
	BEGIN
	
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Missing or empty datestamp.')
		;
		RETURN -1

	END
	
	IF LEN(@deviceId) = 0
	BEGIN

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Missing or empty devicedId.')
		;
		RETURN -1

	END
	
	IF LEN(@response) = 0
	BEGIN

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Missing or empty response type.')
		;
		RETURN -1

	END
	
	-- Normalize the case of the response value.
	SET @response = LOWER(@response)
	;
	-- Check the GUID.
	BEGIN TRY

		DECLARE @testGUID UNIQUEIDENTIFIER = @messageGUID

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Invalid message GUID.')
		;
		RETURN -1

	END CATCH

	-- Check the datestamp.
	BEGIN TRY
		DECLARE @testDate DATETIME = @datestamp
	END TRY
	BEGIN CATCH

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Invalid datestamp.')
		;
		RETURN -1

	END CATCH

	-- Get the message (response) type.
	DECLARE @messageType SMALLINT =
		( SELECT MessageType
		  FROM   MessageTypes
		  WHERE  Description = @response )
	;
	IF @messageType IS NULL
	BEGIN

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Invalid message type.')
		;
		RETURN -1
	
	END

	-- Error code to check.
	DECLARE @error INT = 0
	;
	-- Check for a possible duplicate.
	IF 0 < ( SELECT COUNT(*)
	         FROM   [Messages] 
			 WHERE  MessageGUID = @messageGUID )
	BEGIN
		
		-- It is a duplicate: do not process, report success.
		RETURN 0
	
	END

	-- We should not get from the same device messages with the same time stamp,
	-- but we do. We consider them duplicates but we log the offending device.
	IF 0 < ( SELECT COUNT(*)
	         FROM   [Messages] 
			 WHERE  DeviceId = @deviceId 
			        AND 
					DeviceTimestamp = @datestamp )
	BEGIN
		
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Duplicate deviceId and datestamp.')
		;
		RETURN 0
	
	END

	-- Get the ID of the new Messages row, with due caution.
	BEGIN TRANSACTION
	
	DECLARE @messageId BIGINT =
		( SELECT MAX(MessageId)
		  FROM   [Messages]
		  WITH   (TABLOCKX) )
	;
	-- This starts the sequence from 0:
	SET @messageId = COALESCE(@messageId, -1) + 1
	; 
	-- Insert the Messages row.
	BEGIN TRY

		INSERT
			INTO [Messages] (
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
	
	END TRY
	BEGIN CATCH

		SET @error = @@ERROR
		;
		IF @error <> 0
		BEGIN

			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'INSERT INTO Messages error ' + @error)
			;
			ROLLBACK TRANSACTION
			RETURN -1

		END

	END CATCH

	-- Config and Status --------------------------------------------------------------------
	IF @response IN ('config', 'status')
	BEGIN

		-- Config-specific attribute:
		SET @updateFrequency = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.environmentUpdateFrequency'), '')))
		;
		-- Check whether the value we got is valid.
		IF @updateFrequency IS NULL OR LEN(@updateFrequency) = 0
		BEGIN
			-- It is not good...
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'Missing environmentUpdateFrequency.')
			;
			ROLLBACK TRANSACTION
			RETURN -1

		END
		ELSE BEGIN

			BEGIN TRY

				-- Is the value numeric?
				DECLARE @testFrequency INT = @updateFrequency

			END TRY
			BEGIN CATCH

				-- Value is not numeric.
				INSERT INTO ErrorLog (Message, Error)
				VALUES (@message, 'environmentUpdateFrequency is not an integer.')
				;
				ROLLBACK TRANSACTION
				RETURN -1

			END CATCH

			BEGIN TRY

				INSERT INTO	UpdateFrequencies (
					 MessageId
					,UpdateFrequency )
				VALUES (
					 @messageId
					,@updateFrequency )

			END TRY
			BEGIN CATCH

				INSERT INTO ErrorLog (Message, Error)
				VALUES (@message, 'INSERT INTO UpdateFrequencies error ' + @error)
				;
				ROLLBACK TRANSACTION
				RETURN -1

			END CATCH
		END
	END

	-- Environment and Status ---------------------------------------------------------------
	IF @response IN ('environment', 'status')
	BEGIN

		-- Environment-specific attributes:
		SET @humidity    = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.humidity'),    '')))
		SET @pressure    = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.pressure'),    '')))
		SET @temperature = LTRIM(RTRIM(COALESCE(JSON_VALUE(@message, '$.temperature'), '')))
		;
		-- At least one value must be present and non-null.
		IF 0 = LEN(@temperature) +
		       LEN(@pressure) +
		       LEN(@humidity)
		BEGIN

			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'At least one environment value must be present.')
			;
			ROLLBACK TRANSACTION
			RETURN -1
		
		END
		IF LEN(@temperature) > 0
		BEGIN
			BEGIN TRY

				DECLARE @testTemperature DECIMAL(18, 4) = @temperature

			END TRY
			BEGIN CATCH

				INSERT INTO ErrorLog (Message, Error)
				VALUES (@message, 'Invalid temperature value.')
				;
				ROLLBACK TRANSACTION
				RETURN -1

			END CATCH
		END
		
		IF LEN(@pressure) > 0
		BEGIN
			BEGIN TRY

				DECLARE @testPressure DECIMAL(18, 4) = @pressure

			END TRY
			BEGIN CATCH

			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'Invalid pressure value.')
			;
				ROLLBACK TRANSACTION
				RETURN -1

			END CATCH
		END
				
		IF LEN(@humidity) > 0
		BEGIN
			BEGIN TRY

				DECLARE @testHumidity DECIMAL(18, 4) = @humidity

			END TRY
			BEGIN CATCH
				
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'Invalid humidity value.')
			;
				ROLLBACK TRANSACTION
				RETURN -1

			END CATCH
		END
				
		-- We are ready to insert the row.
		BEGIN TRY

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
		
		END TRY
		BEGIN CATCH

			SET @error = @@ERROR
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'INSERT INTO Environments error ' + @error)
			;
			ROLLBACK TRANSACTION
			RETURN -1

		END CATCH

	END -- Environment and/or Status

	-- Input and Status ---------------------------------------------------------------------
	IF @response IN ('input', 'status')
	BEGIN

		-- Input-specific attributes:
		SET @dials    = COALESCE(JSON_VALUE(@message, '$.dials'),    '')
		SET @switches = COALESCE(JSON_VALUE(@message, '$.switches'), '')
		;
		-- Strip the square brackets.
		SET @dials    = LTRIM(RTRIM(REPLACE(REPLACE(@dials,    '[', ''), ']', '')))
		SET @switches = LTRIM(RTRIM(REPLACE(REPLACE(@switches, '[', ''), ']', '')))
		;
		IF LEN(@dials) > 0
		BEGIN TRY

			-- Use CROSS APPLY to persist all split Dial elements in their rows.
			INSERT INTO Dials
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
	
		END TRY
		BEGIN CATCH

			SET @error = @@ERROR
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'INSERT INTO Dials error ' + @error)
			;
			ROLLBACK TRANSACTION
			RETURN -1

		END CATCH
	
		IF LEN(@switches) > 0
		BEGIN TRY

			-- Use CROSS APPLY to persist all split Switches elements in their rows.
			INSERT INTO Switches
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

		END TRY
		BEGIN CATCH

			SET @error = @@ERROR
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'INSERT INTO Switches error ' + @error)
			;
			ROLLBACK TRANSACTION
			RETURN -1

		END CATCH
	
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
		BEGIN TRY

			-- Use CROSS APPLY to persist all split elements in their rows.
			INSERT INTO Lights
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
			
		END TRY
		BEGIN CATCH

			SET @error = @@ERROR
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'INSERT INTO Lights error ' + @error)
			;
			ROLLBACK TRANSACTION
			RETURN -1

		END CATCH

		-- Process Sound only if we have it.
		IF LEN(@soundPlay) > 0
		BEGIN

			IF @soundPlay IN ('0', 'false', '')
			BEGIN

				-- This should never fail but we do error checking anyway.
				BEGIN TRY
					INSERT INTO	Sounds
						(MessageId
						,Play)
					VALUES
						(@messageId
						,0)

				END TRY
				BEGIN CATCH

					SET @error = @@ERROR
					INSERT INTO ErrorLog (Message, Error)
					VALUES (@message, 'INSERT INTO Sounds error ' + @error)
					;
					ROLLBACK TRANSACTION
					RETURN -1

				END CATCH

			END
			ELSE
			BEGIN

				-- If we do not have a name of the sound...
				SET @soundName = IIF(@soundName IS NULL OR LEN(@soundName) = 0, '?', @soundName)
				;
				BEGIN TRY

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
				
				END TRY
				BEGIN CATCH

					SET @error = @@ERROR
					INSERT INTO ErrorLog (Message, Error)
					VALUES (@message, 'INSERT INTO	Sounds error ' + @error)
					;
					ROLLBACK TRANSACTION
					RETURN -1

				END CATCH

			END -- IF

		END -- sound
	
	END -- Output and/or Status

	COMMIT TRANSACTION
	RETURN 0
	
END
