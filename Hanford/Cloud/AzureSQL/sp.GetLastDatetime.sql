SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 9 May 2016
-- Description:	Returns timestamp of the last inserted row,
--              or NULL if the Messages table is empty.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
ALTER PROCEDURE dbo.GetLastTimestamp
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	;
		-- Get the max timestamp.
	DECLARE @utcStamp DATETIME =
		( SELECT MAX(UtcStamp) FROM [Messages] )
	;
	-- If we have no rows, we return NULL.
	SELECT CASE
		WHEN @utcStamp IS NULL THEN NULL
		ELSE CONVERT(VARCHAR(23), @utcStamp, 126) + 'Z'
	END

END
GO
