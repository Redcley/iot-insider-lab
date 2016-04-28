//-------------------------------------------------------------------------
// <copyright file="Containers.cs" company="http://www.microsoft.com">
//   Copyright © 2016 by Microsoft Corporation. All rights reserved.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IoTLabWeather.DataAccess
{
    public class Location
    {
        public string Code { get; set; }
        public string Name { get; set; }
        public string State { get; set; }
    }

    public class Observation
    {
        public string ObservedOn { get; set; }
        public string LocationCode { get; set; }
        public string Wind { get; set; }
        public string Visibility { get; set; }
        public string Weather { get; set; }
        public string SkyConditions { get; set; }
        public string TemperatureAir { get; set; }
        public string Dewpoint { get; set; }
        public string Temperature6hrMax { get; set; }
        public string Temperature6hrMin { get; set; }
        public string RelativeHumidity { get; set; }
        public string WindChill { get; set; }
        public string PressureAltimeter { get; set; }
        public string HeatIndex { get; set; }
        public string PressureSeaLevel { get; set; }
        public string Precipitation1hr { get; set; }
        public string Precipitation3hr { get; set; }
        public string Precipitation6hr { get; set; }
    }
}
