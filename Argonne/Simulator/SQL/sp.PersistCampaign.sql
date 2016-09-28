SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 26 August 2016
-- Description:	Persists the passed Argonne campaign.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE PersistCampaign

	 @campaignId    NVARCHAR(50)
	,@campaignName  NVARCHAR(100)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO Campaigns
		(
			 CampaignId
			,CampaignName
		)
		VALUES
		(
			 @campaignId
			,@campaignName
		)

	END TRY
	BEGIN CATCH

		-- Let the caller figure out what went wrong.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
