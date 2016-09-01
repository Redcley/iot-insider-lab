using System;
using System.Collections.Generic;

namespace ArgonneWebApi.Models.Datastore
{
    public partial class Ads
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
