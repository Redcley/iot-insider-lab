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

	-- To keep things simple, we will drop parameter names
	-- and go by position, per the second assumption.
	SET @item = REPLACE(@item, '"', '')
	SET @item = REPLACE(@item, 'power:', '')
	SET @item = REPLACE(@item, 'color:', '')
	;

	-- We need to know wherer is the comma separating the two values.
	DECLARE @commaAt INT          = CHARINDEX(',', @item)
	DECLARE @power   NVARCHAR(50) = IIF(@commaAt = 0, @item, SUBSTRING(@item, 1, @commaAt - 1)),
			@color   NVARCHAR(50) = IIF(@commaAt = 0, NULL,  SUBSTRING(@item, @commaAt + 1, LEN(@item) - 1))
	;

	-- If we have no Power value, we assume 'false'.
	SET @power = IIF(@power IN ('true', 'false'), @power, 'false')
	;

	-- If we have no Color value, assume NULL (unknown).
	SET @color = IIF(LEN(@color) > 0, @color, NULL)
	;

	RETURN CASE @parameter
		WHEN 'power' THEN @power
		WHEN 'color' THEN @color
		ELSE NULL    /* wrong name */
	END

END
