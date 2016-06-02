using System;
using System.IO;
using System.Runtime.Serialization.Json;
using System.Text;

namespace EnvironmentMonitoringApp
{
    public sealed class EnvironmentData
    {
        public string response { get { return env; } set { } }
        public float pressure { get; set; }
        public float temperature { get; set; }
        public float humidity { get; set; }
        protected string env = "environment";

        public string JSON
        {
            get
            {
                var jsonSerializer = new DataContractJsonSerializer(typeof(EnvironmentData));
                using (MemoryStream strm = new MemoryStream())
                {
                    jsonSerializer.WriteObject(strm, this);
                    byte[] buf = strm.ToArray();
                    return Encoding.UTF8.GetString(buf, 0, buf.Length);
                }
            }
        }
    }
}
