//Disable all XML Comment warnings in this file
#pragma warning disable 1591

namespace ArgonneWebApi.Models.Datastore
{
    public partial class FacesForImpressions
    {
        public long ImpressionId { get; set; }
        public short Sequence { get; set; }
        public short Age { get; set; }
        public string Gender { get; set; }
        public decimal? ScoreAnger { get; set; }
        public decimal? ScoreContempt { get; set; }
        public decimal? ScoreDisgust { get; set; }
        public decimal? ScoreFear { get; set; }
        public decimal? ScoreHappiness { get; set; }
        public decimal? ScoreNeutral { get; set; }
        public decimal? ScoreSadness { get; set; }
        public decimal? ScoreSurprise { get; set; }

        public virtual Impressions Impression { get; set; }
    }
}
