using Microsoft.Azure.Devices.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EnvironmentMonitoringApp
{
    class HubManager
    {
        DeviceClient mClient;

        public HubManager(DeviceClient client)
        {
            mClient = client;
        }
    }
}
