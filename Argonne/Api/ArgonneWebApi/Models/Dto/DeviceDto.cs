using System;

namespace ArgonneWebApi.Models.Dto
{
    public partial class DeviceDto
    {
        public Guid DeviceId { get; set; }
        public string PrimaryKey { get; set; }
        public string DeviceName { get; set; }
        public string Address { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string City { get; set; }
        public string StateProvince { get; set; }
        public string PostalCode { get; set; }
    }
}
