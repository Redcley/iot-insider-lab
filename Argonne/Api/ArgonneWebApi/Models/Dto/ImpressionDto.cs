using System;
using System.ComponentModel.DataAnnotations;

namespace ArgonneWebApi.Models.Dto
{
    /// <summary>
    /// Represents a moment in time when human(s) impressions of an ad being displayed were evaluated
    /// </summary>
    public partial class ImpressionDto
    {
        /// <summary>
        /// Globally unique identifier assigned by Argonne system
        /// </summary>
        public long ImpressionId { get; set; }
        /// <summary>
        /// The device where the impression occurred
        /// </summary>
        [Required]
        public Guid DeviceId { get; set; }
        /// <summary>
        /// Cognitive services message id
        /// </summary>
        public Guid MessageId { get; set; }
        /// <summary>
        /// Ad being displayed at time of impression
        /// </summary>
        [Required]
        public Guid DisplayedAdId { get; set; }
        /// <summary>
        /// Timestamp from device at time of impression
        /// </summary>
        public DateTime DeviceTimestamp { get; set; }
        /// <summary>
        /// Timestamp from Argonne system when impression is recorded
        /// </summary>
        public DateTime InsertTimestamp { get; set; }
    }
}
