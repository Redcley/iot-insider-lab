DELETE Impressions;
DECLARE	@return_value int;
DECLARE @test NVARCHAR(4000) =
	'{' + 
		'"messageType" : "impression",' + 
		'"deviceId": "CFF56B1B-508B-46EC-AFDC-E287188B2840",' + 
		'"timestamp": "2016-08-18T10:03:00.000Z",' +
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';
EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Duplicate machineId and timestamp:
SET @test =
	'{' + 
		'"messageType" : "impression",' + 
		'"deviceId": "CFF56B1B-508B-46EC-AFDC-E287188B2840",' + 
		'"timestamp": "2016-08-18T10:03:00.000Z",' +
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Missing messageType:
SET @test =
	'{' + 
		'"deviceId": "CFF56B1B-508B-46EC-AFDC-E287188B2840",' + 
		'"timestamp": "' + CAST(GETDATE() AS VARCHAR(20)) + '",' +
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Missing deviceId:
SET @test =
	'{' + 
		'"messageType" : "impression",' + 
		'"timestamp": "' + CAST(GETDATE() AS VARCHAR(20)) + '",' +
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Missing deviceId:
SET @test =
	'{' + 
		'"messageType" : "impression",' + 
		'"timestamp": "' + CAST(GETDATE() AS VARCHAR(20)) + '",' +
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Missing messageId:
SET @test =
	'{' + 
		'"messageType" : "impression",' + 
		'"deviceId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' + 
		'"timestamp": "' + CAST(GETDATE() AS VARCHAR(20)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Missing timestamp:
SET @test =
	'{' + 
		'"messageType" : "impression",' + 
		'"deviceId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' + 
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2",' + 
		'"faces": [' + 
			'{ ' + 
				'"age": 44,' + 
				'"gender": "Male",' + 
				'"faceRectangle": {' + 
					'"left": 593, ' + 
					'"top": 160, ' + 
					'"width": 250, ' +
					'"height": 250 ' +
				'},' + 
				'"scores": { ' +
					'"anger": 0.10040836,' + 
					'"contempt": 0.004295743,' +
					'"disgust": 0.7166687, ' +
					'"fear": 0.000008211285, ' +
					'"happiness": 1.18347288e-7, ' +
					'"neutral": 0.00252671982, ' +
					'"sadness": 0.176079035, ' +
					'"surprise": 0.0000130839826 ' +
				'} ' +
			'}, ' +
			'{ ' +
				'"age": 44, ' +
				'"gender": "Male", ' +
				'"faceRectangle": { ' +
					'"left": 593, ' +
					'"top": 160, ' +
					'"width": 250, ' +
					'"height": 250 ' +
				'} ' +
			'} ' +
		'] ' +
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

-- Missing faces:
SET @test =
	'{' + 
		'"messageType" : "impression",' + 
		'"deviceId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' + 
		'"timestamp": "' + CAST(GETDATE() AS VARCHAR(20)) + '",' +
		'"messageId": "' + CAST(NEWID() AS NVARCHAR(50)) + '",' +
		'"displayedAdId": "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F2"' + 
	'} ';

EXEC	@return_value = [dbo].[PersistImpression] @json = @test
SELECT	'Return Value' = @return_value

