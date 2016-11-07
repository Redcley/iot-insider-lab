USE [IoTLabArgonne]
GO

/****** Object:  StoredProcedure [dbo].[GetCampaignAdAggregateData]    Script Date: 9/15/2016 2:47:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================================================
-- Author:		Nathan Bell (Redcley LLC)
-- Create date: 14 September 2016
-- Description:	Returns the name and value of the highest average score
--              for and interval passed as From and To dates.
--
-- Change log:
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

CREATE PROCEDURE GetCampaignAdAggregateData

	 @campaignId VARCHAR(50) = ''
	,@adId       VARCHAR(50) = ''
	,@dateFrom   DATETIME = '2016-01-01'
	,@dateTo     DATETIME = '2099-12-31'

AS
BEGIN
	-- Obligatory:
	SET NOCOUNT ON;
	SET @adId = COALESCE(@adId, '')
	IF LEN(@adId) < 1
		SET @adId = null

	;WITH TotalFacesPerAd AS  (
	SELECT
		DisplayedAdId as AdId,
		SUM(1) as TotalFaces
	FROM   FacesForImpressions f
			INNER JOIN Impressions i
				    ON i.ImpressionId = f.ImpressionId
	WHERE  i.CampaignId = @campaignId
		AND ((@adId is not null and @adId = i.DisplayedAdId) OR (1=1))
		AND (DeviceTimestamp BETWEEN @dateFrom AND @dateTo)
	Group By DisplayedAdId),

	UniqueFacesPerAd AS (
		SELECT
			DisplayedAdId as AdId,
			FACEID,
			Gender,
			AVG(AGE) as avgage
		FROM   FacesForImpressions f
				INNER JOIN Impressions i
						ON i.ImpressionId = f.ImpressionId
		WHERE  i.CampaignId = @campaignId
			AND ((@adId is not null and @adId = i.DisplayedAdId) OR (1=1))
			AND (DeviceTimestamp BETWEEN @dateFrom AND @dateTo)
		Group By FaceId,Gender,DisplayedAdId),

	UniqueTotals AS   (
		SELECT
			SUM(1) as UniqueFaces,
			SUM(case when Gender = 'male' then 1 else 0 end) as Males,
			SUM(case when Gender = 'female' then 1 else 0 end) as Females,
			SUM(case when avgage between 0 and 15 then 1 else 0 end) as AgeBracket1,
			SUM(case when avgage between 16 and 19 then 1 else 0 end) as AgeBracket2,
			SUM(case when avgage between 20 and 30 then 1 else 0 end) as AgeBracket3,
			SUM(case when avgage between 30 and 40 then 1 else 0 end) as AgeBracket4,
			SUM(case when avgage between 40 and 50 then 1 else 0 end) as AgeBracket5,
			SUM(case when avgage > 50 then 1 else 0 end) as AgeBracket6,
			AdId
		FROM   UniqueFacesPerAd
		Group By AdId)

	select TFPA.TotalFaces,UT.* from
	TotalFacesPerAd as TFPA
	Inner Join UniqueTotals as UT on TFPA.AdId = UT.AdId

	RETURN 0

END



GO


