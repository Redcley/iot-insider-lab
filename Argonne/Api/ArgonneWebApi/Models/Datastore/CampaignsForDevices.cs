using System;

//Disable all XML Comment warnings in this file
#pragma warning disable 1591


namespace ArgonneWebApi.Models.Datastore
{
    public partial class CampaignsForDevices
    {
        public Guid DeviceId { get; set; }
        public Guid CampaignId { get; set; }
        public DateTime Timestamp { get; set; }

        public virtual Campaigns Campaign { get; set; }
        public virtual Devices Device { get; set; }
    }
}
