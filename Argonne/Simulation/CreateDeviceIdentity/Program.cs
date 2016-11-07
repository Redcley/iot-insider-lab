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

using Microsoft.Azure.Devices;
using Microsoft.Azure.Devices.Common.Exceptions;

using Microsoft.IoTInsiderLab.Argonne.Common;

namespace Microsoft.IoTInsiderLab.Argonne.CreateDeviceIdentity
{
    class Program
    {
        private static RegistryManager registryManager;
        private static SqlCommand cmd;

        static void Main(string[] args)
        {
            // This will run in Visual Studio - we do not need special error handling.
            registryManager = RegistryManager.CreateFromConnectionString(ConnectionStrings.IoTHub);

            cmd = new SqlCommand("PersistDevice", new SqlConnection(ConnectionStrings.Database));
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Connection.Open();

            for (var i = 0; i < 50; i++)
            {
                AddDeviceAsync("SimulatedDevice" + i.ToString("D2")).Wait();
            }

            cmd.Connection.Close();
            Console.ReadLine();
        }

        private static async Task AddDeviceAsync(string deviceName)
        {
            Device device;
            try
            {
                device = await registryManager.AddDeviceAsync(new Device(Guid.NewGuid().ToString()));

                cmd.Parameters.Clear();
                cmd.Parameters.Add(new SqlParameter("@deviceId", device.Id));
                cmd.Parameters.Add(new SqlParameter("@primaryKey", device.Authentication.SymmetricKey.PrimaryKey));
                cmd.Parameters.Add(new SqlParameter("@deviceName", deviceName));
                cmd.Parameters.Add(new SqlParameter("@address", string.Empty));
                cmd.Parameters.Add(new SqlParameter("@address2", string.Empty));
                cmd.Parameters.Add(new SqlParameter("@address3", string.Empty));
                cmd.Parameters.Add(new SqlParameter("@city", string.Empty));
                cmd.Parameters.Add(new SqlParameter("@stateProvince", string.Empty));
                cmd.Parameters.Add(new SqlParameter("@postalCode", string.Empty));

                cmd.ExecuteNonQuery();
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
            }
        }
    }
}
