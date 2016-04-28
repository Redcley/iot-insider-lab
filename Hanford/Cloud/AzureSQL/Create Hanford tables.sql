-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 7 March 2016
-- Description:	Creates or recreates all Hanford tables.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================

DROP TABLE [dbo].[Dials]
GO
DROP TABLE [dbo].[Environments]
GO
DROP TABLE [dbo].[Lights]
GO
DROP TABLE [dbo].[Sounds]
GO
DROP TABLE [dbo].[Switches]
GO
DROP TABLE [dbo].[UpdateFrequencies]
GO
DROP TABLE [dbo].[Messages]
GO
DROP TABLE [dbo].[MessageTypes]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MessageTypes](
	[MessageType] [smallint]     NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	CONSTRAINT [PK_MessageTypes] PRIMARY KEY CLUSTERED 
	(
		[MessageType] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MessageTypes_Description] 
ON [dbo].[MessageTypes]
(
	[Description] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


GO
CREATE TABLE [dbo].[Messages](
	[MessageId]       [bigint]           NOT NULL,
	[MessageGUID]     [uniqueidentifier] NOT NULL,
	[DeviceId]        [nvarchar](50)     NOT NULL,
	[DeviceTimestamp] [datetime]         NOT NULL,
	[MessageType]     [smallint]         NOT NULL,
	CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC
	) 
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Messages_MessageType] 
ON [dbo].[Messages]
(
	[MessageType] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_Messages_DeviceId] 
ON [dbo].[Messages]
(
	[DeviceId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Messages_MessageGUID] 
ON [dbo].[Messages]
(
	[MessageGUID] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE [dbo].[Messages] WITH CHECK 
ADD CONSTRAINT [FK_MessageTypes_Messages] 
	FOREIGN KEY([MessageType])
	REFERENCES [dbo].[MessageTypes] ([MessageType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[Dials](
	[MessageId] [bigint]        NOT NULL,
	[Order]     [tinyint]       NOT NULL,
	[Value]     [decimal](9, 4) NOT NULL,
	CONSTRAINT [PK_Dials] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC,
		[Order]     ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Dials] WITH CHECK 
ADD CONSTRAINT [FK_Messages_Dials] 
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[Environments](
	[MessageId]   [bigint]         NOT NULL,
	[Humidity]    [decimal](18, 4) NOT NULL,
	[Pressure]    [decimal](18, 4) NOT NULL,
	[Temperature] [decimal](18, 4) NOT NULL,
	CONSTRAINT [PK_Environments] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Environments] WITH CHECK 
ADD CONSTRAINT [FK_Messages_Environments] 
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[Lights](
	[MessageId] [bigint]       NOT NULL,
	[Order]     [smallint]     NOT NULL,
	[Power]     [bit]          NOT NULL,
	[Color]     [nvarchar](50) NULL
	CONSTRAINT [PK_Lights] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC,
		[Order]     ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE [dbo].[Lights] WITH CHECK 
ADD CONSTRAINT [FK_Messages_Lights] 
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[Sounds](
	[MessageId] [bigint]       NOT NULL,
	[Play]      [bit]          NOT NULL,
	[Name]      [nvarchar](50) NULL,
	[Duration]  [smallint]     NULL,
	CONSTRAINT [PK_Sounds] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE [dbo].[Sounds] WITH CHECK 
ADD CONSTRAINT [FK_Messages_Sounds] 
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO


CREATE TABLE [dbo].[Switches](
	[MessageId] [bigint]  NOT NULL,
	[Order]     [tinyint] NOT NULL,
	[State]     [bit]     NOT NULL,
	CONSTRAINT [PK_Switches] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC,
		[Order]     ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Switches] WITH CHECK 
ADD CONSTRAINT [FK_Messages_Switches] 
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[UpdateFrequencies](
	[MessageId]       [bigint] NOT NULL,
	[UpdateFrequency] [int]    NOT NULL,
	CONSTRAINT [PK_UpdateFrequencies] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UpdateFrequencies] WITH CHECK 
ADD CONSTRAINT [FK_Messages_UpdateFrequencies] 
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
