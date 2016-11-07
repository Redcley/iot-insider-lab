SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Retrieves all Argonne ads for a campagn sorted by name.
--
-- Change log:
-- 14 Sep 2016  jm  Added Sequence.
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =====================================================================

ALTER PROCEDURE GetAllAdsForCampaign

	@campaignId  NVARCHAR(50)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT CampaignId
			  ,AdId
			  ,Sequence
			  ,Duration
			  ,FirstImpression
			  ,ImpressionInterval
		FROM   AdsForCampaign
		WHERE  CampaignId = @campaignId

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
