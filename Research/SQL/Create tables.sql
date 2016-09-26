-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 7 May 2016
-- Description:	Creates or recreates all tables of the Research db.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================

DROP TABLE [dbo].[ErrorLog]
GO
DROP TABLE [dbo].[MessageValues]
GO
DROP TABLE [dbo].[MessageTypeAttributes]
GO
DROP TABLE [dbo].[Attributes]
GO
DROP TABLE [dbo].[Messages]
GO
DROP TABLE [dbo].[AttributeTypes]
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
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

CREATE NONCLUSTERED INDEX [IX_MessageTypes_Description] 
ON [dbo].[MessageTypes]
(
	[Description] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE TABLE [dbo].[AttributeTypes](
	[AttributeType] [smallint]     NOT NULL,
	[Description]   [nvarchar](50) NOT NULL,
	CONSTRAINT [PK_AttributeTypes] PRIMARY KEY CLUSTERED 
	(
		[AttributeType] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE TABLE [dbo].[Messages](
	[MessageId]       [bigint]           NOT NULL,
	[MessageGUID]     [uniqueidentifier] NOT NULL,
	[DeviceId]        [nvarchar](50)     NOT NULL,
	[DeviceTimestamp] [datetime]         NOT NULL,
	[MessageType]     [smallint]         NOT NULL,
	[UtcStamp]        [datetime]         NOT NULL,
	CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC
	) 
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE [dbo].[Messages]
ADD CONSTRAINT [DF_Messages_UtcStamp]
DEFAULT (getutcdate()) FOR [UtcStamp]
GO

CREATE NONCLUSTERED INDEX [IX_Messages_DeviceId] 
ON [dbo].[Messages]
(
	[DeviceId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_Messages_DeviceId_DeviceTimestamp] 
ON [dbo].[Messages]
(
	[DeviceId] ASC,
	[DeviceTimestamp] ASC
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

CREATE NONCLUSTERED INDEX [IX_Messages_MessageType] 
ON [dbo].[Messages]
(
	[MessageType] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_Messages_UtcStamp] ON [dbo].[Messages]
(
	[UtcStamp] ASC
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

CREATE TABLE [dbo].[Attributes](
	[AttributeId]   [int]          NOT NULL,
	[AttributeType] [smallint]     NOT NULL,
	[Name]          [nvarchar](50) NOT NULL,
	[IsArray]       [bit]          NOT NULL,
	CONSTRAINT [PK_Attributes] PRIMARY KEY CLUSTERED 
	(
		[AttributeId] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE [dbo].[Attributes]
ADD CONSTRAINT [DF_Attributes_IsArray] DEFAULT ((0)) FOR [IsArray]
GO

CREATE NONCLUSTERED INDEX [IX_Attributes_AttributeType] ON [dbo].[Attributes]
(
	[AttributeType] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE [dbo].[Attributes]  WITH CHECK 
ADD CONSTRAINT [FK_Attributes_AttributeTypes]
	FOREIGN KEY([AttributeType])
	REFERENCES [dbo].[AttributeTypes] ([AttributeType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[MessageTypeAttributes](
	[MessageTypeAttributesId] [int]           NOT NULL,
	[MessageType]             [smallint]      NOT NULL,
	[AttributeId]             [int]           NOT NULL,
	[Path]                    [nvarchar](200) NOT NULL,
	[IsMandatory]             [bit]           NOT NULL,
	CONSTRAINT [PK_MessageTypeAttributes] PRIMARY KEY CLUSTERED 
	(
		[MessageTypeAttributesId] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE NONCLUSTERED INDEX [IX_MsgTypeAttributes_AttributeId] ON [dbo].[MessageTypeAttributes]
(
	[AttributeId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE [dbo].[MessageTypeAttributes] WITH CHECK
ADD CONSTRAINT [FK_MsgTypeAttributes_Attributes]
	FOREIGN KEY([AttributeId])
	REFERENCES [dbo].[Attributes] ([AttributeId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[MessageTypeAttributes] WITH CHECK
ADD CONSTRAINT [FK_MsgTypeAttributes_MessageTypes]
	FOREIGN KEY([MessageType])
	REFERENCES [dbo].[MessageTypes] ([MessageType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE [dbo].[MessageValues](
	[MessageId]           [bigint]         NOT NULL,
	[MsgTypeAttributesId] [int]            NOT NULL,
	[Order]               [smallint]       NOT NULL,
	[Value]               [nvarchar](1000) NOT NULL,
	CONSTRAINT [PK_MessageValues] PRIMARY KEY CLUSTERED 
	(
		[MessageId] ASC,
		[MsgTypeAttributesId] ASC,
		[Order] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE NONCLUSTERED INDEX [IX_MessageValues_MessageId] ON [dbo].[MessageValues]
(
	[MessageId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_MessageValues_MsgTypeAttributesId] ON [dbo].[MessageValues]
(
	[MsgTypeAttributesId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE [dbo].[MessageValues] WITH CHECK
ADD CONSTRAINT [FK_MessageValues_Messages]
	FOREIGN KEY([MessageId])
	REFERENCES [dbo].[Messages] ([MessageId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[MessageValues] WITH CHECK
ADD CONSTRAINT [FK_MessageValues_MessageTypeAttributes]
	FOREIGN KEY([MsgTypeAttributesId])
	REFERENCES [dbo].[MessageTypeAttributes] ([MessageTypeAttributesId])
GO

CREATE TABLE [dbo].[ErrorLog](
	[RowId]      [int] IDENTITY(1,1) NOT NULL,
	[Timestamp]  [datetime]          NOT NULL,
	[Message]    [nvarchar](max)     NOT NULL,
	[Error]      [varchar](100)      NOT NULL,
	CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
	(
		[RowId] ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
) TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ErrorLog] 
ADD CONSTRAINT [DF_ErrorLog_Timestamp]
DEFAULT (getdate()) FOR [Timestamp]
GO
