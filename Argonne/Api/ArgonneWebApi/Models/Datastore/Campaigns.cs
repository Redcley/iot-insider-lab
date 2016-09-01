﻿using System;
using System.Collections.Generic;

namespace ArgonneWebApi.Models.Datastore
{
    public partial class Campaigns
    {
        public Campaigns()
        {
            AdsForCampaigns = new HashSet<AdsForCampaigns>();
            CampaignsForDevices = new HashSet<CampaignsForDevices>();
        }

        public Guid CampaignId { get; set; }
        public string CampaignName { get; set; }

        public virtual ICollection<AdsForCampaigns> AdsForCampaigns { get; set; }
        public virtual ICollection<CampaignsForDevices> CampaignsForDevices { get; set; }
    }
}
