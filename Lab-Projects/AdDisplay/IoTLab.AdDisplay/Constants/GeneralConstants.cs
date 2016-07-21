namespace IoTLab.AdDisplay.Constants
{
	/// <summary>
	/// General constant variables
	/// </summary>
	public static class GeneralConstants
	{
		// The ID of the sender to IoT Hub - this should be different for every device that is connected
		public static string DeviceId { get; set; }

		// Switch to determine whether to send messages to IoT Hub
		public static bool SendToCloud { get; set; }

		// The URI of the IoT hub this device will send to/receive from if active
		public static string IoTHubURI { get; set; }

		// The device key used to authenticate with IoT Hub
		public static string IoTHubDeviceKey { get; set; }

        // Oxford Emotion API Primary key
        public static string OxfordEmotionAPIKey { get; set; }

        // Oxford Face API Primary key
        public static string OxfordFaceAPIKey { get; set; }
        
	}
}