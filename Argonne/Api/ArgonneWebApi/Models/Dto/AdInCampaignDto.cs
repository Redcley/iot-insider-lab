using System;
using System.ComponentModel.DataAnnotations;

namespace ArgonneWebApi.Models.Dto
{
    public partial class AdInCampaignDto
    {
        [Required]
        public Guid CampaignId { get; set; }
        [Required]
        public Guid AdId { get; set; }
        //public string AdName { get; set; }
        //public string Url { get; set; }
        public short Duration { get; set; }
        public short FirstImpression { get; set; }
        public short ImpressionInterval { get; set; }
        //public string CampaignName { get; set; }
    }
}
