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

using Microsoft.ServiceBus.Messaging;
using System.Threading;

namespace ReadDeviceToCloudMessages
{
using Microsoft.ServiceBus.Messaging;
using System.Threading;
    class Program
    {
        private static readonly string connectionString  = "HostName=JansTestIoTHub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=ASKDXDXfmW+wnU1IdaTEUGsJ93LgeZd2tiJKxhLuov0=";
        private static readonly string iotHubD2cEndpoint = "messages/events";
        private static EventHubClient eventHubClient;
        static void Main(string[] args)
        {
            Console.WriteLine("Receive messages. Ctrl-C to exit.\n");
            eventHubClient = EventHubClient.CreateFromConnectionString(connectionString, iotHubD2cEndpoint);

            var d2cPartitions = eventHubClient.GetRuntimeInformation().PartitionIds;

            CancellationTokenSource cts = new CancellationTokenSource();

            System.Console.CancelKeyPress += (s, e) =>
            {
                e.Cancel = true;
                cts.Cancel();
                Console.WriteLine("Exiting...");
            };

            var tasks = new List<Task>();
            foreach (string partition in d2cPartitions)
            {
                tasks.Add(ReceiveMessagesFromDeviceAsync(partition, cts.Token));
            }
            Task.WaitAll(tasks.ToArray());
        }
        private static async Task ReceiveMessagesFromDeviceAsync(string partition, CancellationToken ct)
        {
            var eventHubReceiver = eventHubClient.GetDefaultConsumerGroup().CreateReceiver(partition, DateTime.UtcNow);
            while (true)
            {
                if (ct.IsCancellationRequested) break;
                EventData eventData = await eventHubReceiver.ReceiveAsync();
                if (eventData == null) continue;

                string data = Encoding.UTF8.GetString(eventData.GetBytes());
                Console.WriteLine($"{DateTime.Now} Received partition {partition}, data '{data}'");
            }
        }
    }
}
