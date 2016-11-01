USE [IoTLabArgonne]
GO

/****** Object:  StoredProcedure [dbo].[GetCampaignAdAggregates]    Script Date: 11/1/2016 11:01:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 October 2016
-- Description:	Returns the name and value of the highest average score
--              for and interval passed as From and To dates.
--
-- Change log:
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

CREATE PROCEDURE [dbo].[GetCampaignAdAggregates]

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
	-- We do this for unique faces. If we have seen a face several times,
	-- we take the latest appearance.
	-- Subqueries are usually atrocious but we do only one per campaign.
	SELECT c.CampaignId
	      ,CampaignName
		  ,DisplayedAdId
		  ,AdName
		  ,( SELECT COUNT(FaceId)
		     FROM   FacesForImpressions f
			        INNER JOIN Impressions i
					        ON i.ImpressionId = f.ImpressionId
		     WHERE  ( (LEN(@campaignId) > 0 AND c.CampaignId = @campaignId) OR (1 = 1) )
				AND DeviceTimestamp BETWEEN @dateFrom AND @dateTo
		   ) AS TotalFaces
		  ,UniqueFaces
		  ,MinAge
		  ,MaxAge
		  ,OverallSentiment
		  ,UniqueMales
		  ,UniqueFemales
		  ,AgeBracket0
		  ,AgeBracket0Males
		  ,AgeBracket0Females
		  ,AgeBracket1
		  ,AgeBracket1Males
		  ,AgeBracket1Females
		  ,AgeBracket2
		  ,AgeBracket2Males
		  ,AgeBracket2Females
		  ,AgeBracket3
		  ,AgeBracket3Males
		  ,AgeBracket3Females
		  ,AgeBracket4
		  ,AgeBracket4Males
		  ,AgeBracket4Females
		  ,AgeBracket5
		  ,AgeBracket5Males
		  ,AgeBracket5Females
		  ,AgeBracket6
		  ,AgeBracket6Males
		  ,AgeBracket6Females
	FROM   Campaigns c
	       RIGHT JOIN
				  ( SELECT *
					FROM   (SELECT TOP 10000000
								   CampaignId
								  ,DisplayedAdId
								  ,SUM(1)                 AS UniqueFaces
								  ,CAST(MIN(Age) AS INT)  AS MinAge
								  ,CAST(MAX(Age) AS INT)  AS MaxAge
								  ,dbo.TopEmotionName (
									 AVG(ScoreAnger)
									,AVG(ScoreContempt)
									,AVG(ScoreDisgust)
									,AVG(ScoreFear)
									,AVG(ScoreHappiness)
									,AVG(ScoreNeutral)
									,AVG(ScoreSadness)
									,AVG(ScoreSurprise) ) AS OverallSentiment
								  ,SUM(UniqueMale)        AS UniqueMales
								  ,SUM(UniqueFemale)      AS UniqueFemales
								  ,SUM(AgeBracket0)       AS AgeBracket0
								  ,SUM(AgeBracket0Male)   AS AgeBracket0Males
								  ,SUM(AgeBracket0Female) AS AgeBracket0Females
								  ,SUM(AgeBracket1)       AS AgeBracket1
								  ,SUM(AgeBracket1Male)   AS AgeBracket1Males
								  ,SUM(AgeBracket1Female) AS AgeBracket1Females
								  ,SUM(AgeBracket2)       AS AgeBracket2
								  ,SUM(AgeBracket2Male)   AS AgeBracket2Males
								  ,SUM(AgeBracket2Female) AS AgeBracket2Females
								  ,SUM(AgeBracket3)       AS AgeBracket3
								  ,SUM(AgeBracket3Male)   AS AgeBracket3Males
								  ,SUM(AgeBracket3Female) AS AgeBracket3Females
								  ,SUM(AgeBracket4)       AS AgeBracket4
								  ,SUM(AgeBracket4Male)   AS AgeBracket4Males
								  ,SUM(AgeBracket4Female) AS AgeBracket4Females
								  ,SUM(AgeBracket5)       AS AgeBracket5
								  ,SUM(AgeBracket5Male)   AS AgeBracket5Males
								  ,SUM(AgeBracket5Female) AS AgeBracket5Females
								  ,SUM(AgeBracket6)       AS AgeBracket6
								  ,SUM(AgeBracket6Male)   AS AgeBracket6Males
								  ,SUM(AgeBracket6Female) AS AgeBracket6Females
							FROM   ( SELECT c.CampaignId
							               ,DisplayedAdId
										   ,f.FaceId
										   ,f.Age
										   ,Gender
										  ,IIF(Gender = 'Male', 1, 0)
																AS UniqueMale
										  ,IIF(Gender = 'Female', 1, 0)
																AS UniqueFemale
										  ,IIF(Bracket = 0, 1, 0)
																AS AgeBracket0
										  ,IIF(Bracket = 0 AND Gender = 'Male', 1, 0)
																AS AgeBracket0Male
										  ,IIF(Bracket = 0 AND Gender = 'Female', 1, 0)
																AS AgeBracket0Female
										  ,IIF(Bracket = 1, 1, 0)
																AS AgeBracket1
										  ,IIF(Bracket = 1 AND Gender = 'Male', 1, 0)
																AS AgeBracket1Male
										  ,IIF(Bracket = 1 AND Gender = 'Female', 1, 0)
																AS AgeBracket1Female
										  ,IIF(Bracket = 2, 1, 0)
																AS AgeBracket2
										  ,IIF(Bracket = 2 AND Gender = 'Male', 1, 0)
																AS AgeBracket2Male
										  ,IIF(Bracket = 2 AND Gender = 'Female', 1, 0)
																AS AgeBracket2Female
										  ,IIF(Bracket = 3, 1, 0)
																AS AgeBracket3
										  ,IIF(Bracket = 3 AND Gender = 'Male', 1, 0)
																AS AgeBracket3Male
										  ,IIF(Bracket = 3 AND Gender = 'Female', 1, 0)
																AS AgeBracket3Female
										  ,IIF(Bracket = 4, 1, 0)
																AS AgeBracket4
										  ,IIF(Bracket = 4 AND Gender = 'Male', 1, 0)
																AS AgeBracket4Male
										  ,IIF(Bracket = 4 AND Gender = 'Female', 1, 0)
																AS AgeBracket4Female
										  ,IIF(Bracket = 5, 1, 0)
																AS AgeBracket5
										  ,IIF(Bracket = 5 AND Gender = 'Male', 1, 0)
																AS AgeBracket5Male
										  ,IIF(Bracket = 5 AND Gender = 'Female', 1, 0)
																AS AgeBracket5Female
										  ,IIF(Bracket = 6, 1, 0)
																AS AgeBracket6
										  ,IIF(Bracket = 6 AND Gender = 'Male', 1, 0)
																AS AgeBracket6Male
										  ,IIF(Bracket = 6 AND Gender = 'Female', 1, 0)
																AS AgeBracket6Female
										   ,ScoreAnger
										   ,ScoreContempt
										   ,ScoreDisgust
										   ,ScoreFear
										   ,ScoreHappiness
										   ,ScoreNeutral
										   ,ScoreSadness
										   ,ScoreSurprise
										   ,RANK() OVER (PARTITION BY FaceId ORDER BY DeviceTimestamp DESC) AS Rank
									 FROM	( SELECT ImpressionId
													,FaceId
													,Age
													,CASE
														WHEN Age BETWEEN  0 AND 14 THEN 0
														WHEN Age BETWEEN 15 AND 19 THEN 1
														WHEN Age BETWEEN 20 AND 29 THEN 2
														WHEN Age BETWEEN 30 AND 39 THEN 3
														WHEN Age BETWEEN 40 AND 49 THEN 4
														WHEN Age BETWEEN 50 AND 59 THEN 5
																				   ELSE 6
													 END	 AS Bracket
													,Gender
													,ScoreAnger
													,ScoreContempt
													,ScoreDisgust
													,ScoreFear
													,ScoreHappiness
													,ScoreNeutral
													,ScoreSadness
													,ScoreSurprise
											  FROM   FacesForImpressions ) f
											INNER JOIN Impressions i
													ON i.ImpressionId = f.ImpressionId
											INNER JOIN Campaigns c
													ON c.CampaignId = i.CampaignId
											WHERE  DeviceTimestamp BETWEEN @dateFrom AND @dateTo
												   AND
												   ( (LEN(@campaignId) > 0 AND c.CampaignId = @campaignId) OR (1 = 1) )
									) AS r
							WHERE  Rank = 1 
							GROUP  BY CampaignId, DisplayedAdId
							ORDER  BY CampaignId, DisplayedAdId
						   ) AS t
				  ) AS s
			ON c.CampaignId = s.CampaignId
	INNER JOIN Ads a
	        ON a.AdId = s.DisplayedAdId
	ORDER BY CampaignName, AdName
	;
	RETURN 0

END

GO


