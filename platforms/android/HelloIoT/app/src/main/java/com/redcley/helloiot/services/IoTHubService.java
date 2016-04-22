package com.redcley.helloiot.services;

import android.app.IntentService;
import android.app.admin.SystemUpdatePolicy;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.Context;
import android.content.IntentFilter;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.google.gson.JsonObject;
import com.microsoft.azure.iothub.DeviceClient;
import com.microsoft.azure.iothub.IotHubClientProtocol;
import com.microsoft.azure.iothub.IotHubEventCallback;
import com.microsoft.azure.iothub.IotHubMessageResult;
import com.microsoft.azure.iothub.IotHubStatusCode;
import com.microsoft.azure.iothub.Message;

import org.json.JSONObject;

import java.io.IOException;
import java.io.Serializable;
import java.net.URISyntaxException;
import java.util.Random;

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
    public static final String EVENT_NAME = "com.redcley.helloiot.services.action.IOT_EVENT";
    public static final String PARAMETER = "parameter";
    public static final String STATUS = "status";
    public static final String STATUS_STOPPED = "Stopped";
    public static final String STATUS_TELEMETRY_STOPPED = "TelemetryStopped";
    public static final String STATUS_TELEMETRY_RECEIVED = "Telemetry_Received";
    public static final String STATUS_TELEMETRY_STARTED = "TelemetryStarted";
    public static final String MESSAGE_START_TELEMETRY = "StartTelemetry";
    public static final String MESSAGE_STOP_TELEMETRY = "StopTelemetry";
    public static final String SERVICE_NAME = "IoTHubService";
    public static final String STATUS_STARTED = "Started";

    private static DeviceClient client;
    private static boolean isTelemetryRunning = false;

    private static String connString = "HostName=IoTLab-MonitorDemo.azure-devices.net;DeviceId=AndroidDemo2;SharedAccessKey=iBQXSRp2cVcXJESgLIVpRw==";
    private static IotHubClientProtocol protocol = IotHubClientProtocol.HTTPS;

    // handler for received Intents for the "my-event" event
    private static BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Extract data included in the Intent
            String message = intent.getStringExtra("status");
            Log.d("IoTHubSvc", "Got message: " + message);
        }
    };

    protected class EventCallback implements IotHubEventCallback {
        public void execute(IotHubStatusCode status, Object context)
        {
            //Integer i = (Integer) context;
            Log.d("IoTHubSvc", "IoT Hub responded to message " + /*i.toString() + */" with status " + status.name());
        }
    }

    protected class IotMessageCallback implements com.microsoft.azure.iothub.MessageCallback {
        public IotHubMessageResult execute(Message msg, Object context) {
            IotHubMessageResult result = IotHubMessageResult.REJECT;

            try {
                String commandJson = new String(msg.getBytes(), Message.DEFAULT_IOTHUB_MESSAGE_CHARSET);

                //DeviceCommand command = DeviceCommand.fromJSON(commandJson);
                org.json.JSONObject jsonObject = new JSONObject(commandJson);

                Log.d("IoTHubSvc", "Received message with content: " + commandJson);
                String commandName = jsonObject.getString("Name");

                if (MESSAGE_START_TELEMETRY.equalsIgnoreCase(commandName)) {
                    //SendEvent.startTelemetry();
                    onStartTelemetry();
                    result = IotHubMessageResult.COMPLETE;
                } else if (MESSAGE_STOP_TELEMETRY.equalsIgnoreCase(commandName)) {
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
        super(SERVICE_NAME);
    }

    /**
     * Starts service.
     *
     * @see IntentService
     */
    public static void start(Context context) {
        // Register mMessageReceiver to receive messages.
        //LocalBroadcastManager.getInstance(context).registerReceiver(mMessageReceiver, new IntentFilter(EVENT_NAME));

        Intent intent = new Intent(context, IoTHubService.class);
        intent.setAction(ACTION_START);
        context.startService(intent);
    }

    /**
     * Stops service.
     *
     * @see IntentService
     */
    public static void stop(Context context) {
        //LocalBroadcastManager.getInstance(context).unregisterReceiver(mMessageReceiver);

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
    }

    private void onStartTelemetry() {
        isTelemetryRunning = true;

        new Thread(new Runnable() {
            public void run() {
                Log.d("IoTHubSvc", "Telemetry thread running");
                broadcastStatus(STATUS_TELEMETRY_STARTED);

                Random rand = new Random();

                while(isTelemetryRunning) {
                    JsonObject jsonObject = new JsonObject();
                    jsonObject.addProperty("DeviceId", "AndroidDemo2");
                    jsonObject.addProperty("Temperature", rand.nextInt(120));
                    jsonObject.addProperty("Humidity", rand.nextInt(100));
                    jsonObject.addProperty("ExternalTemperature", rand.nextInt(120));

                    Message msg = new Message(jsonObject.toString());
                    EventCallback callback = new EventCallback();
                    client.sendEventAsync(msg, callback, null);

                    broadcastStatus(STATUS_TELEMETRY_RECEIVED, jsonObject.toString());

                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }

                Log.d("IoTHubSvc", "Telemetry thread exited");
                broadcastStatus(STATUS_TELEMETRY_STOPPED);
            }
        }).start();
    }

    private void onStopTelemetry() {
        Log.d("IoTHubSvc", "Telemetry thread stopping");
        isTelemetryRunning = false;
    }

    private void onStart() {
        try {
            client = new DeviceClient(connString, protocol);
            client.setMessageCallback(new IotMessageCallback(), null);
            client.open();

            Log.d("IoTHubSvc", "Started");
            broadcastStatus(STATUS_STARTED);
        } catch (URISyntaxException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void onStop() {
        try {
            client.close();

            Log.d("IoTHubSvc", "Stopped");
            broadcastStatus(STATUS_STOPPED);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void broadcastStatus(String status) {
        broadcastStatus(status, null);
    }

    public void broadcastStatus(String status, Serializable parameter) {
        Intent intent = new Intent(EVENT_NAME);
        // add data
        intent.putExtra(STATUS, status);

        if(parameter != null) {
            intent.putExtra(PARAMETER, parameter);
        }

        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }
}
