using System;
using System.Collections.Generic;

//Disable all XML Comment warnings in this file
#pragma warning disable 1591

namespace ArgonneWebApi.Models.Datastore
{
    public partial class Campaigns
    {
        public Campaigns()
        {
            AdsForCampaigns = new HashSet<AdsForCampaigns>();
        }

        public Guid CampaignId { get; set; }
        public string CampaignName { get; set; }

        public virtual ICollection<AdsForCampaigns> AdsForCampaigns { get; set; }

        public virtual ICollection<Devices> Devices { get; set; }
        public virtual ICollection<Impressions> Impressions { get; set; }
    }
}
