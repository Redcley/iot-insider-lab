using S=System;
using SI=System.IO;
using ST=System.Text;
using STh=System.Threading;
using SThT=System.Threading.Tasks;

using AA=Android.App;
using AW=Android.Widget;
using AO=Android.OS;

using MADC=Microsoft.Azure.Devices.Client;
using NJ = Newtonsoft.Json;
using NJL=Newtonsoft.Json.Linq;

namespace IoTCollector
{
	[AA.Activity(Label = "IoTCollector", MainLauncher = true, Icon = "@mipmap/icon")]
	public class MainActivity : AA.Activity
	{
		S.Random rnd = new S.Random();
		int msgCount = 0;

		AW.EditText etTemperature;
		AW.EditText etHumidity;
		AW.EditText etPressure;
		AW.TextView tvStatus;
 		AW.Button btPost;

		MADC.DeviceClient deviceClient;
		STh.CancellationTokenSource TokenSource = new STh.CancellationTokenSource();

		protected override async void OnCreate(AO.Bundle savedInstanceState)
		{
			base.OnCreate(savedInstanceState);

			// Set our view from the "main" layout resource
			SetContentView(Resource.Layout.Main);

			etTemperature = FindViewById<AW.EditText>(Resource.Id.editTemperature);
			etHumidity = FindViewById<AW.EditText>(Resource.Id.editHumidity);
			etPressure = FindViewById<AW.EditText>(Resource.Id.editPressure);
			btPost = FindViewById<AW.Button>(Resource.Id.buttonPost);
			tvStatus = FindViewById<AW.TextView>(Resource.Id.textStatus);

			btPost.Enabled = false;
			btPost.Click += OnClick;

			double temp = 22.0 + (rnd.NextDouble() - 0.5);
			double humidity = 10.0 + (rnd.NextDouble() - 0.5);
			double pressure = 101000.0 + (rnd.NextDouble() - 0.5);

			etTemperature.Text = temp.ToString();
			etHumidity.Text = humidity.ToString();
			etPressure.Text = pressure.ToString();

			SI.StreamReader sr = new SI.StreamReader(Assets.Open("ConnectionString.txt"));
			deviceClient = MADC.DeviceClient.CreateFromConnectionString(sr.ReadToEnd());

			try
			{
				await deviceClient.OpenAsync();
				tvStatus.Text = "Device Connected";
				btPost.Enabled = true;
			}
			catch (S.Exception e)
			{
				tvStatus.Text = e.Message;
			}

			STh.CancellationToken ct = TokenSource.Token;
			SThT.Task tsk = SThT.Task.Factory.StartNew(async () => {
				while (true)
				{
					MADC.Message message = await deviceClient.ReceiveAsync();
					if (message != null)
					{
						try
						{
							byte[] data = message.GetBytes();
							string text = ST.Encoding.UTF8.GetString(data, 0, data.Length);
							tvStatus.Text = text;
							await deviceClient.CompleteAsync(message);
							//var msg = NJL.JObject.Parse(text);
						}
						catch (S.Exception e)
						{
							tvStatus.Text = e.Message;
							await deviceClient.RejectAsync(message);
						}
					}
					if (ct.IsCancellationRequested)
					{
						tvStatus.Text = "Receiving task canceled";
						break;
					}
				}
			}, ct);
		}

		protected override void OnDestroy()
		{
			if (deviceClient != null)
			{
				deviceClient.CloseAsync();
				deviceClient = null;
			}

			base.OnDestroy();
		}

		async void OnClick(object sender, S.EventArgs e)
		{
			double temp = double.Parse(etTemperature.Text);
			double humidity = double.Parse(etHumidity.Text);
			double pressure = double.Parse(etPressure.Text);

			NJL.JObject msg = new NJL.JObject();
			msg.Add(new NJL.JProperty("response", "environment"));
			msg.Add(new NJL.JProperty("temperature", new NJL.JValue(temp)));
			msg.Add(new NJL.JProperty("humidity", new NJL.JValue(humidity)));
			msg.Add(new NJL.JProperty("pressure", new NJL.JValue(pressure)));

			byte[] data = ST.Encoding.UTF8.GetBytes(NJ.JsonConvert.SerializeObject(msg));
			var message = new MADC.Message(data);
			message.MessageId = S.Guid.NewGuid().ToString();

			await deviceClient.SendEventAsync(message);
			msgCount += 1;
			tvStatus.Text = msg.ToString() + "\nMessages Sent: " + msgCount.ToString();

			temp += rnd.NextDouble() - 0.5;
			humidity += rnd.NextDouble() - 0.5;
			pressure += rnd.NextDouble() - 0.5;

			etTemperature.Text = temp.ToString();
			etHumidity.Text = humidity.ToString();
			etPressure.Text = pressure.ToString();
		}
	}
}


