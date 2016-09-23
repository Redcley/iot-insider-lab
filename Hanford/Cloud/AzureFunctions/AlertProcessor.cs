#r "Microsoft.ServiceBus"

using System;
using Microsoft.ServiceBus.Messaging;

public class FooMsg
{
    public string deviceid { get; set; }
	public DateTime? endtimeofaveragewindow { get; set; }
	public double? avgtemp { get; set; }
	public double? triggertemp { get; set; }
	public DateTime? currenteventtime { get; set; }
	public double? previoustemp { get; set; }
	public DateTime? previoustime { get; set; }
	public string uid { get; set; }
	public string color { get; set; }
	public bool power { get; set; }
	
}

public static void Run(List<FooMsg> myEventHubMessages, TraceWriter log)
{
    foreach(var msg in myEventHubMessages)
    {
		log.Info($"------------------------------------------");
		log.Info($"DeviceId: {myEventHubMessages[0].deviceid}");
		log.Info($"Trigger Temp: {myEventHubMessages[0].triggertemp}");
		log.Info($"Avg Temp: {myEventHubMessages[0].avgtemp}");
        log.Info($"Color: {myEventHubMessages[0].color}");
		log.Info($"Power: {myEventHubMessages[0].power}");
    }
   
}