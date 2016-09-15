﻿// Code generated by Microsoft (R) AutoRest Code Generator 0.9.7.0
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

using System;
using System.Collections.Generic;
using System.Linq;
using Argonne.Services.ArgonneService.Models;
using Newtonsoft.Json.Linq;

namespace Argonne.Services.ArgonneService.Models
{
    public static partial class DevicesCollection
    {
        /// <summary>
        /// Deserialize the object
        /// </summary>
        public static IList<Devices> DeserializeJson(JToken inputObject)
        {
            IList<Devices> deserializedObject = new List<Devices>();
            foreach (JToken iListValue in ((JArray)inputObject))
            {
                Devices devices = new Devices();
                devices.DeserializeJson(iListValue);
                deserializedObject.Add(devices);
            }
            return deserializedObject;
        }
    }
}
