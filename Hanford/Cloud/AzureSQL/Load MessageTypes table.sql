-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 7 March 2016
-- Description:	Loads the MessageTypes table.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================

DELETE MessageTypes
GO

INSERT INTO MessageTypes
	([MessageType]
	,[Description])
VALUES
	 (0, 'Environment')
	,(1, 'Input')
	,(2, 'Status')
	,(3, 'Output')
	,(4, 'Config')
GO
