using System;

namespace ArgonneWebApi.Models.Dto
{
    public partial class AdDto
    {
        public Guid AdId { get; set; }
        public string AdName { get; set; }
        public string Url { get; set; }
    }
}
