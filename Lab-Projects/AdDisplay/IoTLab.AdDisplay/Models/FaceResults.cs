using System.Collections.Generic;

namespace IoTLab.AdDisplay.Models
{
    public class FaceResults
    {
        public int NumberOfFaces { get; set; }
        public List<IndividualFace> Faces { get; set; } = new List<IndividualFace>();
    }
}
