using System;
using System.Collections.Generic;

// Disable all XML Comment warnings in this file //
#pragma warning disable 1591

namespace ArgonneWebApi.Models.Datastore
{
    internal partial class Ads
    {
        public Ads()
        {
            AdsForCampaigns = new HashSet<AdsForCampaigns>();
            Impressions = new HashSet<Impressions>();
        }

        public Guid AdId { get; set; }
        public string AdName { get; set; }
        public string Url { get; set; }

        public virtual ICollection<AdsForCampaigns> AdsForCampaigns { get; set; }
        public virtual ICollection<Impressions> Impressions { get; set; }
    }
}
