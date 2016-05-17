SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 5 May 2016
-- Description:	Cleanses (normalizes) SkyConditions strings.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ======================================================================
ALTER FUNCTION Cleanse 
(
	@skyConditions NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN

	-- ------------------------------------------------------------------
	-- Business rules:
	-- 1. We accept up to three values BKNnnn, CLR, FEWnnn,OVCnnn,SCTnnn.
	-- 2. If the value is CLR, it is the only one.
	-- 3. We round nnn to the lower multiple of 5.
	-- 4. We handle a maximum of three values.
	-- 5. If we have two values of the same type, we take the higher one.
	--
	-- NOAA-defined descriptors:
	-- BKN	Broken
	-- CLR	Clear
	-- FEW	Convective precipitation descriptor
	-- OVC	Overcast
	-- SCT	Scattered
	-- ------------------------------------------------------------------

	-- Check the trivial case - we do not know:
	SET @skyConditions = LTRIM(RTRIM(@skyConditions))
	IF  @skyConditions IS NULL OR LEN(@skyConditions) = 0
		RETURN NULL
	;

	-- We do the split by the hard way, but we can have only three items.
	DECLARE @condition1 NVARCHAR(6) = '',
	        @condition2 NVARCHAR(6) = '',
			@condition3 NVARCHAR(6) = ''
	;
	DECLARE @ci INT = CHARINDEX(' ',@skyConditions)
	;
	IF @ci < 1
	BEGIN

		-- We have no or one condition.
		SET @condition1 = @skyConditions

	END
	ELSE
	BEGIN

		-- We have at least two conditions. Get the first one.
		SET @condition1    = LTRIM(RTRIM(SUBSTRING(@skyConditions,1,@ci - 1)))
		SET @skyConditions = LTRIM(RTRIM(SUBSTRING(@skyConditions,@ci + 1, LEN(@skyConditions) - @ci)))
		;
		-- We try for the third condition.
		SET @ci = CHARINDEX(' ',@skyConditions)
		IF  @ci < 1
		BEGIN

			-- We have two conditions.
			SET @condition2 = LTRIM(RTRIM(@skyConditions))

		END
		ELSE
		BEGIN

			-- We have three conditions. Get the remaining ones.
			SET @condition2 = LTRIM(RTRIM(SUBSTRING(@skyConditions,1,@ci - 1)))
			SET @condition3 = LTRIM(RTRIM(SUBSTRING(@skyConditions,@ci + 1, LEN(@skyConditions) - @ci)))
		
		END

	END

	-- Logical checks.
	-- Conditions have form XXXNNN where XXX is one of the five codes
	-- and NNN is a three-digit number (padded left if needed).
	-- CLR does not have the number, and if the sky is clear, there is
	-- no other condition and we are done.
	IF @condition1 = 'CLR'
		RETURN 'CLR'
	;

	IF SUBSTRING(@condition3,1,3) NOT IN ('BKN','FEW','OVC','SCT')
	   OR
	   LEN(@condition3) <> 6
	BEGIN

		SET @condition3 = ''		

	END

	IF SUBSTRING(@condition2,1,3) NOT IN ('BKN','FEW','OVC','SCT')
	   OR
	   LEN(@condition2) <> 6
	BEGIN

		SET @condition2 = @condition3
		SET @condition3 = ''		

	END

	IF SUBSTRING(@condition1,1,3) NOT IN ('BKN','FEW','OVC','SCT')
	   OR
	   LEN(@condition1) <> 6
	BEGIN

		SET @condition1 = @condition2
		SET @condition2 = @condition3
		SET @condition3 = ''		

	END

	-- Recheck what we have - we might have eliminated the only (wrong) value.
	If LEN(@condition1) = 0    
		RETURN NULL
	;
	
	-- Round the numeric parts, per business rule (3).
	SET @condition1 = SUBSTRING(@condition1,1,3) + RIGHT('000' + CAST( ( (CAST(SUBSTRING(@condition1,4,3) AS SMALLINT)/5) * 5 ) AS VARCHAR),3)
	;
	IF LEN(@condition2) > 0 
	   SET @condition2 = SUBSTRING(@condition2,1,3) + RIGHT('000' + CAST( ( (CAST(SUBSTRING(@condition2,4,3) AS SMALLINT)/5) * 5 ) AS VARCHAR),3)
	;
	IF LEN(@condition3) > 0
	   SET @condition3 = SUBSTRING(@condition3,1,3) + RIGHT('000' + CAST( ( (CAST(SUBSTRING(@condition3,4,3) AS SMALLINT)/5) * 5 ) AS VARCHAR),3)
	;
	 
	-- Bubble sort: it is clumsy but that is the only way in a function.
	-- If length of the second condition is zero, there is nothing to sort.
	DECLARE @temp NVARCHAR(10)
	;
	IF LEN(@condition2) > 0 
	BEGIN

		IF LEN(@condition3) = 0
		-- we have only two items to sort
		BEGIN
		
			IF @condition1 > @condition2
			BEGIN

				SET @temp = @condition2
				SET @condition2 = @condition1
				SET @condition1 = @temp

			END

		END
		ELSE
		-- we have three items to sort...
		BEGIN

			-- ...and we need up to two passes to do that.
			DECLARE @i INT = 0
			;
			WHILE @i <= 1
			BEGIN

				IF @condition1 > @condition2
				BEGIN

					SET @temp = @condition2
					SET @condition2 = @condition1
					SET @condition1 = @temp

				END

				IF @condition2 > @condition3
				BEGIN

					SET @temp = @condition3
					SET @condition3 = @condition2
					SET @condition2 = @temp

				END

				SET @i += 1

			END

		END

	END

	-- Check for two values of the same descriptor.
	IF SUBSTRING(@condition2,1,3) = SUBSTRING(@condition3,1,3)
	BEGIN

		SET @condition2 = @condition3
		SET @condition3 = ''

	END
	IF SUBSTRING(@condition1,1,3) = SUBSTRING(@condition2,1,3)
	BEGIN

		SET @condition1 = @condition2
		SET @condition2 = @condition3
		SET @condition3 = ''

	END

	RETURN @condition1 + 
	       IIF(LEN(@condition2) = 0, '', ' ' + @condition2) +
	       IIF(LEN(@condition3) = 0, '', ' ' + @condition3)

END
GO

