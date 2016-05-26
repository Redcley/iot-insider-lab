SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- Author:		David Ferreira (Redcley LLC)
-- Create date: 25 May 2016
-- Returns:     Last X minutes of environmental values for a single device.
--              Number of minutes to retrieve is passed as a param.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ========================================================================
ALTER PROCEDURE [dbo].[GetDeviceReadingsForLastXMinutes]
(
	@DeviceId		NVARCHAR(50),
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
		AVG(e.[Humidity]) AS [average_humidity],
		AVG(e.[Pressure]) AS [average_pressure],
		AVG(e.[Temperature]) AS [average_temperature]
	FROM
		[Messages] AS m
		INNER JOIN [Environments] AS e ON
			m.[MessageId] = e.[MessageId]
	WHERE
		(m.[DeviceId] = @DeviceId) AND
		(m.[DeviceTimestamp] > DATEADD(minute, @MinutesToGet, GETUTCDATE())) AND
		(m.[MessageType] = 0)
	GROUP BY
		m.[DeviceId]

	-- Now get the values
	SELECT
		m.[DeviceTimestamp] AS [timestamp],
		m.[MessageId] AS [message_id],
		e.[Humidity] AS [humidity],
		e.[Pressure] AS [pressure],
		e.[Temperature] AS [temperature]
	FROM
		[Messages] AS m
		INNER JOIN [Environments] AS e ON
			m.[MessageId] = e.[MessageId]
	WHERE
		(m.[DeviceId] = @DeviceId) AND
		(m.[DeviceTimestamp] > DATEADD(minute, @MinutesToGet, GETUTCDATE())) AND
		(m.[MessageType] = 0)
	ORDER BY
		m.[DeviceTimestamp]

END
