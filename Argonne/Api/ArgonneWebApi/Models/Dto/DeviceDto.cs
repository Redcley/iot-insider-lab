using System;
using System.ComponentModel.DataAnnotations;

namespace ArgonneWebApi.Models.Dto
{
    public partial class DeviceDto
    {
        public Guid DeviceId { get; set; }
        [Required]
        public string PrimaryKey { get; set; }
        [Required]
        public string DeviceName { get; set; }
        public string Address { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string City { get; set; }
        public string StateProvince { get; set; }
        public string PostalCode { get; set; }
    }
}
