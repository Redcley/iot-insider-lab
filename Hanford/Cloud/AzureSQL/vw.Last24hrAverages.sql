SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 25 May 2016
-- Description:	10-minute aggregations of the last 24 hr measurements, rounded.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ============================================================================
ALTER VIEW [dbo].[Last24hrAverages]
AS

	SELECT TOP 1000000
	       DeviceId
	      ,Interval
	      ,CAST( ROUND([Avg humidity],1) AS DECIMAL (4,1) )     AS [Avg humidity]
		  ,CAST( ROUND([Avg pressure],1) AS DECIMAL (8,1) )     AS [Avg pressure]
		  ,CAST( ROUND( [Avg temperature],1) AS DECIMAL (4,1) ) AS [Avg temperature]
	FROM   dbo.TenMinutes
	ORDER  by Interval, DeviceId

GO