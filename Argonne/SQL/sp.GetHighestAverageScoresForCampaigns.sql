SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 13 September 2016
-- Description:	Returns the name and value of the highest average score
--              for and interval passed as From and To dates.
--
-- Change log:
-- 31 Oct 2016  jm . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

ALTER PROCEDURE GetHighestAverageScoresForCampaigns

	 @campaignId VARCHAR(50) = ''
	,@dateFrom   DATETIME    = '2016-01-01'
	,@dateTo     DATETIME    = '2099-12-31'

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	-- Make sure that the campaign ID is not NULL:
	-- important for testing logical conditions.
	SET @campaignId = COALESCE(@campaignId, '')
	;
	-- We try to decrease the number of rows in the first step.
	DROP TABLE IF EXISTS #temp
	;
	SELECT *
	INTO   #temp
	FROM   (SELECT TOP 10000000
			       c.CampaignId
				  ,AVG(ScoreAnger)      AS AvgAnger
				  ,AVG(ScoreContempt)   AS AvgContempt
				  ,AVG(ScoreDisgust)    AS AvgDisgust
				  ,AVG(ScoreFear)       AS AvgFear
				  ,AVG(ScoreHappiness)  AS AvgHappiness
				  ,AVG(ScoreNeutral)    AS AvgNeutral
				  ,AVG(ScoreSadness)    AS AvgSadness
				  ,AVG(ScoreSurprise)   AS AvgSurprise
			FROM   FacesForImpressions f
				   INNER JOIN Impressions i
						   ON i.ImpressionId = f.ImpressionId
				   INNER JOIN Campaigns c
						   ON c.CampaignId = i.CampaignId
			WHERE  DeviceTimestamp BETWEEN @dateFrom AND @dateTo
			       AND
				   ( (LEN(@campaignId) > 0 AND c.CampaignId = @campaignId) OR (1 = 1) )
			GROUP  BY c.CampaignId
			ORDER  BY c.CampaignId
		   ) AS t;

	SELECT c.CampaignId
		  ,c.CampaignName
	      ,Emotion
		  ,Score
	FROM  ( SELECT CampaignId
	              ,Emotion
				  ,Score
				  ,RANK() OVER (PARTITION BY CampaignId ORDER BY Score DESC) AS Rank
			FROM  ( SELECT CampaignId
						  ,'Anger'  AS Emotion
						  ,AvgAnger AS Score
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Contempt'
						  ,AvgContempt
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Disgust'
						  ,AvgDisgust
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Fear'
						  ,AvgFear
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Happiness'
						  ,AvgHappiness
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Neutral'
						  ,AvgNeutral
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Sadness'
						  ,AvgSadness
					FROM   #temp
					UNION  ALL
					SELECT CampaignId
						  ,'Surprise'
						  ,AvgSurprise
					FROM   #temp
				  ) AS s
		  ) AS r
	INNER JOIN Campaigns c
	        ON c.CampaignId = r.CampaignId
	WHERE Rank = 1
	ORDER BY CampaignName
	;
	RETURN 0

END
GO
