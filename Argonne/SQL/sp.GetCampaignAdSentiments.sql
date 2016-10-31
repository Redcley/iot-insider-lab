USE [IoTLabArgonne]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- Author:		Nathan Bell (Redcley LLC)
-- Create date: 31 October 2016
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

CREATE PROCEDURE [dbo].[GetCampaignAdSentiments]

	 @campaignId       VARCHAR(50)
	,@dateFrom   DATETIME
	,@dateTo     DATETIME

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	SELECT 
		i.CampaignId
		,i.DisplayedAdId
		,SUM(ScoreAnger) as Anger
		,SUM(ScoreContempt) as Contempt
		,SUM(ScoreDisgust) as Disgust
		,SUM(ScoreFear) as Fear
		,SUM(ScoreHappiness) as Happiness
		,SUM(ScoreNeutral) as Neutral
		,SUM(ScoreSadness) as Sadness
		,SUM(ScoreSurprise) as Surprise
	FROM   Impressions i
	INNER JOIN FacesForImpressions f
		ON f.ImpressionId = i.ImpressionId
	WHERE i.CampaignId = campaignId AND
		(NULL <> @dateTo AND i.DeviceTimestamp BETWEEN @dateFrom AND @dateTo) OR (i.DeviceTimestamp > @dateFrom)
	Group By i.CampaignId, i.DisplayedAdId

	RETURN 0

END

GO


