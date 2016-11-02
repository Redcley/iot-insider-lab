# Project Hanford
Project Hanford is an end to end demo of an IoT device communicating with the Azure IoT cloud. It was first demonstrated at the grand opening of the IoT Lab in Shenzhen and so is sometimes referred to as the Shenzhen Demo.

## Overview

1. Devices send telemetry data (such as ambient temperature) to IotHub.
2. Stream Analytics instance processes each message from IotHub. The Stream Analytics job does 2 things:
	* Every device telemetry message is output to an event hub (EH1)
	* The temperature in each telemetry message is compared to per-device threshholds contained in a reference data file (JSON file in blob storage) and if an alert is triggered it will send an alert message to another event hub (EH2) [the reference data also contains the list of recipients who will be notified of the alert. those recipients are other devices.].

3. The event hub with raw messages (EH1) is processed by a function app (FA1) that invokes a SQL stored procedure for each message. The stored procedure processes the message and makes entries in several tables.
4. The event hub with alert notification messages (EH2) is processed by another function app (FA2) that sends a cloud-to-device message to every device that was in the notification list of the alerting device (notification list is stored in the stream analytics reference data as JSON in blob storage).
5. Cloud-to-device messages sent by FA2 will cause the LED on a device to turn on and change colors when another device senses a temperature spike.
6. A Logic App runs with a recurrence trigger (scheduled job) every 10 minutes and invokes a stored procedure in the SQL database that aggregates device telemetry data into 10 minute intervals.


## Components

Project Hanford is composed of multiple components that have been organized into seperate repositories. Those repositories are linked below:

- [Devices](https://github.com/Redcley/iotil-hanford-device)
- [Web App](https://github.com/Redcley/iotil-hanford-webapp)
- [PAAS](https://github.com/Redcley/iotil-hanford-paas)
- [Database](https://github.com/Redcley/iotil-hanford-database)
