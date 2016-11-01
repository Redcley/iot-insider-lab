using System;

namespace ArgonneWebApi.Models.Datastore
{
    internal class CampaignAdAggregateData
    {
        public Guid CampaignId { get; set; }
        public string CampaignName { get; set; }
        public Guid DisplayedAdId { get; set; }
        public string AdName { get; set; }
        public int? TotalFaces { get; set; }
        public int? UniqueFaces { get; set; }
        public string OverallSentiment { get; set; }
        public decimal? TotalAnger { get; set; }
        public decimal? TotalContempt { get; set; }
        public decimal? TotalDisgust { get; set; }
        public decimal? TotalFear { get; set; }
        public decimal? TotalHappiness { get; set; }
        public decimal? TotalNeutral { get; set; }
        public decimal? TotalSadness { get; set; }
        public decimal? TotalSurprise { get; set; }
        public int? MinAge { get; set; }
        public int? MaxAge { get; set; }
        public int? UniqueMales { get; set; }
        public int? UniqueFemales { get; set; }
        public int? AgeBracket0 { get; set; }
        public int? AgeBracket0Males { get; set; }
        public int? AgeBracket0Females { get; set; }
        public int? AgeBracket1 { get; set; }
        public int? AgeBracket1Males { get; set; }
        public int? AgeBracket1Females { get; set; }
        public int? AgeBracket2 { get; set; }
        public int? AgeBracket2Males { get; set; }
        public int? AgeBracket2Females { get; set; }
        public int? AgeBracket3 { get; set; }
        public int? AgeBracket3Males { get; set; }
        public int? AgeBracket3Females { get; set; }
        public int? AgeBracket4 { get; set; }
        public int? AgeBracket4Males { get; set; }
        public int? AgeBracket4Females { get; set; }
        public int? AgeBracket5 { get; set; }
        public int? AgeBracket5Males { get; set; }
        public int? AgeBracket5Females { get; set; }
        public int? AgeBracket6 { get; set; }
        public int? AgeBracket6Males { get; set; }
        public int? AgeBracket6Females { get; set; }

    }
}

//WHEN Age BETWEEN  0 AND 14 THEN 0
//WHEN Age BETWEEN 15 AND 19 THEN 1
//WHEN Age BETWEEN 20 AND 29 THEN 2
//WHEN Age BETWEEN 30 AND 39 THEN 3
//WHEN Age BETWEEN 40 AND 49 THEN 4
//WHEN Age BETWEEN 50 AND 59 THEN 5
//ELSE 6