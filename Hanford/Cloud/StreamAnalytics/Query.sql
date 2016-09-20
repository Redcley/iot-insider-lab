WITH averages AS
(
    SELECT 
        IoTHub.ConnectionDeviceId as deviceId,
        AVG(temperature) as avgtemp,
        CONCAT(IoTHub.ConnectionDeviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
        System.TimeStamp AS Time
    FROM iotlabdemo
    GROUP BY SlidingWindow(mi, 5), IoTHub.ConnectionDeviceId
),

PreviousEvent AS
(
    SELECT
		IoTHub.ConnectionDeviceId as deviceId,
		LAST(temperature) OVER(LIMIT DURATION(ss, 11)) as temperature
    FROM iotlabdemo
)

SELECT
    averages.deviceId as deviceId,
	averages.time,
	averages.avgtemp,
	iotlabdemo.temperature as TriggerTemp,
	CONCAT(averages.deviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
	CASE
		WHEN ((iotlabdemo.temperature - averages.avgtemp) > 5) AND ((PreviousEvent.temperature  - averages.avgtemp) <= 5) THEN 'red'
		WHEN ((iotlabdemo.temperature - averages.avgtemp) > 3) AND ((PreviousEvent.temperature - averages.avgtemp) <= 3) THEN 'green'
		WHEN ((iotlabdemo.temperature - averages.avgtemp) > 1) AND ((PreviousEvent.temperature - averages.avgtemp) <= 1) THEN 'blue'
		WHEN ((iotlabdemo.temperature - averages.avgtemp) < 5) AND ((PreviousEvent.temperature  - averages.avgtemp) >= 5) THEN 'green'
		WHEN ((iotlabdemo.temperature - averages.avgtemp) < 3) AND ((PreviousEvent.temperature - averages.avgtemp) >= 3) THEN 'blue'	
		ELSE 'off'
	END as Color,
	CASE
		WHEN (iotlabdemo.temperature - averages.avgtemp > 1) THEN 'true'
		ELSE 'false'
	END as Power
INTO
    hotpath
FROM
    iotlabdemo
JOIN PreviousEvent 
    ON DATEDIFF(ss, iotlabdemo, PreviousEvent) between 0 and 6
        AND iotlabdemo.IoTHub.ConnectionDeviceId = PreviousEvent.deviceId
JOIN averages 
    ON DATEDIFF(ms, iotlabdemo, averages) = 0 
    AND iotlabdemo.IoTHub.ConnectionDeviceId = averages.deviceId 
WHERE
	(iotlabdemo.temperature - averages.avgtemp > 1 ) OR ((PreviousEvent.temperature - averages.avgtemp) > 1)