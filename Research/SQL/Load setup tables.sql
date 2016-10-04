-- =================================================================
-- Author:		Jan Machat (Redcley LLC)
-- Create date: 13 June 2016
-- Description:	Loads all four setup tables.
-- Copyright © 2016 by Microsoft Corporation. All rights reserved.
-- =================================================================

-- WARNING: THIS DELETES THE ENTIRE CONTENT OF THE DATABASE.

DELETE AttributeTypes
GO
DELETE MessageTypes
GO

-- General tables ==================================================

-- This will allow us to define types by name.
DECLARE @attTypeString  SMALLINT = 0,
        @attTypeInteger SMALLINT = 1,
		@attTypeDecimal SMALLINT = 2,
		@attTypeBit     SMALLINT = 3,
		@attTypeJSON    SMALLINT = 4
;
INSERT INTO AttributeTypes
	([AttributeType]
	,[Description])
VALUES
	 (@attTypeString,  'string')
	,(@attTypeInteger, 'integer')
	,(@attTypeDecimal, 'decimal')
	,(@attTypeBit,     'bit')
	,(@attTypeJSON,    'json')
;
-- Business domain-specific tables =================================

DECLARE @msgTypeEnvironment SMALLINT = 0,
        @msgTypeInput       SMALLINT = 1,
        @msgTypeStatus      SMALLINT = 2,
        @msgTypeOutput      SMALLINT = 3,
        @msgTypeConfig      SMALLINT = 4
;
INSERT INTO MessageTypes
	([MessageType]
	,[Description])
VALUES
	 (@msgTypeEnvironment, 'environment')
	,(@msgTypeInput,       'input')
	,(@msgTypeStatus,      'status')
	,(@msgTypeOutput,      'output')
	,(@msgTypeConfig,      'config')
;
DECLARE @attributeHumidity     SMALLINT = 0,
        @attributePressure     SMALLINT = 1,
		@attributeTemperature  SMALLINT = 2,
		@attributeUpdateFreq   SMALLINT = 3,
		@attributeDials        SMALLINT = 4,
		@attributeSwitches     SMALLINT = 5,
		@attributeLights       SMALLINT = 6,
		@attributeSound        SMALLINT = 7
;
INSERT INTO Attributes
	([AttributeId]
	,[AttributeType]
	,[Name]
	,[IsArray])
VALUES
	 (@attributeHumidity,     @attTypeDecimal, 'humidity',        0)
	,(@attributePressure,     @attTypeDecimal, 'pressure',        0)
	,(@attributeTemperature,  @attTypeDecimal, 'temperature',     0)
	,(@attributeDials,        @attTypeDecimal, 'dials',           1)
	,(@attributeSwitches,     @attTypeBit,     'switches',        1)
	,(@attributeLights,       @attTypeJSON,    'lights',          1)
	,(@attributeSound,        @attTypeJSON,    'sound',           0)
	,(@attributeUpdateFreq,   @attTypeInteger, 'environmentUpdateFrequency', 0)
;
INSERT INTO MessageTypeAttributes
	([MessageTypeAttributesId]
	,[MessageType]
	,[AttributeId]
	,[Path]
	,[IsMandatory])
VALUES
	 (0, @msgTypeEnvironment, @attributeHumidity,    '$.humidity',    0)
	,(1, @msgTypeEnvironment, @attributePressure,    '$.pressure',    0)
	,(2, @msgTypeEnvironment, @attributeTemperature, '$.temperature', 0)

	,(4, @msgTypeInput,       @attributeDials,       '$.dials',       0)
	,(5, @msgTypeInput,       @attributeSwitches,    '$.switches',    0)

	,(6,  @msgTypeStatus,     @attributeHumidity,    '$.humidity',    0)
	,(7,  @msgTypeStatus,     @attributePressure,    '$.pressure',    0)
	,(8,  @msgTypeStatus,     @attributeTemperature, '$.temperature', 0)
	,(9,  @msgTypeStatus,     @attributeDials,       '$.dials',       0)
	,(10, @msgTypeStatus,     @attributeSwitches,    '$.switches',    0)
	,(11, @msgTypeStatus,     @attributeLights,      '$.lights',      0)
	,(12, @msgTypeStatus,     @attributeSound,       '$.sound',       0)
	,(13, @msgTypeStatus,     @attributeUpdateFreq,  '$.environmentUpdateFrequency', 0)

	,(14, @msgTypeOutput,     @attributeLights,      '$.lights',      0)
	,(15, @msgTypeOutput,     @attributeSound,       '$.sound',       0)

	,(16, @msgTypeConfig,     @attributeUpdateFreq,  '$.environmentUpdateFrequency', 1)

GO
