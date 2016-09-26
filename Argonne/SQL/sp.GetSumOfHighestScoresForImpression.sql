SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 14 September 2016
-- Description:	TODO.
--
-- Change log:
-- 31 Oct 2016  jm . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

ALTER PROCEDURE GetSumOfHighestScoresForImpression

	 @adId       VARCHAR(50) = ''
	,@dateFrom   DATETIME    = '2016-01-01'
	,@dateTo     DATETIME    = '2099-12-31'

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	-- Make sure that the ad ID is not NULL:
	-- important for testing logical conditions.
	SET @adId = COALESCE(@adId, '')
	;
	-- We try to decrease the number of rows in the first step.
	DROP TABLE IF EXISTS #temp
	;
	SELECT *
	INTO   #temp
	FROM   (SELECT TOP 100000000
			         f.ImpressionId
					,MAX(ScoreAnger)     AS MaxAnger
					,MAX(ScoreContempt)  AS MaxContempt
					,MAX(ScoreDisgust)   AS MaxDisgust
					,MAX(ScoreFear)      AS MaxFear
					,MAX(ScoreHappiness) AS MaxHappiness
					,MAX(ScoreNeutral)   AS MaxNeutral
					,MAX(ScoreSadness)   AS MaxSadness
					,MAX(ScoreSurprise)  AS MaxSurprise
			FROM     FacesForImpressions f
			         INNER JOIN Impressions i 
							 ON i.ImpressionId = f.ImpressionId
			WHERE  DeviceTimestamp BETWEEN @dateFrom AND @dateTo
			GROUP BY f.ImpressionId
			ORDER BY f.ImpressionId
		   ) AS t;

	-- If we have an ID, we reduce this set.
	IF LEN(@adId) > 0
		DELETE #temp
		WHERE  AdId <> @adId
	;
	SELECT DisplayedAdId
	      ,AdName
	      ,SUM(CASE WHEN MaxAnger > MaxContempt  AND
		                 MaxAnger > MaxDisgust   AND
						 MaxAnger > MaxFear      AND
						 MaxAnger > MaxHappiness AND
						 MaxAnger > MaxNeutral   AND
						 MaxAnger > MaxSadness   AND
						 MaxAnger > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Anger
	      ,SUM(CASE WHEN MaxContempt > MaxAnger     AND
		                 MaxContempt > MaxDisgust   AND
						 MaxContempt > MaxFear      AND
						 MaxContempt > MaxHappiness AND
						 MaxContempt > MaxNeutral   AND
						 MaxContempt > MaxSadness   AND
						 MaxContempt > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Contempt
	      ,SUM(CASE WHEN MaxDisgust > MaxAnger     AND
		                 MaxDisgust > MaxContempt  AND
						 MaxDisgust > MaxFear      AND
						 MaxDisgust > MaxHappiness AND
						 MaxDisgust > MaxNeutral   AND
						 MaxDisgust > MaxSadness   AND
						 MaxDisgust > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Disgust
	      ,SUM(CASE WHEN MaxFear > MaxAnger     AND
		                 MaxFear > MaxContempt  AND
						 MaxFear > MaxDisgust   AND
						 MaxFear > MaxHappiness AND
						 MaxFear > MaxNeutral   AND
						 MaxFear > MaxSadness   AND
						 MaxFear > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Fear
	      ,SUM(CASE WHEN MaxHappiness > MaxAnger     AND
		                 MaxHappiness > MaxContempt  AND
						 MaxHappiness > MaxDisgust   AND
						 MaxHappiness > MaxFear       AND 
						 MaxHappiness > MaxNeutral   AND
						 MaxHappiness > MaxSadness   AND
						 MaxHappiness > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Happiness
	      ,SUM(CASE WHEN MaxNeutral > MaxAnger     AND
		                 MaxNeutral > MaxContempt  AND
						 MaxNeutral > MaxDisgust   AND
						 MaxNeutral > MaxFear      AND 
						 MaxNeutral > MaxHappiness AND
						 MaxNeutral > MaxSadness   AND
						 MaxNeutral > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Neutral
	      ,SUM(CASE WHEN MaxSadness > MaxAnger     AND
		                 MaxSadness > MaxContempt  AND
						 MaxSadness > MaxDisgust   AND
						 MaxSadness > MaxFear      AND 
						 MaxSadness > MaxHappiness AND
						 MaxSadness > MaxNeutral   AND
						 MaxSadness > MaxSurprise
					THEN 1
		            ELSE 0 END) AS Sadness
	      ,SUM(CASE WHEN MaxSurprise > MaxAnger     AND
		                 MaxSurprise > MaxContempt  AND
						 MaxSurprise > MaxDisgust   AND
						 MaxSurprise > MaxFear      AND 
						 MaxSurprise > MaxHappiness AND
						 MaxSurprise > MaxNeutral   AND
						 MaxSurprise > MaxSadness
					THEN 1
		            ELSE 0 END) AS Surprise
	FROM   #temp t
	       INNER JOIN Impressions i
		           ON t.ImpressionId = i.ImpressionId
	       INNER JOIN Ads a
	               ON AdId = DisplayedAdId
	GROUP BY DisplayedAdId, AdName
	ORDER BY AdName
	;
	RETURN 0

END
GO
