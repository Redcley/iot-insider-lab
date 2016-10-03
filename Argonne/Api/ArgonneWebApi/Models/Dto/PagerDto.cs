using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ArgonneWebApi.Models.Dto
{
    public class PagerDto
    {
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
    }
}
