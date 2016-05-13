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

// The Background Application template is documented at http://go.microsoft.com/fwlink/?LinkID=533884&clcid=0x409

namespace EnvironmentMonitoringApp
{
    public sealed class StartupTask : IBackgroundTask
    {
        private readonly int i2cReadIntervalSeconds = 5;
        private readonly int port = 50001;
        private WeatherShield weatherShield = new WeatherShield("I2C1",6,5);
        private BackgroundTaskDeferral taskDeferral;
        private Mutex mutex;
        private string mutexId = "WeatherShield";
        private ThreadPoolTimer i2cTimer;
        private ThreadPoolTimer ledTimer;

        private EnvironmentData environmentData = new EnvironmentData();
        private string connectionStringLocation = "C:\\config\\IoTDemoConnectionString.txt";
        private byte[] color = { 0, 0, 0 };
        private int count = 0;

        string deviceId;
        DeviceClient client;

        public async void Run(IBackgroundTaskInstance taskInstance)
        {
            taskDeferral = taskInstance.GetDeferral();
            // Task cancellation handler, release our deferral there 
            taskInstance.Canceled += OnCanceled;

            mutex = new Mutex(false, mutexId);
            Debug.WriteLine(connectionStringLocation);
            string connectionString = System.IO.File.ReadAllLines(connectionStringLocation)[0].TrimEnd('\r','\n');
             

            Debug.WriteLine(connectionString);

            client = DeviceClient.CreateFromConnectionString(connectionString, Microsoft.Azure.Devices.Client.TransportType.Amqp);

            await weatherShield.BeginAsync();

            i2cTimer = ThreadPoolTimer.CreatePeriodicTimer(PopulateWeatherData, TimeSpan.FromSeconds(i2cReadIntervalSeconds));
            ledTimer = ThreadPoolTimer.CreatePeriodicTimer(LedDisplayUpdate, TimeSpan.FromMilliseconds(250));
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
                color[0] += 32;
                if (0 == color[0])
                {
                    color[1] += 32;
                    if (0 == color[1])
                    {
                        color[2] += 32;
                    }
                }

                hasMutex = mutex.WaitOne(100);
                if (hasMutex)
                {
                    weatherShield.SetColor(color[0], color[1], color[2]);
                    mutex.ReleaseMutex();
                }
            }
            catch (System.Exception e)
            {
                if (hasMutex)
                    mutex.ReleaseMutex();
                count++;
                Debug.WriteLine(e.ToString());
                Debug.WriteLine("RGB: " + color[0].ToString() +"." + color[1].ToString() + "." + color[2].ToString());
                Debug.WriteLine("Count: " + count.ToString());
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
                    environmentData.pressure = weatherShield.Pressure;
                    environmentData.temperature = weatherShield.Temperature;
                    environmentData.humidity = weatherShield.Humidity;

                    Debug.Write(environmentData.JSON + "\n");
                    Message m = new Message(Encoding.UTF8.GetBytes(environmentData.JSON));
                    m.MessageId = Guid.NewGuid().ToString();

                    client.SendEventAsync(m);
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
