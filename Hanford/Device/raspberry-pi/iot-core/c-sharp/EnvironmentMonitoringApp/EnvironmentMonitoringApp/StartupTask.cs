using System;
using Windows.ApplicationModel.Background;
using Microsoft.Azure.Devices.Client;
using System.Diagnostics;
using Microsoft.Maker.Sparkfun.WeatherShield;
using Windows.Networking;
using Windows.Networking.Connectivity;
using System.Threading;
using Windows.System.Threading;
using System.Text;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Storage;
using System.Runtime.Serialization.Json;
using System.Collections.Generic;
using System.IO;
using Windows.Data.Json;

// The Background Application template is documented at http://go.microsoft.com/fwlink/?LinkID=533884&clcid=0x409

namespace EnvironmentMonitoringApp
{
    public sealed class StartupTask : IBackgroundTask
    {
        private readonly int i2cReadIntervalSeconds = 5;
        private readonly int port = 50001;
        private WeatherShield weatherShield;
        private BackgroundTaskDeferral taskDeferral;
        private Mutex mutex;
        private string mutexId = "WeatherShield";
        private ThreadPoolTimer i2cTimer;
        private ThreadPoolTimer ledTimer;

        private string configLocation = "C:\\config\\IoTDemoConfig.json";
        private JsonObject config;

        private Redcley.Sensors.I2C.NeoPixelDriver.PixelColor color = Redcley.Sensors.I2C.NeoPixelDriver.PixelColor.Black;
        private int count = 0;

        DeviceClient client;

        public async void Run(IBackgroundTaskInstance taskInstance)
        {
            string config_string;
            taskDeferral = taskInstance.GetDeferral();
            // Task cancellation handler, release our deferral there 
            taskInstance.Canceled += OnCanceled;

            mutex = new Mutex(false, mutexId);
            Debug.WriteLine(configLocation);

            try
            {
                config_string = System.IO.File.ReadAllText(configLocation);
                config = JsonValue.Parse(config_string).GetObject();
            } catch
            {
                Debug.WriteLine("Unable to read connection configuration information");
                config_string = "{}";
            }

            weatherShield = new WeatherShield("I2C1", config_string);
            string device_connection_string = config.GetNamedString("connection_string");
            Debug.WriteLine(device_connection_string);
            
            await weatherShield.BeginAsync();

            client = DeviceClient.CreateFromConnectionString(device_connection_string, Microsoft.Azure.Devices.Client.TransportType.Amqp);

            i2cTimer = ThreadPoolTimer.CreatePeriodicTimer(PopulateWeatherData, TimeSpan.FromSeconds(i2cReadIntervalSeconds));
            HandleIncomingMessages(client);
        }

        private async void OnCanceled(IBackgroundTaskInstance sender, BackgroundTaskCancellationReason reason)
        {
            // Relinquish our task deferral
            await client.CloseAsync();
            taskDeferral.Complete();
        }

        private string GetHostName()
        {
            foreach (HostName name in NetworkInformation.GetHostNames())
            {
                if (HostNameType.DomainName == name.Type)
                {
                    return name.DisplayName;
                }
            }

            return "minwinpc";
        }

        private async void LedDisplayUpdate(ThreadPoolTimer timer)
        {
            bool hasMutex = false;
            
            try
            {
                hasMutex = mutex.WaitOne(500);
                if (hasMutex)
                {
                    string color = weatherShield.LedColor;
                    switch (color)
                    {
                        case "blue":
                            weatherShield.SetColor("green");
                            break;
                        case "green":
                            weatherShield.SetColor("orange");
                            break;
                        case "orange":
                            weatherShield.SetColor("purple");
                            break;
                        case "purple":
                            weatherShield.SetColor("red");
                            break;
                        case "red":
                            weatherShield.SetColor("yellow");
                            break;
                        case "yellow":
                            weatherShield.SetColor("black");
                            break;
                        case "black":
                            weatherShield.SetColor("blue");
                            break;
                    }
                    mutex.ReleaseMutex();
                }
            }
            catch (System.Exception e)
            {
                if (hasMutex)
                    mutex.ReleaseMutex();
                count++;
                Debug.WriteLine(e.ToString());
            }
        }

