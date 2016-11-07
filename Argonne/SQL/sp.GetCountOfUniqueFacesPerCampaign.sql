SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 15 September 2016
-- Description:	TODO.
--
-- Change log:
-- 31 Oct 2016  jm . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

ALTER PROCEDURE GetCountOfUniqueFacesPerCampaign

	 @campaignId  VARCHAR(50)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	SELECT CampaignId
	      ,CampaignName
		  ,COUNT(FaceId) AS [Count]
	FROM  ( SELECT DISTINCT
	               c.CampaignId
				  ,CampaignName
				  ,FaceId
	        FROM   FacesForImpressions f
			       INNER JOIN Impressions i
				           ON i.ImpressionId = f.ImpressionId
				   INNER JOIN Campaigns c
				           ON c.CampaignId = i.CampaignId
			WHERE  i.CampaignId = @campaignId ) AS s
	GROUP BY CampaignId, CampaignName
	ORDER BY CampaignName
	;
	RETURN 0

END
GO
