// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.redcley.helloiot;

//import com.microsoft.azure.iothub.*;

import com.google.gson.JsonObject;
import com.microsoft.azure.iothub.DeviceClient;
import com.microsoft.azure.iothub.IotHubClientProtocol;
import com.microsoft.azure.iothub.IotHubEventCallback;
import com.microsoft.azure.iothub.IotHubMessageResult;
import com.microsoft.azure.iothub.IotHubStatusCode;
import com.microsoft.azure.iothub.Message;
import com.redcley.helloiot.models.DeviceCommand;
import com.redcley.helloiot.models.DeviceInfo;
import com.redcley.helloiot.models.DeviceProperties;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.Objects;
import java.util.Scanner;


/** Sends a number of event messages to an IoT Hub. */
public class SendEvent
{
    private static DeviceClient client;
    private static boolean isTelemetryRunning = false;
    private static IotMessageCallback msgCallback;

    protected static class EventCallback
            implements IotHubEventCallback
    {
        public void execute(IotHubStatusCode status, Object context)
        {
            //Integer i = (Integer) context;
            System.out.println("IoT Hub responded to message " + /*i.toString() + */" with status " + status.name());
        }
    }

    protected static class IotMessageCallback implements com.microsoft.azure.iothub.MessageCallback {
        public IotHubMessageResult execute(Message msg, Object context) {
            System.out.println("Received message with content: " + new String(msg.getBytes(), Message.DEFAULT_IOTHUB_MESSAGE_CHARSET));

            return IotHubMessageResult.COMPLETE;
        }
    }

    public static void startTelemetry() {
        isTelemetryRunning = true;

        new Thread(new Runnable() {
            public void run() {
                System.out.println("Telemetry thread running");

                while(isTelemetryRunning) {
                    JsonObject jsonObject = new JsonObject();
                    jsonObject.addProperty("DeviceId", "AndroidDemo2");
                    jsonObject.addProperty("Temperature", Math.random());
                    jsonObject.addProperty("Humidity", Math.random());
                    jsonObject.addProperty("ExternalTemperature", Math.random());

                    Message msg = new Message(jsonObject.toString());
                    EventCallback callback = new EventCallback();
                    client.sendEventAsync(msg, callback, null);

                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }

                System.out.println("Telemetry thread exited");
            }
        }).start();
    }

    public static void stopTelemetry() {
        System.out.println("Telemetry thread stopping");
        isTelemetryRunning = false;
    }

    /**
     * Sends a number of messages to an IoT Hub. Default protocol is to
     * use HTTPS transport.
     *
     */
    public static void run()
            throws IOException, URISyntaxException
    {
        System.out.println("Starting...");
        System.out.println("Beginning setup.");

        //final String connString = "HostName=MSPortHub.azure-devices.net;DeviceId=helloiotdevice;SharedAccessKey=ZyhSNIiG5PehSr7mjbW3CtDrIbCb8Hb/ujRLa5Q+D9A="; // args[0];
        //final String connString = "HostName=IoTLab-Demo.azure-devices.net;DeviceId=Android1Demo;SharedAccessKey=Tpwj4IHrsPh5n5/9EemYgA==";
        final String connString = "HostName=IoTLab-MonitorDemo.azure-devices.net;DeviceId=AndroidDemo2;SharedAccessKey=iBQXSRp2cVcXJESgLIVpRw==";

        final IotHubClientProtocol protocol = IotHubClientProtocol.HTTPS;
        //final IotHubClientProtocol protocol = IotHubClientProtocol.MQTT;

        client = null;
        try {
            client = new DeviceClient(connString, protocol);
            msgCallback = new IotMessageCallback();
            client.setMessageCallback(msgCallback, null);
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }

        System.out.println("Successfully created an IoT Hub client.");

        new Thread(new Runnable() {
            public void run() {
                try {
                    client.open();
                } catch (IOException e) {
                    e.printStackTrace();
                }

                System.out.println("Opened connection to IoT Hub.");

                DeviceInfo deviceInfo = new DeviceInfo();
                deviceInfo.IsSimulatedDevice = false;
                deviceInfo.ObjectType = "DeviceInfo";
                deviceInfo.Version = "1.0";
                deviceInfo.DeviceProperties = new DeviceProperties();
                deviceInfo.DeviceProperties.DeviceID = "AndroidDemo2";
                deviceInfo.DeviceProperties.HubEnabledState = true;
                deviceInfo.DeviceProperties.Platform = "Android";
                deviceInfo.Commands = new ArrayList<DeviceCommand>();

                DeviceCommand command = new DeviceCommand();
                command.Name = "StopTelemetry";
                deviceInfo.Commands.add(command);

                DeviceCommand command2 = new DeviceCommand();
                command2.Name = "StartTelemetry";
                deviceInfo.Commands.add(command2);

                String messageString = deviceInfo.serialize();

                System.out.println("Sending the following event messages: " + messageString);
                Message msg = new Message(messageString);
                EventCallback callback = new EventCallback();
                client.sendEventAsync(msg, callback, null);
            }
        }).start();
    }
}
