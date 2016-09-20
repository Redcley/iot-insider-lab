using System;
using System.ComponentModel.DataAnnotations;

namespace ArgonneWebApi.Models.Dto
{
    /// <summary>
    /// Ad ad in the Argonne system
    /// </summary>
    public partial class AdDto
    {
        /// <summary>
        /// Globally unique identifier assigned by the Argonne system
        /// </summary>
        public Guid AdId { get; set; }
        /// <summary>
        /// User friendly name for an ad
        /// </summary>
        [Required]
        public string AdName { get; set; }
        /// <summary>
        /// Url for ad media
        /// </summary>
        [Required]
        public string Url { get; set; }
    }
}
