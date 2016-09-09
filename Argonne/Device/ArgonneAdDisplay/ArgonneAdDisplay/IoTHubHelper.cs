using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;
using Windows.Data.Json;
using System.Diagnostics;
using System.Threading;
using Windows.System.Threading;

namespace IntelligentKioskSample
{
    class IoTHubHelper
    {
        private DeviceClient dc;
        private Mutex mMutex;
        private Semaphore mIncomingRunning;
        private bool mAvailable;
        private string mConnectionString;
        private Task mIncommingMessageThread;
        Action<JsonObject> messageCallback;

        public bool Available
        {
            get { return mAvailable; }
        }

        public string ConnectionString
        {
            get { return mConnectionString; }
            set {
                mConnectionString = value;
                if (!UpdateConnectionString())
                {
                    throw new Exception("Could not create IoT Hub connection using connection string: " + value);
                }
            }
}

        public IoTHubHelper()
        {
            mMutex = new Mutex(false, "IoTHelper");
            mIncomingRunning = new Semaphore(0, 1);
            messageCallback = null;
        }

        public void RegisterCommandCallback(Action<JsonObject> callback)
        {
            messageCallback = callback;
        }

        private bool UpdateConnectionString()
        {
            bool retval = false;
            Action messageHandler = HandleIncomingMessages;

            if (mIncomingRunning.WaitOne(-1))
            {
                try
                {
                    dc = DeviceClient.CreateFromConnectionString(ConnectionString, Microsoft.Azure.Devices.Client.TransportType.Amqp);
                    retval = true;
                    mAvailable = true;
                } catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());
                    dc = null;
                    mAvailable = false;
                } finally
                {
                    mIncomingRunning.Release();
                    if (this.Available)
                    {
                        mIncommingMessageThread = new Task(messageHandler);
                    }
                }
           }

            return retval;
        }

        private async void HandleIncomingMessages()
        {
            Message receivedMessage;
            string messageData;

            while (mIncomingRunning.WaitOne(0))
            {
                receivedMessage = await dc.ReceiveAsync(TimeSpan.FromSeconds(3));

                if (null != receivedMessage)
                {
                    messageData = Encoding.UTF8.GetString(receivedMessage.GetBytes());
                    Debug.WriteLine("New Message: " + messageData);
                    JsonObject json_message = JsonValue.Parse(messageData).GetObject();

                    if (json_message.ContainsKey("request"))
                    {
                        await dc.CompleteAsync(receivedMessage);
                        if (messageCallback != null)
                        {
                            messageCallback(json_message);
                        }
                    }   
                }
                mIncomingRunning.Release();
            }

            return;
        }

        public async void SendImpression()
        {

        }

    }
}
