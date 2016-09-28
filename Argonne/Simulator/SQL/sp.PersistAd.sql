SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Persists the passed Argonne ad.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE PersistAd

	 @adId		NVARCHAR(50)
	,@adName	NVARCHAR(100)
	,@url		NVARCHAR(200)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO Ads
		(
			 AdId
			,AdName
			,URL
		)
		VALUES
		(
			 @adId
			,@adName
			,@url
		)

	END TRY
	BEGIN CATCH

		-- Let the caller figure out what went wrong.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
