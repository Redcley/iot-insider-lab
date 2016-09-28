SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Updates an ad for a campaign.
--
-- Change log:
-- 14 Sep 2016  jm  Added Sequence.
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- ==================================================================

ALTER PROCEDURE UpdateAdForCampaign

	 @campaignId          NVARCHAR(50)
	,@adId		          NVARCHAR(50)
	,@sequence            SMALLINT
	,@duration	          SMALLINT
	,@firstImpression     SMALLINT
	,@impressionInterval  SMALLINT

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE AdsForCampaigns
		SET    Sequence           = @sequence
		      ,Duration           = @duration
			  ,FirstImpression    = @firstImpression
			  ,ImpressionInterval = @impressionInterval
		WHERE  CampaignId = @campaignId
		       AND
			   AdId       = @adId

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
