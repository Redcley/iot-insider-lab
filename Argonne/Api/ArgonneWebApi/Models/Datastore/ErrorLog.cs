using System;

namespace ArgonneWebApi.Models.Datastore
{
    public partial class ErrorLog
    {
        public DateTime Timestamp { get; set; }
        public string Json { get; set; }
        public string Error { get; set; }
    }
}
