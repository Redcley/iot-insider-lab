using System;

//Disable all XML Comment warnings in this file
#pragma warning disable 1591

namespace ArgonneWebApi.Models.Datastore
{
    internal partial class ErrorLog
    {
        public DateTime Timestamp { get; set; }
        public string Json { get; set; }
        public string Error { get; set; }
    }
}
