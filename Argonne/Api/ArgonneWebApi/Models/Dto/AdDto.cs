using System;

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
        public string AdName { get; set; }
        /// <summary>
        /// Url for ad media
        /// </summary>
        public string Url { get; set; }
    }
}
