USE [IoTLabHanford]
GO

DELETE Messages
;
DECLARE	@return_value int

/*
EXEC	@return_value = [dbo].[PersistConfig]
		@messageGUID = N'0fe3c91a-778f-41e2-8d4e-2bf241a1b275',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 12:22',
		@updateFrequency = N'30'

SELECT * FROM Messages m LEFT JOIN UpdateFrequencies u ON m.MessageId = u.MessageId

EXEC	@return_value = [dbo].[PersistEnvironment]
		@messageGUID = N'5cd1bd25-bd39-4411-99e1-ff0a6b5a69dc',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 12:41',
		@humidity = N'1',
		@pressure = N'2',
		@temperature = N'3'

SELECT * FROM Messages m LEFT JOIN Environments e ON m.MessageId = e.MessageId

EXEC	@return_value = [dbo].[PersistInput]
		@messageGUID = N'ab5dbb62-a84d-455f-9d68-588583d03e2a',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 12:47',
		@dials = N'',
		@switches = N''

EXEC	@return_value = [dbo].[PersistInput]
		@messageGUID = N'90459c57-c854-4751-b1ab-6d32b47beec9',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 12:55',
		@dials = N'[1,2]',
		@switches = N'[false,true]'

SELECT * FROM Messages m LEFT JOIN Dials d ON m.MessageId = d.MessageId
SELECT * FROM Messages m LEFT JOIN Switches s ON m.MessageId = s.MessageId

EXEC	@return_value = [dbo].[PersistOutput]
		@messageGUID = N'baf527f4-aea1-4e21-a56e-723ba2e19f0a',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 13:01',
		@soundPlay = N'',
		@soundName = N'',
		@soundDuration = N'',
		@lights = N''

EXEC	@return_value = [dbo].[PersistOutput]
		@messageGUID = N'645c9482-aede-4bff-a1fa-d722e525689c',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 13:02',
		@soundPlay = N'false',
		@soundName = N'',
		@soundDuration = N'',
		@lights = N''

EXEC	@return_value = [dbo].[PersistOutput]
		@messageGUID = N'8e8dc1cd-3f0e-4e2e-b4c2-f516720d962e',
		@deviceId = N'JansTest',
		@timestamp = N'2016-04-20 13:03',
		@soundPlay = N'true',
		@soundName = N'Reveille',
		@soundDuration = N'30',
		@lights = N'":[{"power":false},{"power":true,"color":magenta'

SELECT * FROM Messages m LEFT JOIN Sounds s ON m.MessageId = s.MessageId
SELECT * FROM Messages m LEFT JOIN Lights l ON m.MessageId = l.MessageId
*/

SELECT	'Return Value' = @return_value

/*
7	aa4ef94c-1122-456f-93e1-73a4559d8360	seank-fake	2016-04-19 18:15:36.093	0
8	b1aabaa7-6281-40cb-af50-4e513304894c	seank-fake	2016-04-19 18:15:41.090	0
9	9c03185d-0895-4b27-b85f-b7637b8c1a1c	seank-fake	2016-04-19 18:15:46.107	0
10	7f32acea-6a64-45df-976d-66d63b518ae7	seank-fake	2016-04-19 18:15:51.107	0
11	f6cb0fc5-f36d-43a1-b179-06788065a9f8	seank-fake	2016-04-19 18:15:56.107	0
12	bc63650f-d907-41a7-873c-9da4b229b242	seank-fake	2016-04-19 18:16:01.113	0
13	f5429d20-17ec-469b-944e-ef0716ded79b	seank-fake	2016-04-19 18:16:06.127	0
14	ce574321-8203-4162-a697-16b38be0ac2a	seank-fake	2016-04-19 18:16:11.120	0
15	3c834373-995e-428b-969f-44608bcdd7d1	seank-fake	2016-04-19 18:16:16.127	0
16	1da31d63-a564-490b-99db-f13fae1b620e	seank-fake	2016-04-19 18:16:21.143	0
17	a9e58a25-03a9-45a7-a28d-902ac620a376	seank-fake	2016-04-19 18:16:26.143	0
*/