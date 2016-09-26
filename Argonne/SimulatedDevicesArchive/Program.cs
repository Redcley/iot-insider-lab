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

using System.Diagnostics;
using System.Data.SqlClient;

using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;

using Microsoft.IoTInsiderLab.Argonne.Common;

namespace Microsoft.IoTInsiderLab.Argonne.SimulatedDevices
{
    class Program
    {
        // We want one sequence or random numbers for the entire run.
        private static Random _random = new Random();

        static void Main(string[] args)
        {
            var clients = new Dictionary<string, DeviceClient>();
            var simulatedDevices = new List<SimulatedDeviceInfo>();

            // Get the simulated devices. They have entries in the BiasesForDevices table.
            // As this is always run in Visual Studio in debug mode, we do not have to handle errors programmatically.
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = new SqlConnection(Common.ConnectionStrings.Database);
                cmd.Connection.Open();

                // BiasesForDevices contains only rows for which we have postal codes,
                // excluding the real device.
                cmd.CommandText =
                    //"DELETE Impressions;" +
                    "SELECT * " +
                    "FROM   BiasesForDevices b " +
                    "       INNER JOIN Devices d " +
                    "               ON d.DeviceId = b.DeviceId;"
                    ;

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var simulatedDeviceInfo = new SimulatedDeviceInfo
                            (
                                deviceId:      reader.GetGuid  (reader.GetOrdinal("DeviceId")).ToString(),
                                primaryKey:    reader.GetString(reader.GetOrdinal("PrimaryKey")),
                                countBias:     reader.GetDouble(reader.GetOrdinal("CountBias")),
                                angerBias:     reader.GetDouble(reader.GetOrdinal("AngerBias")),
                                contemptBias:  reader.GetDouble(reader.GetOrdinal("ContemptBias")),
                                disgustBias:   reader.GetDouble(reader.GetOrdinal("DisgustBias")),
                                fearBias:      reader.GetDouble(reader.GetOrdinal("FearBias")),
                                happinessBias: reader.GetDouble(reader.GetOrdinal("HappinessBias")),
                                neutralBias:   reader.GetDouble(reader.GetOrdinal("NeutralBias")),
                                sadnessBias:   reader.GetDouble(reader.GetOrdinal("SadnessBias")),
                                surpriseBias:  reader.GetDouble(reader.GetOrdinal("SurpriseBias"))
                            );
                        simulatedDevices.Add(simulatedDeviceInfo);
                        clients.Add(simulatedDeviceInfo.DeviceId, 
                                    DeviceClient.Create("IoTLabArgonneIoTHub.azure-devices.net", 
                                                        new DeviceAuthenticationWithRegistrySymmetricKey(simulatedDeviceInfo.DeviceId, simulatedDeviceInfo.PrimaryKey)));
                    }
                }
            }

            // UNDER DEVELOPMENT        vvvv
            for (var count = 0; count < 5000; count++)
            {
                // The fastest rate is one message per second.
                var begin = DateTime.Now;

                foreach (var simulatedDeviceInfo in simulatedDevices)
                {
                    // This makes us send a messge three out of four cases for devices with CountBias = 1.
                    if (_random.NextDouble() * simulatedDeviceInfo.CountBias > .25)
                    {
                        SendDeviceToCloudMessagesAsync(simulatedDeviceInfo, clients[simulatedDeviceInfo.DeviceId]);
                        System.Threading.Thread.Sleep(1000 + Convert.ToInt32(2000 * _random.NextDouble()));
                    }
                }
            }
        }

        private static async void SendDeviceToCloudMessagesAsync(SimulatedDeviceInfo simulatedDeviceInfo, DeviceClient deviceClient)
        {
            // We will have a random number of faces.
            var faces = new List<Face>();

            faces.Add(new Face(10, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));

            if (_random.NextDouble() > .10)
            {
                faces.Add(new Face(5, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));
            }

            if (_random.NextDouble() > .20)
            {
                faces.Add(new Face(15, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));
            }

            if (_random.NextDouble() > .30)
            {
                faces.Add(new Face(20, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));
            }

            if (_random.NextDouble() > .40)
            {
                faces.Add(new Face(15, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));
            }

            if (_random.NextDouble() > .50)
            {
                faces.Add(new Face(10, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));
            }

            if (_random.NextDouble() > .60)
            {
                faces.Add(new Face(5, .45, new Scores(simulatedDeviceInfo, _random), simulatedDeviceInfo.DeviceId, _random));
            }

            if (_random.NextDouble() > .70)
            {
                faces.Add(new Face(10, .45, null, null, _random));
            }

            var impression = new Impression(simulatedDeviceInfo, faces.ToArray());
            var messageString = JsonConvert.SerializeObject(impression);
            messageString = messageString.Replace(",\"scores\":null", string.Empty);

            var message = new Message(Encoding.ASCII.GetBytes(messageString));
            try
            {
                await deviceClient.SendEventAsync(message).ConfigureAwait(false);
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
