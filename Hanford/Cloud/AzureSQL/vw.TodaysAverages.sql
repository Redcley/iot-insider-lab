SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 13 May 2016
-- Description:	10-minute aggregations of today's measurements, rounded.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =====================================================================
ALTER VIEW [dbo].[TodaysAverages]
AS

	SELECT TOP 1000000
	       DeviceId
	      ,dbo.UtcToLocal(Interval) AS Interval
	      ,CAST( ROUND([Avg humidity],1) AS DECIMAL (4,1) )     AS [Avg humidity]
		  ,CAST( ROUND([Avg pressure],1) AS DECIMAL (8,1) )     AS [Avg pressure]
		  ,CAST( ROUND( [Avg temperature],1) AS DECIMAL (4,1) ) AS [Avg temperature]
	FROM   dbo.TenMinutes
	WHERE  dbo.UtcToLocal(Interval) >= FORMAT( GETDATE(), 'MM/dd/yyyy 7:00:00', 'en-US' )
	ORDER  by Interval, DeviceId

GO