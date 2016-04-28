SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 20 April 2016
-- Description:	Persists a a passed set of lights' settings.
-- Usage hint:  Internal use - not expected to be called by users.
-- Returns:     0 if succeeded, error code if failed.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[InsertLights]

	 @messageId   BIGINT
	,@lights      NVARCHAR(1000)

	-- ASSUMPTION -----------------------------------------------------
	-- The passed string looks as follows:
	--
	-- [{"power":true,"color":red},{"power":false}]
	-- 
	-- At this time, we do not care about meaning of the ordinal number
	-- of each light (it will vary by device).
	-- ----------------------------------------------------------------

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Error code to return.
	DECLARE @error INT = 0;

	-- Strip square brackets.
	SET @lights = REPLACE(@lights, '[', '')
	SET @lights = REPLACE(@lights, ']', '')
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

	-- Process values only if we have any.
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
