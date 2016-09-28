SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Retrieves all Argonne devices sorted by name.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE GetAllDevices
AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT DeviceId
			  ,PrimaryKey
			  ,DeviceName
			  ,Address
			  ,Address2
			  ,Address3
			  ,City
			  ,StateProvince
			  ,PostalCode
		FROM   Devices
		ORDER  BY DeviceName

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
