-- ================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 8 April 2016
-- Description:	Creates all tables.
--
-- Change log:
-- 27 Apr 2016: PressureSeaLevel decimal(4, 1) -> decimal(6, 1).
--  2 May 2016: Added the Glossary table.
--  6 May 2016: Deprecated the SklyConditions table, added
--              the SkyConditions and SkyConditionsCleansed cols.
--
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================
IF OBJECT_ID('dbo.Glossary', 'U') IS NOT NULL
	DROP TABLE dbo.Glossary
GO

IF OBJECT_ID('dbo.Observations', 'U') IS NOT NULL
	DROP TABLE dbo.Observations
GO

IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL
	DROP TABLE dbo.Locations
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Locations](
	[LocationCode]  [nchar](4)     NOT NULL,
	[Location]      [nvarchar](80) NOT NULL,
	[State]         [nchar](2)     NOT NULL,
	[PostalCode]    [nvarchar](10) NOT NULL
	CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED 
	(
		[LocationCode] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Observations](
	[ObservationId]          [bigint]        NOT NULL,
	[LocationCode]           [nchar](4)      NOT NULL,
	[ObservedOn]             [datetime]      NOT NULL,
	[Wind]                   [nvarchar](20)  NOT NULL,
	[Visibility]             [decimal](4, 1) NULL,
	[Weather]                [nvarchar](50)  NOT NULL,
	[SkyConditions]          [nvarchar](50)  NULL,
	[TemperatureAir]         [decimal](4, 1) NULL,
	[Dewpoint]               [decimal](4, 1) NULL,
	[RelativeHumidity]       [decimal](4, 1) NULL,
	[WindChill]              [decimal](4, 1) NULL,
	[HeatIndex]              [decimal](4, 1) NULL,
	[PressureAltimeter]      [decimal](4, 2) NULL,
	[PressureSeaLevel]       [decimal](6, 1) NULL,
	[Precipitation1hr]       [decimal](4, 1) NULL,
	[Precipitation3hr]       [decimal](4, 1) NULL,
	[Precipitation6hr]       [decimal](4, 1) NULL,
	[SkyConditionsCleansed]  [nvarchar](50)  NULL,
	CONSTRAINT [PK_Observations] PRIMARY KEY CLUSTERED 
	(
		[ObservationId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

CREATE NONCLUSTERED INDEX [IX_Observations_LocationCode] 
ON [dbo].[Observations]
(
	[LocationCode] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_Observations_ObservedOn] 
ON [dbo].[Observations]
(
	[ObservedOn] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER TABLE [dbo].[Observations] WITH CHECK 
ADD CONSTRAINT [FK_Observations_Locations] 
	FOREIGN KEY([LocationCode])
	REFERENCES [dbo].[Locations] ([LocationCode])
	ON UPDATE CASCADE
	ON DELETE CASCADE
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
