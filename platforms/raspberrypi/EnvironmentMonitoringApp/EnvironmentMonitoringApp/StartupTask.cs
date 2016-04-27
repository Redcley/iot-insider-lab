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
        private EnvironmentData environmentData = new EnvironmentData();

        string deviceId;
        DeviceClient client;

        public async void Run(IBackgroundTaskInstance taskInstance)
        {
            taskDeferral = taskInstance.GetDeferral();
            // Task cancellation handler, release our deferral there 
            taskInstance.Canceled += OnCanceled;

            mutex = new Mutex(false, mutexId);

            deviceId = GetHostName();

            client = DeviceClient.CreateFromConnectionString("HostName=IoTLabDemo.azure-devices.net;DeviceId=lab-pi3-1;SharedAccessKey=si8daal5pXhTDS74HOu4FPiZGa0UtoFgyW6XW9i6hww=");

            await weatherShield.BeginAsync();

            i2cTimer = ThreadPoolTimer.CreatePeriodicTimer(PopulateWeatherData, TimeSpan.FromSeconds(i2cReadIntervalSeconds));
        }

        private void OnCanceled(IBackgroundTaskInstance sender, BackgroundTaskCancellationReason reason)
        {
            // Relinquish our task deferral
            client.CloseAsync();
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
                    Message m = new Message(System.Text.UTF8Encoding.UTF8.GetBytes(environmentData.JSON));
 //                   await client.SendEventAsync(m);
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
