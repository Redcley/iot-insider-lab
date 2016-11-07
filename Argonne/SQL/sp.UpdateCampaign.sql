SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Updates an Argonne campaign identified by its ID.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE UpdateCampaign

	 @campaignId    NVARCHAR(50)
	,@campaignName  NVARCHAR(100)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE Campaigns
		SET    CampaignName = @campaignName
		WHERE  CampaignId   = @campaignId

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
