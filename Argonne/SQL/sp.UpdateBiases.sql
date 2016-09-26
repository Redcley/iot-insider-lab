SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 26 August 2016
-- Description:	Synchronizes the BiasesForDevices table with
--              the Devices table.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER PROCEDURE UpdateBiases
AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	BEGIN TRY
		
		-- We read all devices that have a poastal code, which makes them eligible
		-- for the demo.
		-- If we do not have biases for a device, we create them. If we do, we update
		-- the shadow name - it might be changed.
		WITH cte (DeviceId, DeviceName)
		AS
		(
			SELECT DeviceId
			      ,DeviceName
			FROM   Devices
			WHERE  LEN(PostalCode) > 0
		)
		MERGE  BiasesForDevices AS b
		USING  cte
		ON     b.DeviceId = cte.DeviceId
		WHEN NOT MATCHED BY TARGET
		       THEN INSERT (DeviceId, ShadowName) 
			        VALUES (cte.DeviceId, cte.DeviceName)
		WHEN MATCHED
		       THEN UPDATE SET b.ShadowName = cte.DeviceName
		OUTPUT $action, inserted.*, deleted.*
		;

	END TRY
	BEGIN CATCH

		-- There is nothing that could or should go wrong.
		-- If it does, let the caller handle the error.
		RETURN @@ERROR

	END CATCH

	RETURN 0

END
GO
