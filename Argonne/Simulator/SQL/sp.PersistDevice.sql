SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 24 August 2016
-- Description:	Persists the passed Argonne device.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE PersistDevice

	 @deviceId		NVARCHAR(50)
	,@primaryKey	NVARCHAR(100)
	,@deviceName	NVARCHAR(100)
	,@address		NVARCHAR(100) = ''
	,@address2		NVARCHAR(100) = ''
	,@address3		NVARCHAR(100) = ''
	,@city			NVARCHAR(100) = ''
	,@stateProvince	NVARCHAR(50)  = ''
	,@postalCode	NVARCHAR(50)  = ''

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY

		INSERT INTO Devices
		(
			 DeviceId
			,PrimaryKey
			,DeviceName
			,Address
			,Address2
			,Address3
			,City
			,StateProvince
			,PostalCode
		)
		VALUES
		(
			 @deviceId
			,@primaryKey
			,@deviceName
			,@address
			,@address2
			,@address3
			,@city
			,@stateProvince
			,@postalCode
		)

	END TRY
	BEGIN CATCH

		-- Let the caller figure out what went wrong.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
