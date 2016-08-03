# Project Hanford
Project Hanford is our first end to end demo of and IoT device communicating with the Azure IoT cloud. It was first demonstrated at the grand opening of the IoT Lab in Shenzhen and so is sometimes referred to as the Shenzhen Demo.

## The Device

There are currently three different types of devices that connect to the Hanford IoTHub.

**Device/raspberry-pi/iot-core** - A RaspberryPi device running Windows IoT Core. The device is wired to a mpl3115a2 and htu21d to measure temperature, humidity and pressure and sends this data up to the cloud every 5 seconds as well as a rgb LED which it can drive to provide feedback. All the device code is written in C# using the Azure IoT client SDK to send and receive messages.

**Device/raspberry-pi/raspbian/node** - A RaspberryPi device running Raspbian (Jessie). The device is wired to a mpl3115a2 and htu21d to measure temperature, humidity and pressure and sends this data up to the cloud every 5 seconds as well as a rgb LED which it can drive to provide feedback. All the device code is written in Javascript running in node using the Azure IoT client SDK to send and receive messages.

**Device/mobile/xamarin** - A mobile device (currently Android). The device provides a native Android UI to enter temperature, humidity and pressure and sends this data up to the cloud every time the user presses the POST button. All the device code is written in C# using the xamarin development environment and the Azure IoT client SDK to send and receive messages.

## The Cloud

The cloud is composed of an Azure SQL database and a small Ubuntu VM running node and nginx. The VM uses the eventHub package to consume events off the IoTHub and send them to the Azure SQL database. It also implements a management console using express and JQuery mobile.
