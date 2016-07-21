using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Reflection;
using Newtonsoft.Json;
using IoTLab.Common.Constants;
using IoTLab.Common.Models;

namespace IoTLab.Common.Helpers
{
	public class AppConfiguration
	{
		// Read the content from Json file
		public static async Task ReadConfigurationInfo(string JSONData)
		{
			try
			{
			    await Task.Run(() =>
			    {
                    // Convert the JSON string into setting objects
                    var configObjects = JsonConvert.DeserializeObject<List<SettingInfo>>(JSONData);

                    // And then assign what we have to the GeneralConstants class
                    var settingType = typeof(GeneralConstants);

                    foreach (SettingInfo settingValue in configObjects)
			        {
			            var settingProperty = settingType.GetRuntimeProperty(settingValue.keyName);
			            if (settingProperty == null)
			            {
			                continue;
			            }
			            switch (settingValue.keyType.ToLower())
			            {
			                case "bool":
			                    settingProperty.SetValue(null, Convert.ToBoolean(settingValue.keyValue));
			                    break;

			                default:
			                    settingProperty.SetValue(null, settingValue.keyValue);
			                    break;
			            }
			        }
			    });
			}
			catch (Exception ex)
			{
				
			}
		}
	}
}
