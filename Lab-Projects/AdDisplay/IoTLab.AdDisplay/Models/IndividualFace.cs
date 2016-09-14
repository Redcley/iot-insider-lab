using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IoTLab.AdDisplay.Constants;

namespace IoTLab.AdDisplay.Models
{
    public class IndividualFace
    {
        public int Age { get; set; }
        public GenderEnum Gender { get; set; }
        public Dictionary<string, float> Emotions { get; set; } = new Dictionary<string, float>();
    }
}
