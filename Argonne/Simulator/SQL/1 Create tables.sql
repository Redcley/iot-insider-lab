-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 15 August 2016
-- Description:	Creates all Argonne tables.
--
-- Change log:
-- 31 Aug 2016  jm Added FacesForImpressions.FaceId.
--
-- MIT License Copyright © 2016 by Microsoft Corporation.
-- ==================================================================

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- ------------------------------------------------------------------
-- Drop tables
-- ------------------------------------------------------------------

-- If we do not want to drop all constraints individually, ----------
-- this has to be done in correct order. ----------------------------
DROP TABLE IF EXISTS dbo.BiasesForAds
GO
DROP TABLE IF EXISTS dbo.BiasesForDevices
GO
DROP TABLE IF EXISTS dbo.ErrorLog
GO
DROP TABLE IF EXISTS dbo.FacesForImpressions
GO
DROP TABLE IF EXISTS dbo.Impressions
GO
DROP TABLE IF EXISTS dbo.AdsForCampaigns
GO
DROP TABLE IF EXISTS dbo.Ads
GO
DROP TABLE IF EXISTS dbo.Campaigns
GO
DROP TABLE IF EXISTS dbo.Devices
GO

-- ------------------------------------------------------------------
-- Set-up tables
-- ------------------------------------------------------------------

