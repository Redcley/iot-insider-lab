using System;
using System.ComponentModel.DataAnnotations;

namespace ArgonneWebApi.Models.Dto
{
    /// <summary>
    /// A device within the Argonne system
    /// </summary>
    public partial class DeviceDto
    {
        /// <summary>
        /// Globally unique identifier for a device assgined by Argonne system
        /// </summary>
        public Guid DeviceId { get; set; }
        /// <summary>
        /// Identifier for a device assigned by Azure IOT Hub
        /// </summary>
        [Required]
        public string PrimaryKey { get; set; }
        /// <summary>
        /// User friendly name for a device
        /// </summary>
        [Required]
        public string DeviceName { get; set; }
        /// <summary>
        /// Device location, Address line 1
        /// </summary>
        public string Address { get; set; }
        /// <summary>
        /// Device location, Address line 2
        /// </summary>

        public string Address2 { get; set; }
        /// <summary>
        /// Device location, Address line 3
        /// </summary>
        public string Address3 { get; set; }
        /// <summary>
        /// Device location, City
        /// </summary>

        public string City { get; set; }
        /// <summary>
        /// Device location, State or Province Abbreviation
        /// </summary>

        public string StateProvince { get; set; }
        /// <summary>
        /// Device location, Postal Code
        /// </summary>

        public string PostalCode { get; set; }
    }
}
