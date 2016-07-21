using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Storage;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;
using IoTLab.AdDisplay.Constants;
using IoTLab.AdDisplay.Models;
using Microsoft.ProjectOxford.Emotion;
using Microsoft.ProjectOxford.Emotion.Contract;
using Microsoft.ProjectOxford.Face;
using Microsoft.ProjectOxford.Face.Contract;

namespace IoTLab.AdDisplay.Helpers
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

        public static async Task<FaceResults> DetectFaces(StorageFile ImageFile)
        {
            // Set up the facial attributes we want returned
            var requiredFaceAttributes = new FaceAttributeType[]
            {
                FaceAttributeType.Age, 
                FaceAttributeType.Gender
            };

            // What we will eventually return
            FaceResults faceResults = new FaceResults
            {
                NumberOfFaces = 0
            };

            // Process the inbound image via the Face API
            using (Stream imageStream = File.OpenRead(ImageFile.Path))
            {
                var faces = await faceApiClient.DetectAsync(imageStream, returnFaceLandmarks: true, returnFaceAttributes: requiredFaceAttributes);
                if (!faces.Any())
                {
                    return faceResults;
                }

                // Create the output list
                faceResults.NumberOfFaces = faces.Length;

                // Loop through the faces and get the emotions
                foreach (Face face in faces)
                {
                    ImageSource croppedImage = await ImageCrop.GetCroppedBitmapAsync(ImageFile, 
                        new Point(face.FaceRectangle.Left, face.FaceRectangle.Top),
                        new Size(face.FaceRectangle.Width, face.FaceRectangle.Height));

                    // Process the cropped image through the Emotion API
                    using (Stream croppedStream = ((WriteableBitmap) croppedImage).PixelBuffer.AsStream())
                    {
                        var emotions = await emotionApiClient.RecognizeAsync(croppedStream);
                        foreach (Emotion emotion in emotions)
                        {
                            IndividualFace faceItem = new IndividualFace
                            {
                                Age = (int) Math.Floor(face.FaceAttributes.Age)
                            };
                            foreach (KeyValuePair<string, float> emotionItem in emotion.Scores.ToRankedList())
                            {
                                faceItem.Emotions.Add(emotionItem.Key, emotionItem.Value);
                            }

                            // Now add to the result
                            faceResults.Faces.Add(faceItem);
                        }
                    }
                }
            }

            // And return the result
            return faceResults;
        }
    }
}
