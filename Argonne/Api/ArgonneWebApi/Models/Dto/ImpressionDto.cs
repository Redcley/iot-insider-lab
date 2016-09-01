using System;

namespace ArgonneWebApi.Models.Dto
{
    public partial class ImpressionDto
    {
        public long ImpressionId { get; set; }
        public Guid DeviceId { get; set; }
        public Guid MessageId { get; set; }
        public Guid DisplayedAdId { get; set; }
        public DateTime DeviceTimestamp { get; set; }
        public DateTime InsertTimestamp { get; set; }
    }
}
