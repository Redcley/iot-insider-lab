SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 19 April 2016
-- Description:	Persists a a passed set of dials settings.
-- Usage hint:  Internal use - not expected to be called by users.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[InsertDials]

	 @messageId   BIGINT
	,@dials       NVARCHAR(1000)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Error code to return.
	DECLARE @error INT = 0;

	-- Strip square brackets.
	SET @dials = REPLACE(@dials, '[', '')
	SET @dials = REPLACE(@dials, ']', '')
	;

	-- Process values only if we have any.
	IF LEN(@dials) > 0
	BEGIN 

		-- Use CROSS APPLY to persist all split elements in their rows.
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

	RETURN 0
	
END
