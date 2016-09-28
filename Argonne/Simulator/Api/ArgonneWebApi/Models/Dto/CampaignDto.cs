using System;
using System.ComponentModel.DataAnnotations;

namespace ArgonneWebApi.Models.Dto
{
    /// <summary>
    /// Ad Campaign
    /// </summary>
    public partial class CampaignDto
    {
        /// <summary>
        /// Globally unique identifier for campaign assigned by Argonne system
        /// </summary>
        public Guid CampaignId { get; set; }
        /// <summary>
        /// Name of Campaign
        /// </summary>
        [Required]
        public string CampaignName { get; set; }
    }
}
