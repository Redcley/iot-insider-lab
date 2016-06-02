SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 14 April 2016
-- Description:	Persists a passed Hanford Status message.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[PersistOutput]

	 @messageGUID     NVARCHAR(50)
	,@deviceId        NVARCHAR(50)
	,@timestamp       NVARCHAR(50)
	,@soundPlay       NVARCHAR(20)
	,@soundName       NVARCHAR(50)
	,@soundDuration   NVARCHAR(20)
	,@lights          NVARCHAR(1000)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Error code to check.
	DECLARE @error INT = 0;

	-- Get the ID of the new Messages row.
	DECLARE @messageId BIGINT = -1
	;
	EXEC	@error = [dbo].[InsertMessage]
		    @messageGUID = @messageGUID,
			@deviceId = @deviceId,
			@timestamp = @timestamp,
			@messageType = 'Output',
			@messageId = @messageId OUTPUT
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	BEGIN

		-- Let the caller handle the error.
		RETURN @error

	END

	-- Check for duplicates - they are OK.
	IF @messageId < 0
	BEGIN

		-- We are done.
		RETURN 0

	END

	-- Insert the sound.
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
		;
		IF @error <> 0
		BEGIN

			-- We are doing our own rollback.
			DELETE
				Messages
			WHERE
				MessageId = @messageId
			;
			RETURN @error

		END
	END
	ELSE
	BEGIN

		-- If we do not have a name of the sound...
		SET @soundName = IIF(LEN(@soundName) = 0, '?', @soundName)
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
		;
		IF @error <> 0
		BEGIN

			-- We are doing our own rollback.
			DELETE Messages
			WHERE  MessageId = @messageId
			;
			RETURN @error

		END
	END

	-- Insert the Lights rows.
	EXEC	@error = [dbo].[InsertLights]
			@messageId = @messageId,
			@lights = @lights
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	BEGIN

		-- Let the caller handle the error.
		-- Sproc does the rollback.
		RETURN @error

	END

	RETURN 0  /* success */

END
