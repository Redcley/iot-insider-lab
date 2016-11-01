using System;

namespace ArgonneWebApi.Models.Datastore
{
    internal class AdSentimentData
    {
        public Guid CampaignId { get; set; }
        public Guid DisplayedAdId { get; set; }
        public decimal? Anger { get; set; }
        public decimal? Contempt { get; set; }
        public decimal? Disgust { get; set; }
        public decimal? Fear { get; set; }
        public decimal? Happiness { get; set; }
        public decimal? Neutral { get; set; }
        public decimal? Sadness { get; set; }
        public decimal? Surprise { get; set; }
    }
}

