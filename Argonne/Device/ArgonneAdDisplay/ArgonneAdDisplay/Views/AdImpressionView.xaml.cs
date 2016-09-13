using IntelligentKioskSample.Controls;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;
using Microsoft.ProjectOxford.Emotion.Contract;
using Microsoft.ProjectOxford.Face.Contract;
using ServiceHelpers;
using Windows.Graphics.Imaging;
using System.Threading.Tasks;
using System.Xml.Serialization;
using IntelligentKioskSample;
using Windows.UI.Popups;
using Windows.UI.ViewManagement;
using ArgonneAdDisplay.Model;
using Argonne.Common.ArgonneService.Models;
using Argonne.Common.ArgonneService;
using Microsoft.Azure.Devices.Client;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using ArgonneAdDisplay.ViewModel;
using Microsoft.Practices.ServiceLocation;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

namespace ArgonneAdDisplay.Views
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class AdImpressionView : Page, IRealTimeDataProvider
    {
        private Task processingLoopTask;
        private bool isProcessingLoopInProgress;
        private bool isProcessingPhoto;

        private IEnumerable<Emotion> lastEmotionSample;
        private IEnumerable<Face> lastDetectedFaceSample;
        private IEnumerable<Tuple<Face, IdentifiedPerson>> lastIdentifiedPersonSample;
        private IEnumerable<SimilarFaceMatch> lastSimilarPersistedFaceSample;                

        private const String DEBUG_DEVICE_ID = "1117163c-b8e5-41fd-9cb7-0062d36a14f2";
        //private const string DEBUG_CAMPAIGN_ID = "3149351f-3c9e-4d0a-bfa5-d8caacfd77f0";
        private const string DeviceConnectionString = "HostName=iotlabargonneiothub.azure-devices.net;DeviceId=RashidTestDevice;SharedAccessKey=jBzEMd2UTD66Q0krZX5J+La5QQIZEnxjS5Ft+2A7YXY=";

        DeviceClient deviceClient = DeviceClient.CreateFromConnectionString(DeviceConnectionString, TransportType.Amqp);        

        public AdImpressionView()
        {
            this.InitializeComponent();

            //this.DataContext = this;

            Window.Current.Activated += CurrentWindowActivationStateChanged;
            this.cameraControl.SetRealTimeDataProvider(this);
            this.cameraControl.FilterOutSmallFaces = true;
            this.cameraControl.HideCameraControls();
            this.cameraControl.CameraAspectRatioChanged += CameraControl_CameraAspectRatioChanged;
        }

        public CampaignViewModel CurrentCampaign
        {
            get
            {
                return ServiceLocator.Current.GetInstance<CampaignViewModel>();
            }
        }

        private void CameraControl_CameraAspectRatioChanged(object sender, EventArgs e)
        {
            this.UpdateCameraHostSize();
        }

        private void StartProcessingLoop()
        {
            this.isProcessingLoopInProgress = true;

            if (this.processingLoopTask == null || this.processingLoopTask.Status != TaskStatus.Running)
            {
                this.processingLoopTask = Task.Run(() => this.ProcessingLoop());
            }
        }


        private async Task ProcessingLoop()
        {
            while (this.isProcessingLoopInProgress)
            {
                await this.Dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, async () =>
                {
                    if (!this.isProcessingPhoto)
                    {
                        if (this.cameraControl.NumFacesOnLastFrame == 0)
                        {
                            await this.ProcessCameraCapture(null);
                        }
                        else
                        {
                            await this.ProcessCameraCapture(await this.cameraControl.TakeAutoCapturePhoto());
                        }
                    }
                });

                await Task.Delay(1000);
            }
        }

        private async void CurrentWindowActivationStateChanged(object sender, Windows.UI.Core.WindowActivatedEventArgs e)
        {
            if ((e.WindowActivationState == Windows.UI.Core.CoreWindowActivationState.CodeActivated ||
                e.WindowActivationState == Windows.UI.Core.CoreWindowActivationState.PointerActivated) &&
                this.cameraControl.CameraStreamState == Windows.Media.Devices.CameraStreamState.Shutdown)
            {
                // When our Window loses focus due to user interaction Windows shuts it down, so we 
                // detect here when the window regains focus and trigger a restart of the camera.
                await this.cameraControl.StartStreamAsync(isForRealTimeProcessing: true);
            }
        }

        private async Task ProcessCameraCapture(ImageAnalyzer e)
        {
            try
            {
                this.isProcessingPhoto = true;

                if (e == null)
                {
                    this.lastDetectedFaceSample = null;
                    this.lastIdentifiedPersonSample = null;
                    this.lastSimilarPersistedFaceSample = null;
                    this.lastEmotionSample = null;
                    //this.debugText.Text = "";

                    return;
                }

                DateTime start = DateTime.Now;

                // detect faces
                await Task.WhenAll(e.DetectEmotionAsync(), e.DetectFacesAsync(detectFaceAttributes: true));


                if (!e.DetectedEmotion.Any())
                {
                    this.lastEmotionSample = null;
                    this.ShowTimelineFeedbackForNoFaces();
                }
                else
                {
                    this.lastEmotionSample = e.DetectedEmotion;

                    Scores averageScores = new Scores
                    {
                        Happiness = e.DetectedEmotion.Average(em => em.Scores.Happiness),
                        Anger = e.DetectedEmotion.Average(em => em.Scores.Anger),
                        Sadness = e.DetectedEmotion.Average(em => em.Scores.Sadness),
                        Contempt = e.DetectedEmotion.Average(em => em.Scores.Contempt),
                        Disgust = e.DetectedEmotion.Average(em => em.Scores.Disgust),
                        Neutral = e.DetectedEmotion.Average(em => em.Scores.Neutral),
                        Fear = e.DetectedEmotion.Average(em => em.Scores.Fear),
                        Surprise = e.DetectedEmotion.Average(em => em.Scores.Surprise)
                    };

                    //this.emotionDataTimelineControl.DrawEmotionData(averageScores);
                }

                if (e.DetectedFaces == null || !e.DetectedFaces.Any())
                {
                    this.lastDetectedFaceSample = null;
                }
                else
                {
                    this.lastDetectedFaceSample = e.DetectedFaces;
                }

                // Compute Face Identification and Unique Face Ids
                await Task.WhenAll(e.IdentifyFacesAsync(), e.FindSimilarPersistedFacesAsync());

                if (!e.IdentifiedPersons.Any())
                {
                    this.lastIdentifiedPersonSample = null;
                }
                else
                {
                    this.lastIdentifiedPersonSample = e.DetectedFaces.Select(f => new Tuple<Face, IdentifiedPerson>(f, e.IdentifiedPersons.FirstOrDefault(p => p.FaceId == f.FaceId)));
                }

                if (!e.SimilarFaceMatches.Any())
                {
                    this.lastSimilarPersistedFaceSample = null;
                }
                else
                {
                    this.lastSimilarPersistedFaceSample = e.SimilarFaceMatches;
                }

                // now correlate the emotions and faces by matching faces with the emotions rectangular 
                // var faceDict = e.DetectedFaces.ToDictionary(f => f.FaceId);
                var impressionSet = new ImpressionResultset();
                impressionSet.MessageType = "impression";
                impressionSet.CampaignId = CurrentCampaign.Campaign.CampaignId;
                impressionSet.DeviceId = DEBUG_DEVICE_ID;
                impressionSet.DeviceTimestamp = DateTime.Now;
                impressionSet.DisplayedAdId = CurrentCampaign.CurrentAd.AdId;
                //impressionSet.ImpressionId = ;
                impressionSet.MessageId = Guid.NewGuid().ToString();

                impressionSet.Faces = new List<ImpressionFace>();

                // go through each impressions, find the face
                foreach (var emotion in e.DetectedEmotion)
                {
                    var variationSize = 10;

                    // now find the face
                    var face = (from f in e.DetectedFaces
                                where (f.FaceRectangle.Height + variationSize) >= emotion.FaceRectangle.Height
                                && (f.FaceRectangle.Left + variationSize) >= emotion.FaceRectangle.Left
                                && (f.FaceRectangle.Top + variationSize) >= emotion.FaceRectangle.Top
                                && (f.FaceRectangle.Width + variationSize) >= emotion.FaceRectangle.Width
                                select f).FirstOrDefault();

                    if (face != null)
                    {
                        // found the associated face
                        ImpressionFace impression = new ImpressionFace();
                        impression.Age = Convert.ToInt32(face.FaceAttributes.Age);
                        impression.FaceId = face.FaceId.ToString();
                        impression.Gender = face.FaceAttributes.Gender;
                        //impression.Impression
                        //impression.ImpressionId = 0; // todo: what is the id?
                        //impression.ScoreAnger = emotion.Scores.Anger;
                        //impression.ScoreContempt = emotion.Scores.Contempt;
                        //impression.ScoreDisgust = emotion.Scores.Disgust;
                        //impression.ScoreFear = emotion.Scores.Fear;
                        //impression.ScoreHappiness = emotion.Scores.Happiness;
                        //impression.ScoreNeutral = emotion.Scores.Neutral;
                        //impression.ScoreSadness = emotion.Scores.Sadness;
                        //impression.ScoreSurprise = emotion.Scores.Surprise;

                        impression.Scores = emotion.Scores;

                        impressionSet.Faces.Add(impression);

                        this.debugText.Text = String.Format("You are {0} years old", impression.Age);
                    }
                    else
                    {
                        // something wrong
                        string test = string.Empty;
                    }
                }                

                var jsonSerializerSettings = new JsonSerializerSettings
                {
                    ContractResolver = new CamelCasePropertyNamesContractResolver(),
                    NullValueHandling = NullValueHandling.Ignore,
                    DateFormatHandling = DateFormatHandling.IsoDateFormat,
                    DateTimeZoneHandling = DateTimeZoneHandling.Utc,
                    DateFormatString = "yyyy-MM-ddTHH:mm:ss.fffZ"

                };

                var messageContent = Newtonsoft.Json.JsonConvert.SerializeObject(impressionSet, jsonSerializerSettings);

                // now send to the IoT Hub
                await deviceClient.SendEventAsync(new Message(Encoding.UTF8.GetBytes(messageContent)));

                // now send it to the api
                //await apiClient.ApiAdminImpressionPostAsync(new ImpressionRequest
                //{
                //    Faces = facialImpressions,
                //    Impression = impressionSet
                //});

            }
            catch (Exception ex)
            {
                // todo: log exception here
                string test = ex.Message;
            }
            finally
            {
                this.isProcessingPhoto = false;
            }            
        }

        private void ShowTimelineFeedbackForNoFaces()
        {
            //this.emotionDataTimelineControl.DrawEmotionData(new Scores { Neutral = 1 });
        }

        protected override async void OnNavigatedTo(NavigationEventArgs e)
        {
            EnterKioskMode();

            if (string.IsNullOrEmpty(SettingsHelper.Instance.EmotionApiKey) || string.IsNullOrEmpty(SettingsHelper.Instance.FaceApiKey))
            {
                await new MessageDialog("Missing Face or Emotion API Key. Please enter a key in the Settings page.", "Missing API Key").ShowAsync();
            }
            else
            {
                await FaceListManager.Initialize();
                
                await this.cameraControl.StartStreamAsync(isForRealTimeProcessing: true);
                this.StartProcessingLoop();
            }

            base.OnNavigatedTo(e);
        }       
        
        private void EnterKioskMode()
        {
            ApplicationView view = ApplicationView.GetForCurrentView();
            if (!view.IsFullScreenMode)
            {
                view.TryEnterFullScreenMode();
            }
        }

        protected override async void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            this.isProcessingLoopInProgress = false;
            Window.Current.Activated -= CurrentWindowActivationStateChanged;
            this.cameraControl.CameraAspectRatioChanged -= CameraControl_CameraAspectRatioChanged;

            await this.cameraControl.StopStreamAsync();
            base.OnNavigatingFrom(e);
        }

        private void OnPageSizeChanged(object sender, SizeChangedEventArgs e)
        {
            this.UpdateCameraHostSize();
        }

        private void UpdateCameraHostSize()
        {
            //this.cameraHostGrid.Width = this.cameraHostGrid.ActualHeight * (this.cameraControl.CameraAspectRatio != 0 ? this.cameraControl.CameraAspectRatio : 1.777777777777);
        }

        public Scores GetLastEmotionForFace(BitmapBounds faceBox)
        {
            if (this.lastEmotionSample == null || !this.lastEmotionSample.Any())
            {
                return null;
            }

            return this.lastEmotionSample.OrderBy(f => Math.Abs(faceBox.X - f.FaceRectangle.Left) + Math.Abs(faceBox.Y - f.FaceRectangle.Top)).First().Scores;
        }

        public Face GetLastFaceAttributesForFace(BitmapBounds faceBox)
        {
            if (this.lastDetectedFaceSample == null || !this.lastDetectedFaceSample.Any())
            {
                return null;
            }

            return Util.FindFaceClosestToRegion(this.lastDetectedFaceSample, faceBox);
        }

        public IdentifiedPerson GetLastIdentifiedPersonForFace(BitmapBounds faceBox)
        {
            if (this.lastIdentifiedPersonSample == null || !this.lastIdentifiedPersonSample.Any())
            {
                return null;
            }

            Tuple<Face, IdentifiedPerson> match =
                this.lastIdentifiedPersonSample.Where(f => Util.AreFacesPotentiallyTheSame(faceBox, f.Item1.FaceRectangle))
                                               .OrderBy(f => Math.Abs(faceBox.X - f.Item1.FaceRectangle.Left) + Math.Abs(faceBox.Y - f.Item1.FaceRectangle.Top)).FirstOrDefault();
            if (match != null)
            {
                return match.Item2;
            }

            return null;
        }

        public SimilarPersistedFace GetLastSimilarPersistedFaceForFace(BitmapBounds faceBox)
        {
            if (this.lastSimilarPersistedFaceSample == null || !this.lastSimilarPersistedFaceSample.Any())
            {
                return null;
            }

            SimilarFaceMatch match =
                this.lastSimilarPersistedFaceSample.Where(f => Util.AreFacesPotentiallyTheSame(faceBox, f.Face.FaceRectangle))
                                               .OrderBy(f => Math.Abs(faceBox.X - f.Face.FaceRectangle.Left) + Math.Abs(faceBox.Y - f.Face.FaceRectangle.Top)).FirstOrDefault();

            return match?.SimilarPersistedFace;
        }
    }
}
