WITH averages AS
(
    SELECT 
        IoTHub.ConnectionDeviceId as deviceId,
        AVG(temperature) as avgtemp,
        CONCAT(IoTHub.ConnectionDeviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
        System.TimeStamp AS Time
    FROM sensordata
    GROUP BY SlidingWindow(mi, 5), IoTHub.ConnectionDeviceId
),

PreviousEvent AS
(
    SELECT
		IoTHub.ConnectionDeviceId as deviceId,
		LAST(temperature) OVER(LIMIT DURATION(ss, 11)) as temperature
    FROM sensordata
)

SELECT
    averages.deviceId as deviceId,
	averages.time,
	averages.avgtemp,
	sensordata.temperature as TriggerTemp,
	CONCAT(averages.deviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
	CASE
		WHEN ((sensordata.temperature - averages.avgtemp) > 5) AND ((PreviousEvent.temperature  - averages.avgtemp) <= 5) THEN 'red'
		WHEN ((sensordata.temperature - averages.avgtemp) > 3) AND ((PreviousEvent.temperature - averages.avgtemp) <= 3) THEN 'green'
		WHEN ((sensordata.temperature - averages.avgtemp) > 1) AND ((PreviousEvent.temperature - averages.avgtemp) <= 1) THEN 'blue'
		WHEN ((sensordata.temperature - averages.avgtemp) < 5) AND ((PreviousEvent.temperature  - averages.avgtemp) >= 5) THEN 'green'
		WHEN ((sensordata.temperature - averages.avgtemp) < 3) AND ((PreviousEvent.temperature - averages.avgtemp) >= 3) THEN 'blue'	
		ELSE 'off'
	END as Color,
	CASE
		WHEN (sensordata.temperature - averages.avgtemp > 1) THEN 'true'
		ELSE 'false'
	END as Power
INTO
    alerts
FROM
    sensordata
JOIN PreviousEvent 
    ON DATEDIFF(ss, sensordata, PreviousEvent) between 0 and 6
        AND sensordata.IoTHub.ConnectionDeviceId = PreviousEvent.deviceId
JOIN averages 
    ON DATEDIFF(ms, sensordata, averages) = 0 
    AND sensordata.IoTHub.ConnectionDeviceId = averages.deviceId 
WHERE
	(sensordata.temperature - averages.avgtemp > 1 ) OR ((PreviousEvent.temperature - averages.avgtemp) > 1)