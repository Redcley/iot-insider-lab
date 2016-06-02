SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 May 2016
--
-- Change log:
-- 31 May 2016  [jm] Accesses the new table instead of on-fly aggregations.
--
-- Description:	10-minute aggregations of the last 24 hr measurements, rounded.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ============================================================================
ALTER VIEW [dbo].[Last24hrAverages]
AS

	SELECT TOP 1000000 -- overkill
	       DeviceId
	      ,Interval
	      ,AvgHumidity     AS [Avg humidity]
		  ,AvgPressure     AS [Avg pressure]
		  ,AvgTemperature  AS [Avg temperature]
	FROM   Environment10MinuteAvgs
	WHERE  Interval >= DATEADD( d, -1, GETUTCDATE() )
	ORDER  by Interval, DeviceId

GO