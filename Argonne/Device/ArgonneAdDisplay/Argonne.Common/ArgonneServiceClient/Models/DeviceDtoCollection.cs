﻿// Code generated by Microsoft (R) AutoRest Code Generator 0.9.7.0
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

using System;
using System.Collections.Generic;
using System.Linq;
using Argonne.Common.ArgonneService.Models;
using Newtonsoft.Json.Linq;

namespace Argonne.Common.ArgonneService.Models
{
    public static partial class DeviceDtoCollection
    {
        /// <summary>
        /// Deserialize the object
        /// </summary>
        public static IList<DeviceDto> DeserializeJson(JToken inputObject)
        {
            IList<DeviceDto> deserializedObject = new List<DeviceDto>();
            foreach (JToken iListValue in ((JArray)inputObject))
            {
                DeviceDto deviceDto = new DeviceDto();
                deviceDto.DeserializeJson(iListValue);
                deserializedObject.Add(deviceDto);
            }
            return deserializedObject;
        }
    }
}