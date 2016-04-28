SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 20 April 2016
-- Returns:     Value of the requested Lights parameter;
--              NULL if parameter not found.
-- Usage:       dbo.GetLightsParameter(Item, 'power')
--              dbo.GetLightsParameter(Item, 'color')
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER FUNCTION dbo.GetLightsParam
(
	@item      NVARCHAR(100),
	@parameter NVARCHAR(50)

	-- ASSUMPTIONS -----------------------------------------------------
	--
	-- 1. The passed string looks as follows:
	--
	--    '"power":true,"color":red'  (for example)
	--     - or -
	--    '"power":false'
	-- 
	-- 2. "power" will always precede "color" (if that is present).
	--
	-- -----------------------------------------------------------------
)
RETURNS NVARCHAR(50)
AS
BEGIN
	-- Return value defaults to NULL.
	DECLARE @value NVARCHAR(50) = NULL
	;

	-- To keep things simple, we will drop parameter names
	-- and go by position, per the second assumption.
	SET @item = REPLACE(@item, '"power":', '')
	SET @item = REPLACE(@item, '"color":', '')
	;

	-- We need to know wherer is the comma separating the two values.
	DECLARE @commaAt INT = CHARINDEX(',', @item)
	;

	IF @parameter = 'power'
	BEGIN

		-- Get the value before the comma, if there is a comma.
		-- If there is no comma, we have only the 'power' value we are looking for.
		SET @value = IIF(@commaAt = 0, @item, SUBSTRING(@item, 1, @commaAt - 1))
		;

		-- If we have no value, we assume 'false'.
		SET @value = IIF(@value IN ('true', 'false'), @value, 'false')

	END

	IF @parameter = 'color'
	BEGIN

		-- Get the value after the comma, if there is a comma.
		-- If there is no comma, there is no second parameter - return NULL.
		SET @value = IIF(@commaAt = 0, NULL, SUBSTRING(@item, @commaAt + 1, LEN(@item) - 1))
		;

		-- If we have no value, assume NULL (unknown).
		SET @value = IIF(LEN(@value) > 0, @value, NULL)

	END

	RETURN @value

END
