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
FlattenedEvent AS
(
    SELECT
		IoTHub.ConnectionDeviceId as deviceId,
		EventEnqueuedUtcTime as Time,
		temperature
    FROM sensordata 
),
PreviousEvent AS
(
    SELECT
		LAG(deviceId,1,0) OVER(LIMIT DURATION(ss, 11)) as deviceId,
		LAG(Time,1,0) OVER(LIMIT DURATION(ss, 11)) as Time,
		LAG(temperature,1,0) OVER(LIMIT DURATION(ss, 11)) as temperature
    FROM FlattenedEvent 
)
SELECT
    averages.deviceId as deviceId,
	averages.time as EndTimeOfAverageWindow,
	averages.avgtemp,
	sensordata.temperature as TriggerTemp,
	sensordata.EventEnqueuedUtcTime AS CurrentEventTime,
	PreviousEvent.temperature as PreviousTemp,
	PreviousEvent.Time as PreviousTime,
	CONCAT(averages.deviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
	CASE
		WHEN ((sensordata.temperature - averages.avgtemp) > 5) THEN 'red'
		WHEN ((sensordata.temperature - averages.avgtemp) > 3) THEN 'green'
		WHEN ((sensordata.temperature - averages.avgtemp) > 1) THEN 'blue'
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
    ON DATEDIFF(ss, PreviousEvent, sensordata) between 1 and 6
        AND sensordata.IoTHub.ConnectionDeviceId = PreviousEvent.deviceId	
JOIN averages 
    ON DATEDIFF(ss, averages, sensordata) between 1 and 6
    AND sensordata.IoTHub.ConnectionDeviceId = averages.deviceId 
WHERE
	(sensordata.temperature - averages.avgtemp > 1 ) OR ((PreviousEvent.temperature - averages.avgtemp) > 1)