-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 16 September 2016
-- Description:	Returns average ad scores per postal code.
--
-- Change log:
-- 31 Oct 2016  . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- ==================================================================

CREATE VIEW AdScoresPerPostalCode
AS
SELECT TOP 10000
	   PostalCode
	  ,AdName
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
		INNER JOIN Ads a
			    ON a.AdId = i.DisplayedAdId
WHERE DeviceTimestamp >= DATEADD(day, -1, GETDATE())
GROUP BY PostalCode, AdName
ORDER BY PostalCode, AdName
;
