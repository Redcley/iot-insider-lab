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
		    @INVALID_HUMIDITY			INT = -20,
		    @INVALID_PRESSURE			INT = -21,
			@INVALID_TEMPERATURE		INT = -22

	;

	-- Did we get a valid JSON string?
	IF ISJSON(@message) = 0
		RETURN @IS_NOT_JSON
	;	

	-- JSON is valid, we can get values of all common attributes.
	DECLARE @messageGUID NVARCHAR(50) = JSON_VALUE(@message, '$.messageId'),
	        @datestamp   NVARCHAR(50) = JSON_VALUE(@message, '$.datestamp'),
			@deviceId    NVARCHAR(50) = JSON_VALUE(@message, '$.deviceId'),
			@response    NVARCHAR(20) = JSON_VALUE(@message, '$.response')
	;

	-- Check whether the values we got are valid.
	IF @messageGUID IS NULL OR LEN(@messageGUID) = 0	RETURN @MISSING_GUID
	IF @datestamp   IS NULL OR LEN(@datestamp)   = 0	RETURN @MISSING_DATESTAMP
	IF @deviceId    IS NULL OR LEN(@deviceId)    = 0	RETURN @MISSING_DEVICE_ID
	IF @response    IS NULL OR LEN(@response)    = 0	RETURN @MISSING_RESPONSE_TYPE
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

select @messageGUID as MessageGUID, @datestamp as [Timestamp], @deviceId as DeviceId, @response as Response

	-- Error code to check.
	DECLARE @error INT = 0;

	-- Check for a possible duplicate.
	IF 0 < ( SELECT COUNT(*)
	         FROM   Messages 
			 WHERE  MessageGUID = @messageGUID
			        AND
					DeviceId = @deviceId
					AND
					DeviceTimestamp = @datestamp
					AND
					MessageType = @messageType )
		-- It is a duplicate: do not process, report success.
		RETURN 0
	;

	-- Get the ID of the new Messages row.
	DECLARE @messageId BIGINT =
		( SELECT MAX(MessageId)
		  FROM   Messages )
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
	IF @error <> 0
		RETURN @error
	;	

	-- Message type-specific processing.
	SET @response = LOWER(@response)
	;
	IF @response = 'config'
	BEGIN

		-- Config-specific attribute:
		DECLARE @updateFrequency NVARCHAR(50) = JSON_VALUE(@message, '$.environmentUpdateFrequency')
		;

	END

	IF @response = 'environment'
	BEGIN

		-- Environment-specific attributes:
		DECLARE @humidity  NVARCHAR(50) = JSON_VALUE(@message, '$.humidity'),
				@pressure  NVARCHAR(50) = JSON_VALUE(@message, '$.datestamp'),
				@response    NVARCHAR(20) = JSON_VALUE(@message, '$.response')
	;
		-- Insert the row.
		INSERT
			INTO Environments (
				 MessageId
				,Humidity
				,Pressure
				,Temperature)
			VALUES (
				 @messageId
				,@humidity
				,@pressure
				,@temperature)
		;
		SET @error = @@ERROR
		;
		IF @error <> 0
		BEGIN

			-- We are doing our own rollback:
			-- delete the orphaned Messages row.
			DELETE
				Messages
			WHERE
				MessageId = @messageId
			;
			RETURN @error
	
		END

	END -- Environment
	
	RETURN 0  /* success */
	
END
