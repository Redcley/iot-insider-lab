-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 26 August 2016
-- Description:	Returns average scores per postal code.
--
-- Change log:
-- 31 Aug 2016  . . .
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ==================================================================

ALTER VIEW AvgScoresPerPostalCode
AS
SELECT f.PostalCode
      ,DeviceName
      ,AvgAnger
      ,AvgContempt
      ,AvgDisgust
      ,AvgFear
      ,AvgHappiness
      ,AvgNeutral
      ,AvgSadness
      ,AvgSurprise
FROM
	( SELECT TOP 10000
		     PostalCode
		    ,AVG(ScoreAnger)     AS AvgAnger
		    ,AVG(ScoreContempt)  AS AvgContempt
		    ,AVG(ScoreDisgust)   AS AvgDisgust
		    ,AVG(ScoreFear)      AS AvgFear
		    ,AVG(ScoreHappiness) AS AvgHappiness
		    ,AVG(ScoreNeutral)   AS AvgNeutral
		    ,AVG(ScoreSadness)   AS AvgSadness
		    ,AVG(ScoreSurprise)  AS AvgSurprise
	  FROM   FacesForImpressions f
		     INNER JOIN Impressions i
			 	     ON i.ImpressionId = f.ImpressionId
		     INNER JOIN Devices d
				     ON d.DeviceId = i.DeviceId
	  WHERE DeviceTimestamp >= DATEADD(day, -1, GETDATE())
	  GROUP BY PostalCode
	  ORDER BY PostalCode ) AS f
	INNER JOIN Devices d
	        ON d.PostalCode = f.PostalCode
;
