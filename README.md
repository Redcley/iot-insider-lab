# Microsoft IoT Insider Lab
This repository contains on-boarding documents and information that pertains to the IoT Insider Lab.

[About the IoT lab here]

## Microsoft Azure IoT

Visit http://azure.com/iotdev to learn more about developing applications for Azure IoT.

## Microsoft Azure IoT SDKs

### Device SDKs
The Microsoft Azure IoT device SDKs contain code that facilitate building devices and applications that connect to and are managed by Azure IoT Hub services.

Visit http://github.com/Azure/azure-iot-sdks for more information

### Service SDKs
Visit http://github.com/Azure/azure-iot-sdks for more information

## Platforms and Devices

Microsoft Azure IoT supports a wide range of devices and platforms, this repository contains information on the following platforms:

- [iOS](platforms/ios/README.md)
- [Android](platforms/android/README.md)
- [Cordova](platforms/cordova/README.md)
- [NodeJS](platforms/nodejs/README.md)
- [Xamarin](platforms/xamarin/README.md)
- [Arduion](platforms/arduino/README.md)
- [Raspberry Pi](platforms/raspberrypi/README.md)
- [Windows Universal Application/Platform](platforms/uwp/README.md)


For more information on another device or platform, please visit https://azure.microsoft.com/en-us/develop/iot/get-started/.

## Getting Started

### Setup Your IoT Hub
https://azure.microsoft.com/en-us/documentation/articles/iot-hub-csharp-csharp-getstarted/

### Setup Your Development Environment

## Samples

## Contribution, feedback and issues

If you would like to become an active contributor to this project please follow the instructions provided in the [contribution guidelines](contribute.md).
If you encounter any bugs or have suggestions for new features, please file an issue in the [Issues](https://github.com/Azure/azure-iot-sdks/issues) section of the project.

## Support

## Additional resources

### /build

This folder contains various build scripts to build the libraries.

### /doc


----------


This folder contains the following documents that are relevant to all the language SDKs:

- [Set up IoT Hub](doc/setup_iothub.md) describes how to configure your Azure IoT Hub service.
- [Manage IoT Hub](doc/manage_iot_hub.md) describes how to provision devices in your Azure IoT Hub service.
- [FAQ](doc/faq.md) contains frequently asked questions about the SDKs and libraries.
- [OS Platforms and hardware compatibility](https://azure.microsoft.com/documentation/articles/iot-hub-tested-configurations/) describes the SDK compatibility with different OS platforms as well as specific device configurations.

### /tools

This folder contains tools you will find useful when you are working with IoT Hub and the device SDKs.
- [iothub-explorer](tools/iothub-explorer/readme.md): describes how to use the iothub-explorer node.js tool to provision a device for use in IoT Hub, monitor the messages from the device, and send commands to the device.
- [Device Explorer](tools/DeviceExplorer/readme.md): this tool enables you to perform operations such as manage the devices registered to an IoT hub, view device-to-cloud messages sent to an IoT hub, and send cloud-to-device messages from an IoT hub. Note this tool only runs on Windows.

    enter code here