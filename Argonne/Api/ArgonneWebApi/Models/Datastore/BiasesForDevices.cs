using System;

// Disable all XML Comment warnings in this file //
#pragma warning disable 1591

namespace ArgonneWebApi.Models.Datastore
{
    public partial class BiasesForDevices
    {
        public Guid DeviceId { get; set; }
        public string ShadowName { get; set; }
        public double CountBias { get; set; }
        public double AngerBias { get; set; }
        public double ContemptBias { get; set; }
        public double DisgustBias { get; set; }
        public double FearBias { get; set; }
        public double HappinessBias { get; set; }
        public double NeutralBias { get; set; }
        public double SadnessBias { get; set; }
        public double SurpriseBias { get; set; }

        public virtual Devices Device { get; set; }
    }
}
