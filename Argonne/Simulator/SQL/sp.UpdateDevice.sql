SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 August 2016
-- Description:	Updates an Argonne device identified by its ID.
--
-- Note:        Primary key of the device cannot be updated.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE UpdateDevice

	 @deviceId		NVARCHAR(50)
	,@deviceName	NVARCHAR(100)
	,@address		NVARCHAR(100)
	,@address2		NVARCHAR(100)
	,@address3		NVARCHAR(100)
	,@city			NVARCHAR(100)
	,@stateProvince	NVARCHAR(50)
	,@postalCode	NVARCHAR(50)

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE Devices
		SET    DeviceName    = @deviceName
			  ,Address       = @address
			  ,Address2      = @address2
			  ,Address3      = @address3
			  ,City          = @city
			  ,StateProvince = @stateProvince
			  ,PostalCode    = @postalCode
		WHERE  DeviceId	     = @deviceId

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
