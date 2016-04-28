SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 19 April 2016
-- Description:	Persists a passed Hanford Config[ure] message.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE dbo.PersistConfig

	 @messageGUID     NVARCHAR(50)
	,@deviceId        NVARCHAR(50)
	,@timestamp       NVARCHAR(50)
	,@updateFrequency NVARCHAR(20)

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
			@messageType = 'Config',
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

	-- Insert the update frequency.
	INSERT INTO	UpdateFrequencies
		(MessageId
		,UpdateFrequency)
	VALUES
		(@messageId
		,@updateFrequency)
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

	RETURN 0  /* success */

END
