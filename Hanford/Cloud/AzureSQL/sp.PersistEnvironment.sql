SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 14 April 2016
-- Description:	Persists a passed Hanford Environment message.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[PersistEnvironment]

	 @messageGUID NVARCHAR(50)
	,@deviceId    NVARCHAR(50)
	,@timestamp   NVARCHAR(50)
	,@humidity    NVARCHAR(20)
	,@pressure    NVARCHAR(20)
	,@temperature NVARCHAR(20)

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
			@messageType = 'Environment',
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

	-- Insert the Environments row.
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
	
	RETURN 0  /* success */
	
END
