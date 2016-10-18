using System;

// Disable all XML Comment warnings in this file //
#pragma warning disable 1591

namespace ArgonneWebApi.Models.Datastore
{
    internal partial class AdsForCampaigns
    {
        public Guid CampaignId { get; set; }
        public Guid AdId { get; set; }
        public short Sequence { get; set; }
        public short Duration { get; set; }
        public short FirstImpression { get; set; }
        public short ImpressionInterval { get; set; }

        public virtual Ads Ad { get; set; }
        public virtual Campaigns Campaign { get; set; }
    }
}
