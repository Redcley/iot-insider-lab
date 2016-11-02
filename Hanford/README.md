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

- [Web App](https://github.com/Redcley/iotil-hanford-webapp)
- [PAAS](https://github.com/Redcley/iotil-hanford-paas)
- [Database](https://github.com/Redcley/iotil-hanford-database)
- Clients
  - [**RaspberryPi and IoT Core**](https://github.com/Redcley/iotil-hanford-rpi-core) - A RaspberryPi device running Windows IoT Core. The device is wired to a mpl3115a2 and htu21d to measure temperature, humidity and pressure and sends this data up to the cloud every 5 seconds as well as a rgb LED which it can drive to provide feedback. All the device code is written in C# using the Azure IoT client SDK to send and receive messages.
  - [**RaspberryPi and Raspbian**](https://github.com/Redcley/iotil-hanford-rpi-core) - A RaspberryPi device running Raspbian (Jessie). The device is wired to a mpl3115a2 and htu21d to measure temperature, humidity and pressure and sends this data up to the cloud every 5 seconds as well as a rgb LED which it can drive to provide feedback. All the device code is written in Javascript running in node using the Azure IoT client SDK to send and receive messages.
  - [**Xamarin mobile app**](https://github.com/Redcley/iotil-hanford-mobile) - A mobile device (currently Android). The device provides a native Android UI to enter temperature, humidity and pressure and sends this data up to the cloud every time the user presses the POST button. All the device code is written in C# using the xamarin development environment and the Azure IoT client SDK to send and receive messages.

