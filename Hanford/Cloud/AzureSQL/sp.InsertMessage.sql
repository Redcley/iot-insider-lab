SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 15 April 2016
-- Description:	Persists a single Messages row.
-- Usage hint:  Internal use - not expected to be called by users.
-- Returns:     MessageId if succeeded, -1 if failed (duplicate).
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[InsertMessage]

	 @messageGUID NVARCHAR(50)
	,@deviceId    NVARCHAR(50)
	,@timestamp   NVARCHAR(50)
	,@messageType NVARCHAR(20)
	,@messageId   BIGINT OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Initialize the output value - -1 denotes a duplicate.
	SET @messageId = -1
	;
	-- Error code to check.
	DECLARE @error INT = 0
	;
		-- Check the GUID.
	DECLARE @guid UNIQUEIDENTIFIER = @messageGUID
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	   RETURN @error
	;

	-- Get the message type.
	DECLARE @type SMALLINT =
		(SELECT MessageType
		 FROM   MessageTypes
		 WHERE  Description = @messageType)
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	   RETURN @error
	;

	-- Make sure we do not insert a duplicate.
	IF ( SELECT COUNT(*)
	     FROM   [Messages]
		 WHERE  MessageGUID = @guid )
	   > 0
	BEGIN

		-- This is a duplicate, and duplicates are OK.
		RETURN 0
		
	END

	-- We do not have this message - we have to persist it.
	-- Get the new ID, with due caution.
	BEGIN TRANSACTION

	SET @messageId = COALESCE(
		( SELECT MAX(MessageId) FROM Messages WITH (TABLOCKX) ),
		-1 ) + 1 -- this starts the sequence from 0
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
			,@guid
			,@deviceId
			,@timestamp
			,@type)
	;
	SET @error = @@ERROR
	;
	IF @error <> 0
	BEGIN

		SET @messageId = -1  /* Invalid ID indicates that the insert failed. */
	
	END

	COMMIT TRANSACTION

	RETURN @error
	
END
