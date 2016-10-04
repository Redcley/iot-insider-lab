WITH averages AS
(
    SELECT 
        IoTHub.ConnectionDeviceId as deviceId,
        AVG(temperature) as avgtemp,
        CONCAT(IoTHub.ConnectionDeviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
        System.TimeStamp AS Time
    FROM sensordata Timestamp by EventEnqueuedUtcTime
    GROUP BY SlidingWindow(mi, 5), IoTHub.ConnectionDeviceId
),
FlattenedEvent AS
(
    SELECT
		IoTHub.ConnectionDeviceId as deviceId,
		System.TimeStamp as Time,
		temperature
    FROM sensordata Timestamp by EventEnqueuedUtcTime
),
--The FlattenedEvent CTE is used because LAG() does not like nested fields
PreviousEvent AS
(
    SELECT
		LAG(deviceId,1,0) OVER(PARTITION BY deviceId LIMIT DURATION(ss, 11)) as deviceId,
		--LAG(Time,1,0) OVER(PARTITION BY deviceId LIMIT DURATION(ss, 11)) as Time,
        Time,
		LAG(temperature,1,0) OVER(PARTITION BY deviceId LIMIT DURATION(ss, 11)) as temperature
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
		WHEN ((sensordata.temperature - averages.avgtemp) > CAST(reference.tolerance_high as float)) THEN 'red'
		WHEN ((sensordata.temperature - averages.avgtemp) > CAST(reference.tolerance_med as float)) THEN 'green'
		WHEN ((sensordata.temperature - averages.avgtemp) > CAST(reference.tolerance_low as float)) THEN 'blue'
		ELSE 'off'
	END as Color,
	CASE
		WHEN (sensordata.temperature - averages.avgtemp > CAST(reference.tolerance_low as float)) THEN 'true'
		ELSE 'false'
	END as Power,
    reference.notify
INTO
    alerts
FROM
    sensordata Timestamp by EventEnqueuedUtcTime
JOIN reference
	ON reference.id = sensordata.IoTHub.ConnectionDeviceId
JOIN PreviousEvent 
    ON DATEDIFF(ss, PreviousEvent, sensordata) between 1 and 6
        AND sensordata.IoTHub.ConnectionDeviceId = PreviousEvent.deviceId	
JOIN averages 
    ON DATEDIFF(ss, averages, sensordata) between 1 and 6
    AND sensordata.IoTHub.ConnectionDeviceId = averages.deviceId 
WHERE
	(sensordata.temperature - averages.avgtemp > CAST(reference.tolerance_low as float) ) OR ((PreviousEvent.temperature - averages.avgtemp) > CAST(reference.tolerance_low as float))