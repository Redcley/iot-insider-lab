WITH averages AS
(
    SELECT 
        IoTHub.ConnectionDeviceId as deviceId,
        AVG(temperature) as avgtemp,
        CONCAT(IoTHub.ConnectionDeviceId, CAST(System.TimeStamp as nvarchar(max))) as uid,
        System.TimeStamp AS Time
    FROM iotlabdemo
    GROUP BY SlidingWindow(mi, 5), IoTHub.ConnectionDeviceId
)

SELECT
    averages.deviceId as deviceId,
	averages.time,
	averages.avgtemp,
	iotlabdemo.temperature as TriggerTemp,
	CONCAT(averages.deviceId, CAST(System.TimeStamp as nvarchar(max))) as uid
INTO
    hotpath
FROM
    iotlabdemo
JOIN
    averages on iotlabdemo.IoTHub.ConnectionDeviceId = averages.deviceId
    AND DATEDIFF(ms, iotlabdemo, averages) = 0
WHERE
	ABS(iotlabdemo.temperature - averages.avgtemp) > 1 