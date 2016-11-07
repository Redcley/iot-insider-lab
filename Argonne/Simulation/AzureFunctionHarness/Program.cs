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

using System.Configuration;
using System.Data.SqlClient;

namespace Microsoft.IoTInsiderLab.Argonne.AzureFunctionHarness
{
    // Harness for the Argonne Azure function.
    class Program
    {
        static void Main(string[] args)
        {
            // Preliminary test. We later test in Azure.
            var message = "{\"deviceId\":\"cff56b1b-508b-46ec-afdc-e287188b2840\",\"messageId\":\"90660965-3475-4dca-ae10-1fe2048fdac4\"," +
                          "\"messageType\": \"impression\"," +
                          "\"displayedAdId\":\"3149351f-3c9e-4d0a-bfa5-d8caacfd77f2\",\"timestamp\":\"2016-08-22T16:32:45.892Z\"," +
                          "\"faces\":{\"age\":41,\"gender\":\"male\"," +
                          "\"scores\":{\"anger\":0,\"contempt\":0.1,\"disgust\":0.2,\"fear\":0.3,\"happiness\":0.4,\"neutral\":0.5,\"sadness\":0.6,\"surprise\":0.7}}}";
            Run(message, new TraceWriter());
        }

        public static void Run(string myEventHubMessage, TraceWriter log)
        {
            using (var cmd = new SqlCommand())
            {
                try
                {
                    cmd.Connection = new SqlConnection(
// In Azure set up the connection string, uncomment this line...
//                        ConfigurationManager.ConnectionStrings["SqlServerConnectionString"].ConnectionString);
"");   // ...and delete this line. Don't forget to set up the string.
                    cmd.Connection.Open();

                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.CommandText = "PersistImpression";
                    cmd.Parameters.Add(new SqlParameter("@json", myEventHubMessage));
                    cmd.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    // This can fail only as a result of a cmd problem.
                    log.Info($"Event Hub trigger function failed with {ex.Message}.");
                }
            }

            // This will be removed after the end-to-end test.
            log.Info($"Event Hub trigger function processed message {myEventHubMessage}.");
        }
    }

    // Simulated Azure logger.
    class TraceWriter
    {
        public void Info(string message)
        {
            // do nothing - it is just a simulation
        }
    }
}
