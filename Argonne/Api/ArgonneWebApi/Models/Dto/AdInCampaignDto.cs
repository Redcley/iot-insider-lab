using System;

namespace ArgonneWebApi.Models.Dto
{
    public partial class AdInCampaignDto
    {
        public Guid CampaignId { get; set; }
        public Guid AdId { get; set; }
        //public string AdName { get; set; }
        //public string Url { get; set; }
        public short Duration { get; set; }
        public short FirstImpression { get; set; }
        public short ImpressionInterval { get; set; }
        //public string CampaignName { get; set; }
    }
}
