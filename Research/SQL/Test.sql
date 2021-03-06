TRUNCATE TABLE ErrorLog

DELETE  [Messages]
DECLARE	@return_value int
EXEC	@return_value = [dbo].[Persist]
		-- Common attributes
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
		
		-- Config and Status
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "config" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "config", "environmentUpdateFrequency": "" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "config", "environmentUpdateFrequency": "XYZ" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "config", "environmentUpdateFrequency": 123 }'
		
		-- Environment and Status
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": "XYZ" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": 12.3 }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": 12.3, "pressure": "XYZ" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": 12.3, "pressure": 1234.5 }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": 12.3, "pressure": 1234.5, "temperature": "XYZ" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": "XYZ", "pressure": 1234.5, "temperature": 12.34 }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": 12.3, "pressure": 1234.5, "temperature": 12.34 }'

		-- Test of the single JSON type:
		-- 1. Change the type of 'humidity' in Attributes to JSON (4).
		-- 2. Run the following:
		--    @message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": 12.3 }'  -- not JSON
		--    @message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "environment", "humidity": {"attribute" : "value"} }'  -- valid JSON
		-- 3. Revert the type of 'humidity' back to decimal (2). 

		-- Input and Status
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "input", "dials": "[]" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "input", "dials": "[123.45]" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "input", "dials": "[123.45,678.90]" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "input", "dials": "[123.45,678.90]", "switches": "[]" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "input", "dials": "[123.45,678.90]", "switches": "[true]" }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "input", "dials": "[123.45,678.90]", "switches": "[true,false]" }'
		
		-- Output and Status
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [] }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":true,"color":"red"}] }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"}] }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"}] }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}] }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":true,"name":"alarm"} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":false} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":false,"name":"alarm"} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":false,"duration":33} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":false,"name":"alarm","duration":33} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":true} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":true,"name":"alarm"} }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "output", "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], "sound":{"play":true,"name":"alarm","duration":33} }'

		-- Status
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status", 
		--               "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], 
		--			     "sound":{"play":true,"name":"alarm","duration":33} 
		--             }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status",
		--               "humidity": 12.3, "pressure": 1234.5, "temperature": 12.34,
		--               "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], 
		--			   "sound":{"play":true,"name":"alarm","duration":33}, 
		--			   "environmentUpdateFrequency": 123
		--			 }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status",
		--               "humidity": 12.3, "pressure": 1234.5, "temperature": 12.34,
		--			   "dials": [123.45,678.90],
		--               "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], 
		--			   "sound":{"play":true,"name":"alarm","duration":33}, 
		--			   "environmentUpdateFrequency": 123
		--			 }'
		--@message = N'{ "messageId": "aa4ef94c-1122-456f-93e1-73a4559d8360", "datestamp": "2016-04-28T09:38:00Z", "deviceId": "JansTest", "response": "status",
		--               "humidity": 12.3, "pressure": 1234.5, "temperature": 12.34,
		--			   "dials": [123.45,678.90],
		--               "lights": [{"power":false,"color":"red"},{"power":true,"color":"green"},{"power":false,"color":"blue"}], 
		--			   "sound":{"play":true,"name":"alarm","duration":33}, 
		--			   "switches": [true,false],
		--			   "environmentUpdateFrequency": 123
		--			 }'

SELECT	'Return Value' = @return_value

GO
