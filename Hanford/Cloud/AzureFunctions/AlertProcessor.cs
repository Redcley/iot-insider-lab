#r "Microsoft.ServiceBus"

using System;
using Microsoft.ServiceBus.Messaging;
using Microsoft.Azure.Devices;
using Newtonsoft.Json;
using System.Text;

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

public class Light
{
	public bool power { get; set; }
	public string color { get; set; }
}

public class Sound
{
	public bool play { get; set; }
}

public class CloudToDeviceMessage
{
	public string request { get; set; }
	public List<Light> lights { get; set; }
	public Sound sound { get; set; }
}

public static void Run(List<FooMsg> myEventHubMessages, TraceWriter log)
{
	var connectionString = System.Environment.GetEnvironmentVariable("iothub_connection");
	var serviceClient = ServiceClient.CreateFromConnectionString(connectionString);
	
    foreach(var msg in myEventHubMessages)
    {
		log.Info($"DeviceId: {msg.deviceid}");
		var command = new CloudToDeviceMessage
		{
			request = "output",
			lights = new List<Light>{new Light{power = msg.power, color = msg.color}},
			sound = new Sound{play = false}
		};
		string messageString = JsonConvert.SerializeObject(command);
		log.Info($"CloudToDeviceMessage: {messageString}");
		
		var commandMessage = new Message(Encoding.ASCII.GetBytes(messageString));
		serviceClient.SendAsync(msg.deviceid, commandMessage).Wait(1000);
    }
}