-- Devices ----------------------------------------------------------
CREATE TABLE dbo.Devices
(
	DeviceId           uniqueidentifier NOT NULL,
	PrimaryKey         nvarchar(100)    NOT NULL,
	DeviceName         nvarchar(100)    NOT NULL,
	Address            nvarchar(100)    NOT NULL,
	Address2           nvarchar(100)    NOT NULL,
	Address3           nvarchar(100)    NOT NULL,
	City               nvarchar(100)    NOT NULL,
	StateProvince      nvarchar(50)     NOT NULL,
	PostalCode         nvarchar(50)     NOT NULL,
	ActiveFrom         datetime             NULL,
	ActiveTo           datetime             NULL,
	Timezone           varchar(3)           NULL,
	AssignedCampaignId uniqueidentifier     NULL,
	CONSTRAINT PK_Devices PRIMARY KEY CLUSTERED 
	(
		DeviceId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.Devices
ADD  CONSTRAINT [FK_Devices_Campaigns] FOREIGN KEY([AssignedCampaignId])
REFERENCES [dbo].[Campaigns] ([CampaignId])
GO

CREATE NONCLUSTERED INDEX IX_Devices_AssignedCampaignId ON dbo.Devices
(
	AssignedCampaignId ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Devices_PostalCode ON dbo.Devices
(
	PostalCode ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

-- Campaigns --------------------------------------------------------
CREATE TABLE dbo.Campaigns
(
	CampaignId	 uniqueidentifier NOT NULL,
	CampaignName nvarchar(100)    NOT NULL,
	CONSTRAINT PK_Campaigns PRIMARY KEY CLUSTERED 
	(
		CampaignId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

-- Ads --------------------------------------------------------------
CREATE TABLE dbo.Ads
(
	AdId   uniqueidentifier NOT NULL,
	AdName nvarchar(100)    NOT NULL,
	URL    nvarchar(200)    NOT NULL,
	CONSTRAINT PK_Advertisements PRIMARY KEY CLUSTERED 
	(
		AdId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE NONCLUSTERED INDEX IX_Ads_Name ON dbo.Ads
(
	AdName ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

-- AdsForCampaigns --------------------------------------------------
CREATE TABLE dbo.AdsForCampaigns
(
	CampaignId         uniqueidentifier NOT NULL,
	AdId               uniqueidentifier NOT NULL,
	Sequence           smallint         NOT NULL,
	Duration           smallint         NOT NULL,
	FirstImpression    smallint         NOT NULL,
	ImpressionInterval smallint         NOT NULL,
	CONSTRAINT PK_AdsForCampaigns PRIMARY KEY CLUSTERED 
	(
		CampaignId ASC,
		AdId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.AdsForCampaigns
ADD CONSTRAINT FK_AdsForCampaigns_Ads FOREIGN KEY(AdId)
REFERENCES dbo.Ads (AdId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE dbo.AdsForCampaigns
ADD CONSTRAINT FK_AdsForCampaigns_Campaigns FOREIGN KEY(CampaignId)
REFERENCES dbo.Campaigns (CampaignId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

-- ------------------------------------------------------------------
-- Business data tables
-- ------------------------------------------------------------------

-- Impressions ------------------------------------------------------
CREATE TABLE dbo.Impressions
(
	ImpressionId    bigint identity(1,1) NOT NULL,
	DeviceId        uniqueidentifier     NOT NULL,
	MessageId       uniqueidentifier     NOT NULL,
	CampaignAdId    uniqueidentifier     NOT NULL,
	MessageId       uniqueidentifier     NOT NULL,
	DeviceTimestamp datetime             NOT NULL,
	InsertTimestamp datetime             NOT NULL,
	CONSTRAINT PK_Impressions PRIMARY KEY CLUSTERED 
	(
		ImpressionId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.Impressions 
ADD CONSTRAINT DF_Impressions_InsertTimestamp DEFAULT (getdate()) FOR InsertTimestamp
GO

ALTER TABLE dbo.Impressions
ADD CONSTRAINT FK_Impressions_Ads FOREIGN KEY(DisplayedAdId)
REFERENCES dbo.Ads (AdId)
ON DELETE CASCADE
GO

ALTER TABLE dbo.Impressions
ADD CONSTRAINT FK_Impressions_Campaigns FOREIGN KEY(CampaignId)
REFERENCES dbo.Campaigns (CampaignId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE dbo.Impressions
ADD CONSTRAINT FK_Impressions_Devices FOREIGN KEY(DeviceId)
REFERENCES dbo.Devices (DeviceId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE NONCLUSTERED INDEX IX_Impressions_CampaignId ON dbo.Impressions
(
	CampaignId ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Impressions_Covering ON dbo.Impressions
(
	CampaignId ASC,
	DeviceTimestamp ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Impressions_DeviceId ON dbo.Impressions
(
	DeviceId ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Impressions_DeviceTimestamp ON dbo.Impressions
(
	DeviceTimestamp ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Impressions_DisplayedAdId ON dbo.Impressions
(
	DisplayedAdId ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX IX_Impressions_MessageId ON dbo.Impressions
(
	MessageId ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

-- FacesForImpressions ----------------------------------------------
CREATE TABLE dbo.FacesForImpressions(
	ImpressionId   bigint       NOT NULL,
	Sequence       smallint     NOT NULL,
	FaceId         varchar(50)  NOT NULL,
	Age            smallint     NOT NULL,
	Gender         nvarchar(12) NOT NULL,
	ScoreAnger     decimal(18, 15)  NULL,
	ScoreContempt  decimal(18, 15)  NULL,
	ScoreDisgust   decimal(18, 15)  NULL,
	ScoreFear      decimal(18, 15)  NULL,
	ScoreHappiness decimal(18, 15)  NULL,
	ScoreNeutral   decimal(18, 15)  NULL,
	ScoreSadness   decimal(18, 15)  NULL,
	ScoreSurprise  decimal(18, 15)  NULL,
	CONSTRAINT PK_FacesForImpressions PRIMARY KEY CLUSTERED 
	(
		ImpressionId ASC,
		Sequence ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE NONCLUSTERED INDEX IX_FacesForImpressions_Age ON dbo.FacesForImpressions
(
	Age ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_FacesForImpressions_FaceId] ON [dbo].[FacesForImpressions]
(
	[FaceId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE dbo.FacesForImpressions 
ADD CONSTRAINT FK_FacesForImpressions_Impressions FOREIGN KEY(ImpressionId)
REFERENCES dbo.Impressions (ImpressionId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

-- ------------------------------------------------------------------
-- Error log
-- ------------------------------------------------------------------

CREATE TABLE dbo.ErrorLog
(
	Timestamp datetime       NOT NULL,
	JSON      nvarchar(4000) NOT NULL,
	Error     nvarchar (200) NOT NULL,
	CONSTRAINT PK_ErrorLog PRIMARY KEY CLUSTERED 
	(
		Timestamp ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.ErrorLog
ADD CONSTRAINT DF_ErrorLog_Timestamp DEFAULT (GETDATE()) FOR Timestamp
GO

-- ------------------------------------------------------------------
-- Simulated devices
-- ------------------------------------------------------------------
CREATE TABLE dbo.BiasesForDevices(
	DeviceId      uniqueidentifier NOT NULL,
	ShadowName    nvarchar(100)    NOT NULL,
	CampaignId	  uniqueidentifier NOT NULL,
	CountBias     float            NOT NULL,
	AngerBias     float            NOT NULL,
	ContemptBias  float            NOT NULL,
	DisgustBias   float            NOT NULL,
	FearBias      float            NOT NULL,
	HappinessBias float            NOT NULL,
	NeutralBias   float            NOT NULL,
	SadnessBias   float            NOT NULL,
	SurpriseBias  float            NOT NULL,
	CONSTRAINT PK_BiasesForDevices PRIMARY KEY CLUSTERED 
	(
		DeviceId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE [dbo].[BiasesForDevices]
ADD CONSTRAINT [DF_BiasesForDevices_CountBias] DEFAULT ((1)) FOR [CountBias]
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_AngerBias DEFAULT ((0.125)) FOR AngerBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_ContemptBias DEFAULT ((0.125)) FOR ContemptBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_DisgustBias DEFAULT ((0.125)) FOR DisgustBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD  CONSTRAINT DF_BiasesForDevices_FearBias DEFAULT ((0.125)) FOR FearBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_HappinessBias DEFAULT ((0.125)) FOR HappinessBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_NeutralBias DEFAULT ((0.125)) FOR NeutralBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_SadnessBias DEFAULT ((0.125)) FOR SadnessBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT DF_BiasesForDevices_SurpriseBias DEFAULT ((0.125)) FOR SurpriseBias
GO

ALTER TABLE dbo.BiasesForDevices
ADD CONSTRAINT FK_BiasesForDevices_Devices FOREIGN KEY(DeviceId)
REFERENCES dbo.Devices (DeviceId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO

CREATE TABLE dbo.BiasesForAds(
	AdId          uniqueidentifier NOT NULL,
	ShadowName    nvarchar(100)    NOT NULL,
	AngerBias     float            NOT NULL,
	ContemptBias  float            NOT NULL,
	DisgustBias   float            NOT NULL,
	FearBias      float            NOT NULL,
	HappinessBias float            NOT NULL,
	NeutralBias   float            NOT NULL,
	SadnessBias   float            NOT NULL,
	SurpriseBias  float            NOT NULL,
	CONSTRAINT PK_BiasesForAds PRIMARY KEY CLUSTERED 
	(
		AdId ASC
	)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_AngerBias  DEFAULT ((1.0)) FOR AngerBias
GO

ALTER TABLE dbo.BiasesForAds 
ADD CONSTRAINT DF_BiasesForAds_ContemptBias  DEFAULT ((1.0)) FOR ContemptBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_DisgustBias  DEFAULT ((1.0)) FOR DisgustBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_FearBias  DEFAULT ((1.0)) FOR FearBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_HappinessBias  DEFAULT ((1.0)) FOR HappinessBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_NeutralBias  DEFAULT ((1.0)) FOR NeutralBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_SadnessBias  DEFAULT ((1.0)) FOR SadnessBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT DF_BiasesForAds_SurpriseBias  DEFAULT ((1.0)) FOR SurpriseBias
GO

ALTER TABLE dbo.BiasesForAds
ADD CONSTRAINT FK_BiasesForAds_Ads FOREIGN KEY(AdId)
REFERENCES dbo.Ads (AdId)
ON UPDATE CASCADE
ON DELETE CASCADE
GO
