using System;

namespace ArgonneWebApi.Models.Datastore
{
    public class AdAggregateData
    {
        public Guid AdId { get; set; }
        public int? Faces { get; set; }
        public int? Males { get; set; }
        public int? Females { get; set; }

        public int? AgeBracket1 { get; set; }
        public int? AgeBracket2 { get; set; }
        public int? AgeBracket3 { get; set; }
        public int? AgeBracket4 { get; set; }
        public int? AgeBracket5 { get; set; }
        public int? AgeBracket6 { get; set; }
    }
}

