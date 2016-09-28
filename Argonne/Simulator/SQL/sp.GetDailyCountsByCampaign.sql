SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 20 September 2016
-- Description:	Returns the name and value of the highest average score
--              for and interval passed as From and To dates.
--
-- Change log:
-- 31 Oct 2016  jm . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

ALTER PROCEDURE GetDailyCountsByCampaign

	 @campaignId VARCHAR(50) = ''
AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	-- Make sure that the campaign ID is not NULL:
	-- important for testing logical conditions.
	SET @campaignId = COALESCE(@campaignId, '')
	;
	SELECT d.CampaignId
	      ,d.CampaignName
		  ,DailyTotal
		  ,DailyMales
		  ,DailyFemales
		  ,HourlyTotal
		  ,HourlyMales
		  ,HourlyFemales
	FROM   ( -- Daily counts
	         SELECT TOP 1000000
			        CampaignId
			       ,CampaignName
			       ,SUM(Total)    AS DailyTotal
	               ,SUM(Males)    AS DailyMales
	               ,SUM(Females)  AS DailyFemales
			 FROM ( SELECT c.CampaignId
			              ,c.CampaignName
						  ,(1)                        AS Total
			              ,IIF(Gender = 'Male', 1, 0) AS Males
			              ,IIF(Gender = 'Male', 0, 1) AS Females
					FROM   FacesForImpressions f
					       INNER JOIN Impressions i
						           ON i.ImpressionId = f.ImpressionId
						   INNER JOIN Campaigns c
						           ON c.CampaignId = i.CampaignId
					WHERE  DeviceTimestamp >= FORMAT(GETDATE(),'d','en-US') 
						   AND
						   ( (LEN(@campaignId) > 0 AND c.CampaignId = @campaignId) OR (1 = 1) )
				  ) AS dd
			 GROUP BY CampaignId, CampaignName
			 ORDER BY CampaignId, CampaignName
		   ) AS d
		   INNER JOIN
	       ( -- Daily counts
	         SELECT TOP 1000000
			        CampaignId
			       ,CampaignName
			       ,SUM(Total)    AS HourlyTotal
	               ,SUM(Males)    AS HourlyMales
	               ,SUM(Females)  AS HourlyFemales
			 FROM ( SELECT c.CampaignId
			              ,c.CampaignName
						  ,(1)                        AS Total
			              ,IIF(Gender = 'Male', 1, 0) AS Males
			              ,IIF(Gender = 'Male', 0, 1) AS Females
					FROM   FacesForImpressions f
					       INNER JOIN Impressions i
						           ON i.ImpressionId = f.ImpressionId
						   INNER JOIN Campaigns c
						           ON c.CampaignId = i.CampaignId
					WHERE  DeviceTimestamp >= DATEADD(hour,-1,GETDATE()) 
						   AND
						   ( (LEN(@campaignId) > 0 AND c.CampaignId = @campaignId) OR (1 = 1) )
				  ) AS hh
			 GROUP BY CampaignId, CampaignName
			 ORDER BY CampaignId, CampaignName
		   ) AS h
		   ON h.CampaignId = d.CampaignId
	;
	RETURN 0

END
GO
