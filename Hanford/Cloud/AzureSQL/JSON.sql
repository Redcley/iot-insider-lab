USE [IoTLabHanford]
GO

DELETE  Messages
DECLARE	@return_value int
EXEC	@return_value = [dbo].[PersistJSON]
		--@message = N'{ "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "XYZef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "XYZ-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "XYZ" }'
		-- Tested handling of duplicates
		@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status" }'

SELECT	'Return Value' = @return_value

GO
