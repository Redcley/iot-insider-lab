-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 7 April 2016
-- Description:	Creates or recreates all Hanford tables.
--
-- Update log:
--  9 May 2016  jm Added ErrorLog.
--  6 Sep 2016  jm Modified ErrorLog: message is verbal.
--                 Environments values are nullable.
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================

DROP TABLE IF EXISTS dbo.ErrorLog
GO
DROP TABLE IF EXISTS dbo.Environment10MinuteAvgs
GO
DROP TABLE IF EXISTS dbo.Dials
GO
DROP TABLE IF EXISTS dbo.Environments
GO
DROP TABLE IF EXISTS dbo.Lights
GO
DROP TABLE IF EXISTS dbo.Sounds
GO
DROP TABLE IF EXISTS dbo.Switches
GO
DROP TABLE IF EXISTS dbo.UpdateFrequencies
GO
DROP TABLE IF EXISTS dbo.Messages
GO
DROP TABLE IF EXISTS dbo.MessageTypes
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.MessageTypes(
	MessageType smallint     NOT NULL,
	Description nvarchar(50) NOT NULL,
	CONSTRAINT PK_MessageTypes PRIMARY KEY CLUSTERED 
	(
		MessageType ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY

CREATE NONCLUSTERED INDEX IX_MessageTypes_Description 
ON dbo.MessageTypes
(
	Description ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


GO
CREATE TABLE dbo.Messages(
	MessageId       bigint           NOT NULL,
	MessageGUID     uniqueidentifier NOT NULL,
	DeviceId        nvarchar(50)     NOT NULL,
	DeviceTimestamp datetime         NOT NULL,
	MessageType     smallint         NOT NULL,
	UtcStamp        datetime         NOT NULL,
	CONSTRAINT PK_Messages PRIMARY KEY CLUSTERED 
	(
		MessageId ASC
	) 
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY
GO

ALTER TABLE dbo.Messages
ADD CONSTRAINT DF_Messages_UtcStamp
DEFAULT (getutcdate()) FOR UtcStamp
GO

CREATE NONCLUSTERED INDEX IX_Messages_DeviceId 
ON dbo.Messages
(
	DeviceId ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Messages_DeviceId_DeviceTimestamp 
ON dbo.Messages
(
	DeviceId ASC,
	DeviceTimestamp ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_Messages_MessageGUID 
ON dbo.Messages
(
	MessageGUID ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Messages_MessageType 
ON dbo.Messages
(
	MessageType ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Messages_UtcStamp ON dbo.Messages
(
	UtcStamp ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE dbo.Messages
ADD CONSTRAINT FK_MessageTypes_Messages 
	FOREIGN KEY(MessageType)
	REFERENCES dbo.MessageTypes (MessageType)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.Dials(
	MessageId bigint        NOT NULL,
	Order     tinyint       NOT NULL,
	Value     decimal(9, 4) NOT NULL,
	CONSTRAINT PK_Dials PRIMARY KEY CLUSTERED 
	(
		MessageId ASC,
		Order     ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY
GO

ALTER TABLE dbo.Dials
ADD CONSTRAINT FK_Messages_Dials 
	FOREIGN KEY(MessageId)
	REFERENCES dbo.Messages (MessageId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.Environments(
	MessageId   bigint         NOT NULL,
	Humidity    decimal(18, 4)     NULL,
	Pressure    decimal(18, 4)     NULL,
	Temperature decimal(18, 4)     NULL,
	CONSTRAINT PK_Environments PRIMARY KEY CLUSTERED 
	(
		MessageId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY
GO

ALTER TABLE dbo.Environments WITH
ADD CONSTRAINT FK_Messages_Environments 
	FOREIGN KEY(MessageId)
	REFERENCES dbo.Messages (MessageId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.Lights(
	MessageId bigint       NOT NULL,
	Order     smallint     NOT NULL,
	Power     bit          NOT NULL,
	Color     nvarchar(50) NULL
	CONSTRAINT PK_Lights PRIMARY KEY CLUSTERED 
	(
		MessageId ASC,
		Order     ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.Lights WITH CHECK 
ADD CONSTRAINT FK_Messages_Lights 
	FOREIGN KEY(MessageId)
	REFERENCES dbo.Messages (MessageId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.Sounds(
	MessageId bigint       NOT NULL,
	Play      bit          NOT NULL,
	Name      nvarchar(50) NULL,
	Duration  smallint     NULL,
	CONSTRAINT PK_Sounds PRIMARY KEY CLUSTERED 
	(
		MessageId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.Sounds WITH CHECK 
ADD CONSTRAINT FK_Messages_Sounds 
	FOREIGN KEY(MessageId)
	REFERENCES dbo.Messages (MessageId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO


CREATE TABLE dbo.Switches(
	MessageId bigint  NOT NULL,
	Order     tinyint NOT NULL,
	State     bit     NOT NULL,
	CONSTRAINT PK_Switches PRIMARY KEY CLUSTERED 
	(
		MessageId ASC,
		Order     ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY
GO

ALTER TABLE dbo.Switches
ADD CONSTRAINT FK_Messages_Switches 
	FOREIGN KEY(MessageId)
	REFERENCES dbo.Messages (MessageId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.UpdateFrequencies(
	MessageId       bigint NOT NULL,
	UpdateFrequency int    NOT NULL,
	CONSTRAINT PK_UpdateFrequencies PRIMARY KEY CLUSTERED 
	(
		MessageId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY
GO

ALTER TABLE dbo.UpdateFrequencies
ADD CONSTRAINT FK_Messages_UpdateFrequencies 
	FOREIGN KEY(MessageId)
	REFERENCES dbo.Messages (MessageId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.Environment10MinuteAvgs(
	DeviceId       nvarchar(50)  NOT NULL,
	Interval       datetime      NOT NULL,
	AvgHumidity    decimal(4, 1) NOT NULL,
	AvgPressure    decimal(8, 1) NOT NULL,
	AvgTemperature decimal(4, 1) NOT NULL,
	CONSTRAINT PK_Environment10MinuteAvgs PRIMARY KEY CLUSTERED 
	(
		DeviceId ASC,
		Interval ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE TABLE dbo.ErrorLog(
	Timestamp  datetime          NOT NULL,
	Message    nvarchar(max)     NOT NULL,
	Error      int               NOT NULL,
	CONSTRAINT PK_ErrorLog PRIMARY KEY CLUSTERED 
	(
		Timestamp ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY TEXTIMAGE_ON PRIMARY
GO

ALTER TABLE dbo.ErrorLog 
ADD CONSTRAINT DF_ErrorLog_Timestamp
DEFAULT (getdate()) FOR Timestamp
GO
