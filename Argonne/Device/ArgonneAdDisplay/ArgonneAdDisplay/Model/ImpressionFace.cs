using Argonne.Common.ArgonneService.Models;
using Microsoft.ProjectOxford.Emotion.Contract;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArgonneAdDisplay.Model
{
    public class ImpressionFace : FacesForImpressions
    {
        public Scores Scores { get; set; }
    }    
}
