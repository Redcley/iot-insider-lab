SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 12 May 2016
-- Description:	Converts UTC time to PST/PDT.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- ======================================================================
ALTER FUNCTION UtcToLocal 
(
	@utc DATETIME
)
RETURNS DATETIME
AS
BEGIN

	-- We have to account for Daylight Savings Time.
	DECLARE @yyyy CHAR(4) = FORMAT(@utc,'yyyy')
	;
	-- Our server defaults to the American date format.
	DECLARE @DTSStartWeek SMALLDATETIME = '03/01/' + CONVERT(VARCHAR,@yyyy), 
	        @DTSEndWeek   SMALLDATETIME = '11/01/' + CONVERT(VARCHAR,@yyyy)
	;
	SET @DTSStartWeek = CASE DATEPART(dw,@DTSStartWeek) 
							 WHEN 1 THEN DATEADD(hour,170,@DTSStartWeek) 
							 WHEN 2 THEN DATEADD(hour,314,@DTSStartWeek) 
							 WHEN 3 THEN DATEADD(hour,290,@DTSStartWeek) 
							 WHEN 4 THEN DATEADD(hour,266,@DTSStartWeek) 
							 WHEN 5 THEN DATEADD(hour,242,@DTSStartWeek) 
							 WHEN 6 THEN DATEADD(hour,218,@DTSStartWeek) 
							 WHEN 7 THEN DATEADD(hour,194,@DTSStartWeek) 
						END 
	SET @DTSEndWeek   = CASE DATEPART(dw,DATEADD(week,1,@DTSEndWeek))
							 WHEN 1 THEN DATEADD(hour,2,@DTSEndWeek)
							 WHEN 2 THEN DATEADD(hour,146,@DTSEndWeek)
							 WHEN 3 THEN DATEADD(hour,122,@DTSEndWeek)
							 WHEN 4 THEN DATEADD(hour,98,@DTSEndWeek)
							 WHEN 5 THEN DATEADD(hour,74,@DTSEndWeek)
							 WHEN 6 THEN DATEADD(hour,50,@DTSEndWeek)
							 WHEN 7 THEN DATEADD(hour,26,@DTSEndWeek)
					   END  

	RETURN DATEADD(hh, IIF(@utc BETWEEN @DTSStartWeek AND @DTSEndWeek,-7,-8), @utc)

END
GO
