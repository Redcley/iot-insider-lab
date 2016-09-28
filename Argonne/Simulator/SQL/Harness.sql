DECLARE @json NVARCHAR(4000) =
	'{' + 
		'"messageType" : "impression",' + 
		'"deviceId": "<guid>",' + 
		'"timestamp": "2016-08-18T10:03:00.000Z",' +
		'"messageId": "<guid>",' +
		'"displayedAdId": "<guid>",' + 
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
	'} '
;
	DECLARE @faces NVARCHAR(4000) = JSON_QUERY(@json, '$.faces')
	;
	SET @faces = REPLACE(@faces, '[', '')
	SET @faces = REPLACE(@faces, ']', '')
	;
	-- We will massage JSON to make for the DelimitedSplit4K function.
	-- We will make sure that there are no spaces between curly brackets.
	WHILE CHARINDEX(' {', @faces) > 0
		SET @faces = REPLACE(@faces, ' {', '{')
	;
	-- We separate faces by verical bars.
	SET @faces = REPLACE(@faces, '},{', '}|{')
	;
	-- Now we can do the split.
	DECLARE @split TABLE
	(
		 Sequence BIGINT
		,Face     NVARCHAR(1000)
	);
	INSERT INTO @split
	SELECT *
	FROM   dbo.DelimitedSplit4K(@faces, '|')
	;
	declare @impressionId int = 1;
		SELECT @impressionId
			  ,Sequence
			  ,JSON_VALUE(Face, '$.age')
			  ,JSON_VALUE(Face, '$.gender')
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.anger')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.anger'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.contempt')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.contempt'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.disgust')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.disgust'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.fear')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.fear'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.happiness')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.happiness'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.neutral')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.neutral'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.sadness')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.sadness'), 3), NULL)
			  ,IIF(LEN(JSON_VALUE(Face, '$.scores.surprise')) > 0, CONVERT(float, JSON_VALUE(Face, '$.scores.surprise'), 3), NULL)
		FROM @split AS s
