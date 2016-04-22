package com.redcley.helloiot.services;

import android.app.IntentService;
import android.app.admin.SystemUpdatePolicy;
import android.content.Intent;
import android.content.Context;

import com.google.gson.JsonObject;
import com.microsoft.azure.iothub.DeviceClient;
import com.microsoft.azure.iothub.IotHubClientProtocol;
import com.microsoft.azure.iothub.IotHubEventCallback;
import com.microsoft.azure.iothub.IotHubMessageResult;
import com.microsoft.azure.iothub.IotHubStatusCode;
import com.microsoft.azure.iothub.Message;

import org.json.JSONObject;

import java.io.IOException;
import java.net.URISyntaxException;

/**
 * An {@link IntentService} subclass for handling asynchronous task requests in
 * a service on a separate handler thread.
 * <p/>
 * TODO: Customize class - update intent actions, extra parameters and static
 * helper methods.
 */
public class IoTHubService extends IntentService {
    // IntentService can perform, e.g. ACTION_FETCH_NEW_ITEMS
    private static final String ACTION_TELEMETRY_START = "com.redcley.helloiot.services.action.TELEMETRY_START";
    private static final String ACTION_TELEMETRY_STOP = "com.redcley.helloiot.services.action.TELEMETRY_STOP";
    private static final String ACTION_START = "com.redcley.helloiot.services.action.ACTION_START";
    private static final String ACTION_STOP = "com.redcley.helloiot.services.action.ACTION_STOP";

    private static DeviceClient client;
    private static boolean isTelemetryRunning = false;

    private static String connString = "HostName=IoTLab-MonitorDemo.azure-devices.net;DeviceId=AndroidDemo2;SharedAccessKey=iBQXSRp2cVcXJESgLIVpRw==";
    private static IotHubClientProtocol protocol = IotHubClientProtocol.HTTPS;

    protected class EventCallback implements IotHubEventCallback {
        public void execute(IotHubStatusCode status, Object context)
        {
            //Integer i = (Integer) context;
            System.out.println("IoT Hub responded to message " + /*i.toString() + */" with status " + status.name());
        }
    }

    protected class IotMessageCallback implements com.microsoft.azure.iothub.MessageCallback {
        public IotHubMessageResult execute(Message msg, Object context) {
            IotHubMessageResult result = IotHubMessageResult.REJECT;

            try {
                String commandJson = new String(msg.getBytes(), Message.DEFAULT_IOTHUB_MESSAGE_CHARSET);

                //DeviceCommand command = DeviceCommand.fromJSON(commandJson);
                org.json.JSONObject jsonObject = new JSONObject(commandJson);

                System.out.println("Received message with content: " + commandJson);
                String commandName = jsonObject.getString("Name");

                if ("StartTelemetry".equalsIgnoreCase(commandName)) {
                    //SendEvent.startTelemetry();
                    onStartTelemetry();
                    result = IotHubMessageResult.COMPLETE;
                } else if ("StopTelemetry".equalsIgnoreCase(commandName)) {
                    //SendEvent.stopTelemetry();
                    onStopTelemetry();
                    result = IotHubMessageResult.COMPLETE;
                }
            } catch (Throwable e) {
                e.printStackTrace();
            }

            return result;
        }
    }

    public IoTHubService() {
        super("IoTHubService");
    }

    /**
     * Starts service.
     *
     * @see IntentService
     */
    public static void start(Context context) {
        Intent intent = new Intent(context, IoTHubService.class);
        intent.setAction(ACTION_START);
        //intent.putExtra(EXTRA_PARAM1, param1);
        //intent.putExtra(EXTRA_PARAM2, param2);
        context.startService(intent);
    }

    /**
     * Stops service.
     *
     * @see IntentService
     */
    public static void stop(Context context) {
        Intent intent = new Intent(context, IoTHubService.class);
        intent.setAction(ACTION_STOP);
        context.startService(intent);
    }

    /**
     * Starts the telemetry.
     *
     * @see IntentService
     */
    public static void startTelemetry(Context context) {
        Intent intent = new Intent(context, IoTHubService.class);
        intent.setAction(ACTION_TELEMETRY_START);
        context.startService(intent);
    }

    /**
     * Stops the telemetry.
     *
     * @see IntentService
     */
    public static void stopTelemetry(Context context) {
        Intent intent = new Intent(context, IoTHubService.class);
        intent.setAction(ACTION_TELEMETRY_STOP);
        context.startService(intent);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        if (intent != null) {
            final String action = intent.getAction();
            if (ACTION_START.equals(action)) {
                onStart();
            } else if (ACTION_STOP.equals(action)) {
                onStop();
            } else if (ACTION_TELEMETRY_START.equals(action)) {
                onStartTelemetry();
            } else if (ACTION_TELEMETRY_STOP.equals(action)) {
                onStopTelemetry();
            }
        }

        /*new Thread(new Runnable() {
            public void run() {
                String connString = "HostName=IoTLab-MonitorDemo.azure-devices.net;DeviceId=AndroidDemo2;SharedAccessKey=iBQXSRp2cVcXJESgLIVpRw==";
                IotHubClientProtocol protocol = IotHubClientProtocol.HTTPS;

                try {
                    DeviceClient client = new DeviceClient(connString, protocol);
                    client.setMessageCallback(new IotMessageCallback(), null);
                    client.open();
                } catch (URISyntaxException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }

                while(true) {
                    System.out.println("Running");

                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();*/
    }

    private void onStartTelemetry() {
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

    private void onStopTelemetry() {
        System.out.println("Telemetry thread stopping");
        isTelemetryRunning = false;
    }

    private void onStart() {
        //new Thread(new Runnable() {
        //    public void run() {

                try {
                    client = new DeviceClient(connString, protocol);
                    client.setMessageCallback(new IotMessageCallback(), null);
                    client.open();
                } catch (URISyntaxException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }

        System.out.println("Running");

                /*while(true) {
                    System.out.println("Running");

                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }*/
            //}
        //}).start();
    }

    private void onStop() {
        try {
            client.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
