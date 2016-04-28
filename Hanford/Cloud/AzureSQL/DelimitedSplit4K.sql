-- =========================================================================================================
-- Authors:		Lynn Pettis, Jeff Moden.
--              Optimized for SQL Server 2014 by Jan Machat.
-- Create date: January-April 2010; modified April 2016.
-- Description:	Splits a given string at a given delimiter and returns a list of the split elements (items).
-- Returns:     iTVF containing the following:
--              ItemNumber = Element position of Item as a BIGINT (not converted to INT to eliminate a CAST)
--              Item       = Element value as a NVARCHAR(4000) 
-- Not copyrighted.
-- =========================================================================================================
CREATE FUNCTION [dbo].[DelimitedSplit4K]
(        
	@pString    NVARCHAR(3999),
	@pDelimiter NCHAR(1)
) 
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
-- Inline CTE-driven tally table produces values up to 10,000:
-- enough to cover NVARCHAR(4000).
WITH      E1(N) AS ( 
                      -- Create ten 1's
                      SELECT 1 UNION ALL SELECT 1 UNION ALL
                      SELECT 1 UNION ALL SELECT 1 UNION ALL
                      SELECT 1 UNION ALL SELECT 1 UNION ALL
                      SELECT 1 UNION ALL SELECT 1 UNION ALL
                      SELECT 1 UNION ALL SELECT 1 
                   ), -- 10
          E2(N) AS ( 
                      SELECT 1 FROM E1 a, E1 b
                   ), -- 100
          E4(N) AS ( 
                      SELECT 1 FROM E2 a, E2 b
                   ), -- 10,000
          cteTally(N) AS 
                   (  
                      SELECT ROW_NUMBER() OVER (ORDER BY (SELECT N)) FROM E4
                   )
-- Do the split. 
SELECT ROW_NUMBER() OVER (ORDER BY N) AS ItemNumber,
       SUBSTRING(@pString, N, CHARINDEX(@pDelimiter, @pString + @pDelimiter, N) - N) AS Item
  FROM cteTally
 WHERE N < LEN(@pString) + 2    
   AND SUBSTRING(@pDelimiter + @pString, N, 1) = @pDelimiter
;
GO