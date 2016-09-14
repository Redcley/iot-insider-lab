using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ArgonneWebApi.Models.Dto
{
    public class CampaignEmotion
    {
        public Guid CampaignId { get; set; }
        public string CampaignName { get; set; }
        public string Emotion { get; set; }
        public decimal? Score { get; set; }
    }
}
