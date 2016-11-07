SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Deletes an Argonne ad by its Id.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE DeleteAd

	 @adId		NVARCHAR(50)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		DELETE Ads
		WHERE  AdId = @adId

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
