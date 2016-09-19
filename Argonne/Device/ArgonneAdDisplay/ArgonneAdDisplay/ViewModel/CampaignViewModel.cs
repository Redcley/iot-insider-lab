using Argonne.Common.ArgonneService;
using Argonne.Common.ArgonneService.Models;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Threading;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Windows.UI.Xaml;

namespace ArgonneAdDisplay.ViewModel
{
    public class CampaignViewModel : ViewModelBase
    {
        //private const string CLIENT_URL = "http://localhost:44685/";
        private const string CLIENT_URL = "http://api-argonne.azurewebsites.net";
        private const String DEBUG_DEVICE_ID = "1117163c-b8e5-41fd-9cb7-0062d36a14f2";
        //private const String CAMPAIGN_ID = "7c69a011-f039-4fb2-8c45-986bfae5c13d";
        private const String CAMPAIGN_ID = "3149351F-3C9E-4D0A-BFA5-D8CAACFD77F0";

        // timer to swap out the ad based on the settings
        private Timer adTimer;
        private int currentAdIndex = -1;
        private IArgonneServiceClient argonneService;

        private IList<AdInCampaignDto> currentCampaignAds;

        public CampaignViewModel(IArgonneServiceClient argonneService)
        {
            this.argonneService = argonneService;

            // TODO: Use config
            this.argonneService.BaseUri = new Uri(CLIENT_URL);

            Initialize();

        }        

        public async Task<bool> Initialize()
        {            
            // get the device campaign  
            this.Campaign = await argonneService.ApiAdminCampaignByIdGetAsync(CAMPAIGN_ID);

            //if (campaigns == null || campaigns.Count == 0)
            //{
            //    // TODO: Error handling here when can't find campaign
            //    throw new InvalidOperationException("No campaign");
            //}

            //// TODO: Match campaigns to device
            //this.Campaign = campaigns[0];

            // now get the adds            
            currentCampaignAds = await argonneService.ApiAdminCampaignByCampaignidAdsGetAsync(this.Campaign.CampaignId);

            if (currentCampaignAds == null || currentCampaignAds.Count == 0)
            {
                // TODO: Error handling here when can't find any ads
                throw new InvalidOperationException("No ads for campaign");
            }

            // immediately kickoff the timer callback
            this.adTimer = new Timer(UpdateCampaign, null, 0, Timeout.Infinite);                       

            return true;
        }

        private void UpdateCampaign(Object stateInfo)
        {
            if (currentAdIndex == this.currentCampaignAds.Count - 1)
            {
                // start over
                this.currentAdIndex = 0;
            }
            else
            {
                this.currentAdIndex++;
            }

            DispatcherHelper.CheckBeginInvokeOnUI(() =>
            {
                this.CurrentAdInfo = this.currentCampaignAds.ElementAtOrDefault(this.currentAdIndex);

                // now create the timer.
                // duration = how long to show the ad
                // first impression = when to take the impression
                // impression interval = how often to take the picture
                this.adTimer.Change((CurrentAdInfo.Duration.Value * 1000), Timeout.Infinite);
                //Task.Run(() => this.UpdateCampaign(null));

                // get the add

                this.CurrentAd = this.argonneService.ApiAdminAdByIdGet(this.CurrentAdInfo.AdId);                
            });            
        }

        #region CurrentAd
        /// <summary>
        /// The <see cref="CurrentAd" /> property's name.
        /// </summary>
        public const string CurrentAdPropertyName = "CurrentAd";

        private AdDto _currentAd = null;

        /// <summary>
        /// Sets and gets the CurrentAd property.
        /// Changes to that property's value raise the PropertyChanged event. 
        /// </summary>
        public AdDto CurrentAd
        {
            get
            {                
                return _currentAd;
            }
            set
            {
                Set(() => CurrentAd, ref _currentAd, value);
            }
        }

        #endregion

        #region Campaign
        /// <summary>
        /// The <see cref="Campaign" /> property's name.
        /// </summary>
        public const string CampaignPropertyName = "Campaign";

        private CampaignDto campaign = null;

        /// <summary>
        /// Sets and gets the Campaign property.
        /// Changes to that property's value raise the PropertyChanged event. 
        /// </summary>
        public CampaignDto Campaign
        {
            get
            {
                return campaign;
            }
            set
            {
                Set(() => Campaign, ref campaign, value);
            }
        }
        #endregion

        #region CurrentAdInfo
        /// <summary>
        /// The <see cref="CurrentAdInfo" /> property's name.
        /// </summary>
        public const string CurrentAdInfoPropertyName = "CurrentAdInfo";

        private AdInCampaignDto _currentAdInfo = null;

        /// <summary>
        /// Sets and gets the AdInCampaignDto property.
        /// Changes to that property's value raise the PropertyChanged event. 
        /// </summary>
        public AdInCampaignDto CurrentAdInfo
        {
            get
            {
                return _currentAdInfo;
            }
            set
            {
                Set(() => CurrentAdInfo, ref _currentAdInfo, value);
            }
        }
        #endregion      
    }
}
