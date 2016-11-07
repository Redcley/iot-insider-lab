-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 26 August 2016
-- Description:	Returns a set of devices that did not report
--              in the last 5 minutes.
--
-- Change log:
-- 31 Oct 2016  . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- ==================================================================

CREATE VIEW FailingDevices
AS
SELECT PostalCode
      ,DeviceName
	  ,FailureInterval
FROM
	( SELECT TOP 100000
		     PostalCode
		    ,DeviceName
		    ,DATEDIFF(minute, MaxInsertTimestamp, GETDATE()) AS FailureInterval
	  FROM   ( SELECT DeviceId
	                 ,MAX(InsertTimestamp) AS MaxInsertTimestamp
			   FROM   Impressions
			   GROUP  BY DeviceId ) i
		     INNER JOIN Devices d
				     ON d.DeviceId = i.DeviceId
	  WHERE MaxInsertTimestamp < DATEADD(minute, -5, GETDATE())
    ) AS f
;
