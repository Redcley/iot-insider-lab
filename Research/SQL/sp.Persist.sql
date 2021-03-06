SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 7 May 2016
-- Description:	Persists a passed JSON message.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[Persist]

	 @message  NVARCHAR(MAX)

AS
BEGIN

	SET NOCOUNT ON;

	-- Values of common attributes:
	DECLARE @messageGUID	NVARCHAR(50),
	        @datestamp		NVARCHAR(50),
			@deviceId		NVARCHAR(50),
			@messageType	NVARCHAR(50),

			@scalar			NVARCHAR(50),
			@array			NVARCHAR(2000)
	;
	-- Did we get a valid JSON string?
	IF ISJSON(@message) = 0
	BEGIN

		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Invalid JSON.')
		;
		RETURN -1

	END

	-- JSON is valid, we can get values of all common attributes.
	SET @messageGUID = JSON_VALUE(@message, '$.messageId')
	SET @datestamp   = JSON_VALUE(@message, '$.datestamp')
	SET @deviceId    = JSON_VALUE(@message, '$.deviceId')
	SET @messageType = JSON_VALUE(@message, '$.response')
	;
	-- Check whether the values we got are valid.
	IF @messageGUID IS NULL OR LEN(@messageGUID) = 0
	BEGIN
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Message GUID is missing.')
		;
		RETURN -1
	END

	IF @datestamp IS NULL OR LEN(@datestamp) = 0
	BEGIN
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Date stamp is missing.')
		;
		RETURN -1
	END

	IF @deviceId IS NULL OR LEN(@deviceId) = 0
	BEGIN
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Device ID is missing.')
		;
		RETURN -1
	END

	IF @messageType IS NULL OR LEN(@messageType) = 0
	BEGIN
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'Message type is missing.')
		;
		RETURN -1
	END

	-- Normalize the case of the message type.
	SET @messageType = LOWER(@messageType)
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
		VALUES (@message, 'Invalid date stamp.')
		;
		RETURN -1

	END CATCH

	-- Get the message (response) type.
	-- From now on @messageType is the numeric type stored as NVARCHAR. 
	SET @messageType =
		( SELECT MessageType
		  FROM   MessageTypes
		  WHERE  Description = @messageType )
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
			 WHERE  MessageGUID = @messageGUID
			        OR
					(DeviceId = @deviceId AND DeviceTimestamp = @datestamp) )
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
		VALUES (@message, 'Duplicate device ID and date stamp.')
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

			ROLLBACK TRANSACTION
			;
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'INSERT INTO Messages error ' + CAST(@error AS VARCHAR(6)) + '.')
			;
			RETURN @error
		END

	END CATCH

	-- Get attributes for this type of message.
	DECLARE @msgTypeAttributesId  VARCHAR(50),  -- circumvents a bug in SQLS 2016
			@name                 NVARCHAR(50),
	        @path                 NVARCHAR(200),
			@type                 VARCHAR(50),
			@isMandatory          BIT,
			@isArray              BIT
	;
	DECLARE @lengthCheck NVARCHAR(4000) = ''
	;
	DECLARE c CURSOR FOR
	SELECT
		 [MessageTypeAttributesId]
		,[Name]
		,[Path]
		,[Description]
		,[IsMandatory]
		,[IsArray]
		FROM MessageTypeAttributes mta
		INNER JOIN Attributes a
				ON a.AttributeId = mta.AttributeId
		INNER JOIN AttributeTypes at
				ON at.AttributeType = a.AttributeType
		WHERE MessageType = @messageType
	;
	OPEN c
	FETCH NEXT FROM c 
	INTO @msgTypeAttributesId
		,@name
		,@path
		,@type
		,@isMandatory
		,@isArray
	;
	WHILE @@FETCH_STATUS = 0   
	BEGIN

		-- Do we have this attribute?
		-- We have to execute SQL because JSON_VALUE needs path as a literal string. (!)
		DECLARE @jsonValue NVARCHAR(2000),
		        @sql       NVARCHAR(4000),
				@parameter NVARCHAR(1000)
		;
		SET @sql = CASE WHEN @type = 'json'
						THEN 'SELECT @jsonValue = JSON_QUERY(''' + @message + ''', ''' + @path + ''')'
						ELSE 'SELECT @jsonValue = JSON_VALUE(''' + @message + ''', ''' + @path + ''')'
				   END
		; 
		SET @parameter = N'@jsonValue nvarchar(255) OUTPUT'
		;
		EXECUTE sp_executesql @sql, @parameter, @jsonValue = @jsonValue OUTPUT;
		;
		DECLARE @value NVARCHAR(2000) = COALESCE(@jsonValue, '') 
		;
		IF LEN(@value) = 0 AND @isMandatory <> 0 AND @type = 'json'
		BEGIN

			CLOSE c
			DEALLOCATE c
			;
			ROLLBACK TRANSACTION
			;
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'JSON attribute ''' + @name + ''' not found or is not JSON.')
			;
			RETURN -1 

		END
		;
		IF LEN(@value) = 0 AND @isMandatory <> 0
		BEGIN

			CLOSE c
			DEALLOCATE c
			;
			ROLLBACK TRANSACTION
			;
			INSERT INTO ErrorLog (Message, Error)
			VALUES (@message, 'Mandatory attribute ''' + @name + ''' not found or is empty.')
			;
			RETURN -1 

		END

		IF LEN(@value) > 0
		BEGIN

			-- We have a value. We will transform it into one or more rows in this table:
			DECLARE @messageValues TABLE
			(
				 [MessageId]           BIGINT
				,[MsgTypesAttributeId] INTEGER
				,[Order]               SMALLINT
				,[Value]               NVARCHAR(1000)
			);
			-- This is for the second and subsequent passes:
			DELETE @messageValues
			;
			IF @isArray = 0
			BEGIN

				-- Scalar value:
				INSERT INTO @messageValues (
					 [MessageId]
					,[MsgTypesAttributeId]
					,[Order]
					,[Value]
				)
				VALUES (
					 @messageId
					,@msgTypeAttributesId
					,0
					,@value
				);

			END
			ELSE BEGIN

				-- Array: strip the square brackets.
				SET @value = LTRIM(RTRIM(REPLACE(REPLACE(@value,'[',''),']','')))
				;
				--Different handling for scalars vs JSON.
				IF @type = 'json'

					-- We need to split only between JSON tokens, not between attribute/value pairs.
					SET @value = REPLACE(@value,'},{','}|{')
				
				ELSE

					-- Straightforward split of the list.
					SET @value = REPLACE(@value,',','|')
				;
				-- Use CROSS APPLY to persist all split Dial elements in their rows.
				INSERT INTO   @messageValues
				SELECT *
				FROM
					(
						SELECT @messageId           AS MessageId
						      ,@msgTypeAttributesId AS MsgTypesAttributeId
					) temp
					CROSS APPLY
					(
						SELECT ItemNumber AS [Order]
						      ,Item       AS [Value]
						FROM   dbo.DelimitedSplit4k(@value,'|')
					) split
					WHERE LEN([Value]) > 0

			END

			-- Inner cursor loops through our table.
			DECLARE @v NVARCHAR(1000) -- value
			;
			DECLARE t CURSOR FOR
			SELECT  [Value]
			FROM    @messageValues
			;
			OPEN t
			FETCH NEXT FROM t
			INTO @v
			;
			WHILE @@FETCH_STATUS = 0   
			BEGIN

				-- Check validity of all values except JSON.
				-- If JSON was not correct, it was not retrieved.

				IF @type = 'integer'
				BEGIN

					BEGIN TRY

						DECLARE @testInteger INTEGER = CAST(@v AS INTEGER)

					END TRY
					BEGIN CATCH

						CLOSE t
						DEALLOCATE t
						;
						CLOSE c
						DEALLOCATE c
						;
						ROLLBACK TRANSACTION
						;
						INSERT INTO ErrorLog (Message, Error)
						VALUES (@message, 'Value of attribute ''' + @name + ''' is not an integer.')
						;
						RETURN -1
					
					END CATCH

				END

				IF @type = 'decimal'
				BEGIN

					BEGIN TRY

						DECLARE @testDecimal DECIMAL = CAST(@v AS DECIMAL)

					END TRY
					BEGIN CATCH

						CLOSE t
						DEALLOCATE t
						;
						CLOSE c
						DEALLOCATE c
						;
						ROLLBACK TRANSACTION
						;
						INSERT INTO ErrorLog (Message, Error)
						VALUES (@message, 'Value of attribute ''' + @name + ''' is not a decimal.')
						;
						RETURN -1
					
					END CATCH

				END

				IF @type = 'bit'
				BEGIN

					BEGIN TRY

						DECLARE @testBit BIT = CAST(@v AS BIT)

					END TRY
					BEGIN CATCH

						CLOSE t
						DEALLOCATE t
						;
						CLOSE c
						DEALLOCATE c
						;
						ROLLBACK TRANSACTION
						;
						INSERT INTO ErrorLog (Message, Error)
						VALUES (@message, 'Value of attribute ''' + @name + ''' is not a bit.')
						;
						RETURN -1
					
					END CATCH

				END

				-- Include in the length of all values.
				SET @lengthCheck += @v

 				FETCH NEXT FROM t
				INTO @v

			END -- inner WHILE

			CLOSE t
			DEALLOCATE t
			;

			-- All rows passed tests: persist them.
			BEGIN TRY

				INSERT   INTO  MessageValues
				SELECT * FROM @messageValues
	
			END TRY
			BEGIN CATCH

				SET @error = @@ERROR
				;
				IF @error <> 0
				BEGIN

					CLOSE c
					DEALLOCATE c
					;
					ROLLBACK TRANSACTION
					;
					INSERT INTO ErrorLog (Message, Error)
					VALUES (@message, 'INSERT INTO MessageValues error ' + CAST(@error AS VARCHAR(6)) + '.')
					;
					RETURN @error

				END

			END CATCH

		END  -- LEN() > 0

		FETCH NEXT FROM c
		INTO @msgTypeAttributesId
			,@name
			,@path
			,@type
			,@isMandatory
			,@isArray

	END

	CLOSE c
	DEALLOCATE c
	;

	-- Did we get any parameters?
	if LEN(@lengthCheck) = 0
	BEGIN

		-- No, we did not. 
		ROLLBACK TRANSACTION
		;
		INSERT INTO ErrorLog (Message, Error)
		VALUES (@message, 'No values to persist.')
		;
		RETURN -1
					
	END

	COMMIT TRANSACTION
	RETURN 0
	
END
