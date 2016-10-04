-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 26 August 2016
-- Description:	Returns counts of impressions per device
--              in the last 24 hours.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER VIEW ImpressionsPerDevice
AS
SELECT TOP 10000
       DeviceName
      ,COUNT(*) AS Impressions
FROM   Impressions i
       INNER JOIN Devices d
	           ON d.DeviceId = i.DeviceId
WHERE DeviceTimestamp >= DATEADD(day, -1, GETDATE())
GROUP BY DeviceName
ORDER BY COUNT(*) DESC
;
