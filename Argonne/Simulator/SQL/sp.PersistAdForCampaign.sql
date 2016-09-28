SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 14 September 2016
-- Description:	Persists an ad for a campaign.
--
-- Change log:
-- 31 Oct 2016  . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- ==================================================================

ALTER PROCEDURE PersistAdForCampaign

	 @campaignId         NVARCHAR(50)
	,@adId               NVARCHAR(50)
	,@sequence           SMALLINT
	,@duration           SMALLINT
	,@firstImpression    SMALLINT
	,@impressionInterval SMALLINT

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO AdsForCampaigns
		(
			 CampaignId
			,AdId
			,Sequence
			,Duration
			,FirstImpression
			,ImpressionInterval
		)
		VALUES
		(
			 @campaignId
			,@adId
			,@sequence
			,@duration
			,@firstImpression
			,@impressionInterval
		)

	END TRY
	BEGIN CATCH

		-- Let the caller figure out what went wrong.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
