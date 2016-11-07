SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Retrieves all Argonne campaigns sorted by name.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE GetAllCampaigns
AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT CampaignId
			  ,CampaignName
		FROM   Campaigns
		ORDER  BY CampaignName

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
