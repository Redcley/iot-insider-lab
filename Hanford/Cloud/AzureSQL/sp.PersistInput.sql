SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 14 April 2016
-- Description:	Persists a passed Hanford Input message.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE dbo.PersistInput

	 @messageGUID NVARCHAR(50)
	,@deviceId    NVARCHAR(50)
	,@timestamp   NVARCHAR(50)
	,@dials       NVARCHAR(1000)
	,@switches    NVARCHAR(1000)

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
			@messageType = 'Input',
			@messageId = @messageId OUTPUT
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	BEGIN

		-- Let the caller handle the error.
		RETURN @error

	END

	-- Check for duplicates.
	IF @messageId < 0
	BEGIN

		-- It is a duplicate and that is OK: we are done.
		RETURN 0

	END

	-- Insert the Dials rows.
	EXEC	@error = [dbo].[InsertDials]
			@messageId = @messageId,
			@dials = @dials
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	BEGIN

		-- Let the caller handle the error.
		RETURN @error

	END

	-- Insert the Switches rows.
	EXEC	@error = [dbo].[InsertSwitches]
			@messageId = @messageId,
			@switches = @switches
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	BEGIN

		-- Let the caller handle the error.
		RETURN @error

	END

	RETURN 0  /* success */

END
