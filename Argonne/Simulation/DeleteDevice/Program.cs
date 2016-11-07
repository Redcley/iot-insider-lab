//-------------------------------------------------------------------------
// <copyright file="Program.cs" company="http://www.microsoft.com">
//   Copyright © 2016 by Microsoft Corporation. All rights reserved.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Azure.Devices;
using Microsoft.Azure.Devices.Common.Exceptions;

namespace Microsoft.IoTInsiderLab.Argonne.RemoveDevice
{
    class Program
    {
        private static RegistryManager registryManager;
        private static readonly string connectionString = 
            "HostName=IoTLabArgonneIoTHub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=MH8bpYXF98gpqQgzFJMQKnijwSJMCdPElltOhoqiQtA=";

        static void Main(string[] args)
        {
            registryManager = RegistryManager.CreateFromConnectionString(connectionString);
            foreach (var deviceId in new string[] 
                {
                  "1db7c5b1-b3be-44ae-bb70-99c1c1048a2e"
                } )
            {
                RemoveDeviceAsync(deviceId).Wait();
            }
        }

        private static async Task RemoveDeviceAsync(string deviceId)
        {
            try
            {
                await registryManager.RemoveDeviceAsync(deviceId);
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                // TODO
            }
        }
    }
}
