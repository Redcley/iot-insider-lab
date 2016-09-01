using System;
using System.Collections.Generic;

namespace ArgonneWebApi.Models.Datastore
{
    public partial class Impressions
    {
        public Impressions()
        {
            FacesForImpressions = new HashSet<FacesForImpressions>();
        }

        public long ImpressionId { get; set; }
        public Guid DeviceId { get; set; }
        public Guid MessageId { get; set; }
        public Guid DisplayedAdId { get; set; }
        public DateTime DeviceTimestamp { get; set; }
        public DateTime InsertTimestamp { get; set; }

        public virtual ICollection<FacesForImpressions> FacesForImpressions { get; set; }
        public virtual Devices Device { get; set; }
        public virtual Ads DisplayedAd { get; set; }
    }
}
