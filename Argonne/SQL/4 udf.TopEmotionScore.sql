-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 20 September 2016
-- Description:	Returns the name of the highest passed score.
--
-- Change log:
-- 31 Oct 2016  jm . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================
CREATE FUNCTION dbo.TopEmotionScore
(        
	@scoreAnger		DECIMAL(18, 15),
	@scoreContempt	DECIMAL(18, 15),
	@scoreDisgust	DECIMAL(18, 15),
	@scoreFear		DECIMAL(18, 15),
	@scoreHappiness	DECIMAL(18, 15),
	@scoreNeutral	DECIMAL(18, 15),
	@scoreSadness	DECIMAL(18, 15),
	@scoreSurprise	DECIMAL(18, 15)
) 
RETURNS DECIMAL(18, 15)
AS
BEGIN
	RETURN

 		-- This is primitive but very fast.
		-- Note that CASE is evaluated in the order in which it is written;
		-- therefore, we do not have to retest previous cases.
		CASE

			WHEN @scoreAnger > @scoreContempt
				 AND
				 @scoreAnger > @scoreDisgust
				 AND
				 @scoreAnger > @scoreFear
				 AND
				 @scoreAnger > @scoreDisgust
				 AND
				 @scoreAnger > @scoreHappiness
				 AND
				 @scoreAnger > @scoreNeutral
				 AND
				 @scoreAnger > @scoreSadness
				 AND
				 @scoreAnger > @scoreSurprise		THEN @scoreAnger

			WHEN @scoreContempt > @scoreDisgust
				 AND
				 @scoreContempt > @scoreFear
				 AND
				 @scoreContempt > @scoreDisgust
				 AND
				 @scoreContempt > @scoreHappiness
				 AND
				 @scoreContempt > @scoreNeutral
				 AND
				 @scoreContempt > @scoreSadness
				 AND
				 @scoreContempt > @scoreSurprise	THEN @scoreContempt

			WHEN @scoreDisgust > @scoreFear
				 AND
				 @scoreDisgust > @scoreHappiness
				 AND
				 @scoreDisgust > @scoreNeutral
				 AND
				 @scoreDisgust > @scoreSadness
				 AND
				 @scoreDisgust > @scoreSurprise		THEN @scoreDisgust

			WHEN @scoreFear > @scoreHappiness
				 AND
				 @scoreFear > @scoreNeutral
				 AND
				 @scoreFear > @scoreSadness
				 AND
				 @scoreFear > @scoreSurprise		THEN @scoreFear

			WHEN @scoreHappiness > @scoreNeutral
				 AND
				 @scoreHappiness > @scoreSadness
				 AND
				 @scoreHappiness > @scoreSurprise	THEN @scoreHappiness

			WHEN @scoreNeutral > @scoreSadness
				 AND
				 @scoreNeutral > @scoreSurprise		THEN @scoreNeutral

			WHEN @scoreSadness > @scoreSurprise		THEN @scoreSadness

													ELSE @scoreSurprise
		END
END
GO