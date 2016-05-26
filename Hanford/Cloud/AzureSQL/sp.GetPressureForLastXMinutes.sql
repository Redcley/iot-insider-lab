SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		David Ferreira (Redcley LLC)
-- Create date: 24 May 2016
-- Returns:     Last X minutes of pressure values for all devices.
--              Number of minutes to retrieve is passed as a param.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE [dbo].[GetPressureForLastXMinutes]
(
	@MinutesToGet	INT = -3
)
AS
BEGIN

	-- Make sure we have a good value to work with
	IF @MinutesToGet > 0
	BEGIN
		SET @MinutesToGet = @MinutesToGet * -1
	END
	ELSE IF @MinutesToGet = 0
	BEGIN
		SET @MinutesToGet = -3
	END

	-- Get the averages
	SELECT
		m.[DeviceId] AS [device_id],
		'pressure' AS [reading_type],
		AVG(e.[Pressure]) AS [average]
	FROM
		[Messages] AS m
		INNER JOIN [Environments] AS e ON
			m.[MessageId] = e.[MessageId]
	WHERE
		(m.[DeviceTimestamp] > DATEADD(minute, @MinutesToGet, GETUTCDATE())) AND
		(m.[MessageType] = 0)
	GROUP BY
		m.[DeviceId]
	ORDER BY
		m.[DeviceId]

	-- Now get the values to return
	SELECT
		m.[DeviceId] AS [device_id],
		m.[DeviceTimestamp] AS [timestamp],
		m.[MessageId] AS [message_id],
		e.[Pressure] AS [reading]
	FROM
		[Messages] AS m
		INNER JOIN [Environments] AS e ON
			m.[MessageId] = e.[MessageId]
	WHERE
		(m.[DeviceTimestamp] > DATEADD(minute, @MinutesToGet, GETUTCDATE())) AND
		(m.[MessageType] = 0)
	ORDER BY
		m.[DeviceId],
		m.[DeviceTimestamp]

END
