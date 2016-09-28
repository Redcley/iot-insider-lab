using System;
using System.Collections.Generic;

//Disable all XML Comment warnings in this file
#pragma warning disable 1591


namespace ArgonneWebApi.Models.Datastore
{
    public partial class Devices
    {
        public Devices()
        {
            Impressions = new HashSet<Impressions>();
        }

        public Guid DeviceId { get; set; }
        public Guid? AssignedCampaignId { get; set; }
        public string PrimaryKey { get; set; }
        public string DeviceName { get; set; }
        public string Address { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string City { get; set; }
        public string StateProvince { get; set; }
        public string PostalCode { get; set; }
        public DateTime? ActiveFrom { get; set; }
        public DateTime? ActiveTo { get; set; }
        public string Timezone { get; set; }

        public virtual BiasesForDevices BiasesForDevices { get; set; }
        public virtual ICollection<Impressions> Impressions { get; set; }

        public virtual Campaigns CurrentCampaign { get; set; }
    }
}
