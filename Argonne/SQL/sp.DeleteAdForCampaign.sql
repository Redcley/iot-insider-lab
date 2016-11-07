SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Deletes an Argonne ad within a campaign by its campaign
--              and ad Ids.
--
-- Usage note:  Use with utmost caution - this is reference data for impressions.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==============================================================================

ALTER PROCEDURE DeleteAdForCampaign

	 @campaignId  NVARCHAR(50)
	,@adId        NVARCHAR(50)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		DELETE AdsForCampaigns
		WHERE  CampaignId = @campaignId
		       AND
		       AdId = @adId

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
