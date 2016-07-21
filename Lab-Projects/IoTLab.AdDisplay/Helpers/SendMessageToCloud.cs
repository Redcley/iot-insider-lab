using System;
using System.Text;
using System.Threading.Tasks;
using IoTLab.AdDisplay.Constants;
using IoTLab.AdDisplay.Models;
using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;

namespace IoTLab.AdDisplay.Helpers
{
	public class SendMessageToCloud
	{
		private static readonly DeviceClient deviceClient = DeviceClient.Create(GeneralConstants.IoTHubURI,
			new DeviceAuthenticationWithRegistrySymmetricKey(GeneralConstants.DeviceId, GeneralConstants.IoTHubDeviceKey));

		public static SendMessageToCloud Default { get;  } = new SendMessageToCloud();

		private SendMessageToCloud()
		{
			// Nothing happens here
		}

		static SendMessageToCloud()
		{
			// Nothing happens here, either
		}

		public void OnDeleteUser(DeleteUser deletedUser)
		{
			// See if the "send to cloud" feature is turned on
			if (!GeneralConstants.SendToCloud)
			{
				return;
			}

			// Create the JSON data from the inbound message object
			var jsonData = JsonConvert.SerializeObject(deletedUser);

			// And send the message
			sendMessage(jsonData);
		}

		public void OnNewUser(NewUser newUser)
		{
			// See if the "send to cloud" feature is turned on
			if (!GeneralConstants.SendToCloud)
			{
				return;
			}

			// Create the JSON data from the inbound message object
			var jsonData = JsonConvert.SerializeObject(newUser);

			// And send the message
			sendMessage(jsonData);
		}

		public void OnRecognizedVisitor(RecognizedVisitor recognizedVisitor)
		{
			// See if the "send to cloud" feature is turned on
			if (!GeneralConstants.SendToCloud)
			{
				return;
			}

			// Create the JSON data from the inbound message object
			var jsonData = JsonConvert.SerializeObject(recognizedVisitor);

			// And send the message
			sendMessage(jsonData);
		}

		public void OnUnrecognizedVisitor(UnrecognizedVisitor unrecognizedVisitor)
		{
			// See if the "send to cloud" feature is turned on
			if (!GeneralConstants.SendToCloud)
			{
				return;
			}

			// Create the JSON data from the inbound message object
			var jsonData = JsonConvert.SerializeObject(unrecognizedVisitor);

			// And send the message
			sendMessage(jsonData);
		}

		public async Task RegisterMessageReceivers()
		{
			// Register the handlers for message processing
			await Messenger.Default.Register<DeleteUser>(Default, OnDeleteUser);
			await Messenger.Default.Register<NewUser>(Default, OnNewUser);
			await Messenger.Default.Register<RecognizedVisitor>(Default, OnRecognizedVisitor);
			await Messenger.Default.Register<UnrecognizedVisitor>(Default, OnUnrecognizedVisitor);
		}

		private static async void sendMessage(string messageData)
		{
			var deviceMessage = new Message(Encoding.ASCII.GetBytes(messageData));
			await deviceClient.SendEventAsync(deviceMessage);
		}
	}
}
