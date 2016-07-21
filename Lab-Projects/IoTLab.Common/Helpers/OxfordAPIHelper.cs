using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using IoTLab.Common.Constants;
using Microsoft.ProjectOxford.Emotion;
using Microsoft.ProjectOxford.Emotion.Contract;
using Microsoft.ProjectOxford.Face;
using Microsoft.ProjectOxford.Face.Contract;

namespace IoTLab.Common.Helpers
{
    /// <summary>
    /// Allows easy access to oxford functions such as adding a visitor to whitelist and checing to see if a visitor is on the whitelist
    /// </summary>
    internal static class OxfordAPIHelper
    {
        // The Oxford Emotion API client
        private static readonly EmotionServiceClient emotionApiClient = new EmotionServiceClient(GeneralConstants.OxfordEmotionAPIKey);

        // The Oxford Face API client
        private static readonly IFaceServiceClient faceApiClient = new FaceServiceClient(GeneralConstants.OxfordFaceAPIKey);

        public static async Task<bool> DetectFaces(Stream ImageStream)
        {
            // Set up the facial attributes we want returned
            var requiredFaceAttributes = new FaceAttributeType[]
            {
                FaceAttributeType.Age, 
                FaceAttributeType.Gender
            };

            // Convert the inbound stream to a bitmap so we can slice off faces later for the emotion API

            // Process the inbound image via the Face API
            var faces = await faceApiClient.DetectAsync(ImageStream, returnFaceLandmarks: true, returnFaceAttributes: requiredFaceAttributes);
            if (!faces.Any())
            {
                return false;
            }

            // Now process via the Emotion API
            var emotions = await emotionApiClient.RecognizeAsync(ImageStream);
            foreach (Emotion emotion in emotions)
            {
            }

            // We have faces, so process the return values
            foreach (Face face in faces)
            {
            }

            // And return the result
            return true;
        }
    }
}
