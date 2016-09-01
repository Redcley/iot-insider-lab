using System;
using System.Collections.Generic;

namespace ArgonneWebApi.Models.Datastore
{
    public partial class Devices
    {
        public Devices()
        {
            CampaignsForDevices = new HashSet<CampaignsForDevices>();
            Impressions = new HashSet<Impressions>();
        }

        public Guid DeviceId { get; set; }
        public string PrimaryKey { get; set; }
        public string DeviceName { get; set; }
        public string Address { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string City { get; set; }
        public string StateProvince { get; set; }
        public string PostalCode { get; set; }

        public virtual BiasesForDevices BiasesForDevices { get; set; }
        public virtual ICollection<CampaignsForDevices> CampaignsForDevices { get; set; }
        public virtual ICollection<Impressions> Impressions { get; set; }
    }
}
