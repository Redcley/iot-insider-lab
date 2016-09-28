SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 16 September 2016
-- Description:	Returns the name and value of the highest average score
--              for and interval passed as From and To dates.
--
-- Change log:
-- 31 Oct 2016  jm . . .
--
-- MIT License copyright © 2016 by Microsoft Corporation.
-- =============================================================================

ALTER PROCEDURE GetDeviceAggregates

	 @deviceId  VARCHAR(50)
	,@dateFrom  DATETIME    = '2016-01-01'
	,@dateTo    DATETIME    = '2099-12-31'

AS
BEGIN

	-- Obligatory:
	SET NOCOUNT ON;

	-- Make sure that the device ID is not NULL:
	-- important for testing logical conditions.
	SET @deviceId = COALESCE(@deviceId, '')
	;
	-- We try to decrease the number of rows in the first step.
	DROP TABLE IF EXISTS #temp
	;
	SELECT *
	INTO   #temp
	FROM   ( SELECT TOP 100000000
			        DeviceId
				   ,AVG(ScoreAnger)                 AS AvgAnger
				   ,AVG(ScoreContempt)              AS AvgContempt
				   ,AVG(ScoreDisgust)               AS AvgDisgust
				   ,AVG(ScoreFear)                  AS AvgFear
				   ,AVG(ScoreHappiness)             AS AvgHappiness
				   ,AVG(ScoreNeutral)               AS AvgNeutral
				   ,AVG(ScoreSadness)               AS AvgSadness
				   ,AVG(ScoreSurprise)              AS AvgSurprise
				   ,AVG(Age)                        AS AvgAge
				   ,SUM(IIF(Gender = 'Male', 1, 0)) AS CountMales
				   ,SUM(IIF(Gender = 'Male', 0, 1)) AS CountFemales
			 FROM   FacesForImpressions f
					INNER JOIN Impressions i
							ON i.ImpressionId = f.ImpressionId
			 WHERE  DeviceTimestamp BETWEEN @dateFrom AND @dateTo
			        AND
					DeviceId = @deviceId
			 GROUP  BY DeviceId
			 ORDER  BY DeviceId
		   ) AS t
	;
	SELECT d.DeviceId
	      ,d.DeviceName
		  ,d.PostalCode
	      ,Emotion
		  ,AvgScore
		  ,AvgAge
		  ,CountMales
		  ,CountFemales
		   -- Subqueries are atrocious but we need two level aggregations
		   -- and a JOIN on an on-the-fly table is slower than this.
		  ,( SELECT COUNT(*) FROM Impressions i
		     WHERE  i.DeviceId = d.DeviceId ) AS CountImpressions
	FROM  ( SELECT DeviceId
	              ,AvgAge
				  ,CountMales
				  ,CountFemales
	              ,Emotion
				  ,AvgScore
				  ,RANK() OVER (PARTITION BY DeviceId ORDER BY AvgScore DESC) AS Rank
			FROM  ( SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Anger'  AS Emotion
						  ,AvgAnger AS AvgScore
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Contempt'
						  ,AvgContempt
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Disgust'
						  ,AvgDisgust
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Fear'
						  ,AvgFear
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Happiness'
						  ,AvgHappiness
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Neutral'
						  ,AvgNeutral
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Sadness'
						  ,AvgSadness
					FROM   #temp
					UNION  ALL
					SELECT DeviceId
			              ,AvgAge
			              ,CountMales
						  ,CountFemales
						  ,'Surprise'
						  ,AvgSurprise
					FROM   #temp
				  ) AS s
		  ) AS r
	INNER JOIN Devices d
	        ON d.DeviceId = r.DeviceId
	WHERE Rank = 1
	ORDER BY d.DeviceId
	;
	RETURN 0

END
GO