        private async Task HandleIncomingMessages(DeviceClient deviceClient)
        {
            Message receivedMessage;
            string messageData;

            while (true)
            {

                receivedMessage = await deviceClient.ReceiveAsync(TimeSpan.FromSeconds(3));

                if ( null != receivedMessage)
                {
                    messageData = Encoding.UTF8.GetString(receivedMessage.GetBytes());
                    Debug.WriteLine("New Message: " + messageData);

                    JsonObject json_message = JsonValue.Parse(messageData).GetObject();

                    if (json_message.ContainsKey("request"))
                    {
                        if (json_message.GetNamedString("request").Equals("status"))
                        {

                            JsonObject response = new JsonObject();
                            response.Add("response", JsonValue.CreateStringValue("status"));

                            if (mutex.WaitOne(1000))
                            {
                                response.Add("pressure", JsonValue.CreateNumberValue(weatherShield.Pressure));
                                response.Add("temperature", JsonValue.CreateNumberValue(weatherShield.Temperature));
                                response.Add("humidity", JsonValue.CreateNumberValue(weatherShield.Humidity));
                                response.Add("responseId", JsonValue.CreateStringValue(receivedMessage.MessageId));
                                response.Add("dials", JsonArray.Parse("[]"));
                                response.Add("switches", JsonArray.Parse("[]"));

                                JsonArray lights = new JsonArray();
                                JsonObject led = new JsonObject();
                                led.Add("power", JsonValue.CreateBooleanValue(weatherShield.LedEnabled));
                                led.Add("color", JsonValue.CreateStringValue(weatherShield.LedColor));
                                lights.Add(led);
                                response.Add("lights", lights);

                                response.Add("sound", JsonObject.Parse("{\"play\": false}"));
                                mutex.ReleaseMutex();
                            }
                            else
                            {
                                response.Add("pressure", JsonValue.CreateNumberValue(0));
                                response.Add("temperature", JsonValue.CreateNumberValue(0));
                                response.Add("humidity", JsonValue.CreateNumberValue(0));
                                response.Add("responseId", JsonValue.CreateStringValue(receivedMessage.MessageId));
                                response.Add("dials", JsonArray.Parse("[]"));
                                response.Add("switches", JsonArray.Parse("[]"));

                                JsonArray lights = new JsonArray();
                                JsonObject led = new JsonObject();
                                led.Add("power", JsonValue.CreateBooleanValue(false));
                                led.Add("color", JsonValue.CreateStringValue("black"));
                                lights.Add(led);
                                response.Add("lights", lights);

                                response.Add("sound", JsonObject.Parse("{\"play\": false}"));
                            }

                            Debug.Write(response.Stringify() + "\n");
                            Message m = new Message(Encoding.UTF8.GetBytes(response.Stringify()));
                            m.MessageId = Guid.NewGuid().ToString();

                            Debug.WriteLine("New Message: " + messageData.ToString());
                            await deviceClient.SendEventAsync(m);
                            await deviceClient.CompleteAsync(receivedMessage);


                        }
                        else if (json_message.GetNamedString("request").Equals("output"))
                        {
                            await deviceClient.CompleteAsync(receivedMessage);

                            JsonArray lights = json_message.GetNamedArray("lights");
                            JsonObject led = lights.GetObjectAt(0);
                            if (mutex.WaitOne(1000))
                            {
                                if (false == led.GetNamedBoolean("power"))
                                {
                                    weatherShield.SetColor("black");
                                } else
                                {
                                    weatherShield.SetColor(led.GetNamedString("color"));
                                }
                                mutex.ReleaseMutex();
                            } else
                            {
                                Debug.WriteLine("Unable to set LED color.");
                            }
                        }
                    }

                }
            }
        }

        private async void PopulateWeatherData(ThreadPoolTimer timer)
        {
            bool hasMutex = false;

            try
            {
                hasMutex = mutex.WaitOne(1000);
                if (hasMutex)
                {
                    JsonObject environmentData = new JsonObject();
                    environmentData.Add("response", JsonValue.CreateStringValue("environment"));
                    environmentData.Add("pressure", JsonValue.CreateNumberValue(weatherShield.Pressure));
                    environmentData.Add("temperature", JsonValue.CreateNumberValue(weatherShield.Temperature));
                    environmentData.Add("humidity", JsonValue.CreateNumberValue(weatherShield.Humidity));

                    Debug.Write(environmentData.Stringify() + "\n");
                    Message m = new Message(Encoding.UTF8.GetBytes(environmentData.Stringify()));
                    m.MessageId = Guid.NewGuid().ToString();

                    await client.SendEventAsync(m);
                }
            } catch (System.Exception e)
            {
                Debug.WriteLine(e.ToString());
            }
            finally
            {
                if (hasMutex)
                {
                    mutex.ReleaseMutex();
                }
            }

        }
    }
}
