using System;

namespace ArgonneWebApi.Models.Datastore
{
    public class CampaignEmotion
    {
        public Guid CampaignId { get; set; }
        public string CampaignName { get; set; }
        public string Emotion { get; set; }
        public decimal? Score { get; set; }
    }
}
