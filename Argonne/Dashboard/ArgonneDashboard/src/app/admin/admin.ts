import {ArgonneService} from '../services/argonneService.ts';
import moment from 'moment';

import 'jquery-sparkline';

interface CampaignDto extends Argonne.Services.ArgonneService.Models.CampaignDto {
    ads: Argonne.Services.ArgonneService.Models.AdDto[];    
}

class AdminController {
    static $inject = ['argonneService', '$interval', '$log', '$scope'];
    private currentAfterDate: moment.Moment = moment();//.subtract('days', 1);
    public impressions: Argonne.Services.ArgonneService.Models.ImpressionDto[];
    public campaigns: CampaignDto[];
    public currentCampaign: CampaignDto;
    public moment = moment;
    public enableLiveStream: boolean = true;
    public liveStreamTimer: ng.IPromise<any>;    

    //public loaded: boolean = false;
    private CAMPAIGN_ID = '3149351f-3c9e-4d0a-bfa5-d8caacfd77f0';

    constructor(private argonneService: ArgonneService, private $interval: ng.IIntervalService, private $log: ng.ILogService, private $scope: ng.IScope) {
        //this.startMonitor();
        this.initializeCharts();
        this

        this.argonneService.getAllCampaigns().then((campaigns) => {
            this.campaigns = campaigns as CampaignDto[];            
        });

        this.argonneService.getCampaignDetails(this.CAMPAIGN_ID).then((c) => {
            this.currentCampaign = c as CampaignDto;

            // now get the current campaign details
            this.getCampaignDetails(this.currentCampaign);
        });

        $scope.$watch('vm.enableLiveStream', (isEnabled, prevVal) => {
            if (isEnabled == true) {
                this.startMonitor();
            } else {
                this.stopTimer();
            }
        });
    }



    public getCampaignDetails(campaign: CampaignDto) {        
        this.argonneService.getCampaignAds(campaign.campaignId)
            .then((ads) => {                
                campaign.ads = ads;                
            });
    }

    public getAdDetails(ad: Argonne.Services.ArgonneService.Models.AdDto) {        
        this.argonneService.getAdDetails(ad.adId)
            .then((adDetail) => {                
                ad = angular.extend(ad, adDetail);
            });
    }

    public getImpressionResult(impression) {
        var impressionResult = 'anger';
        var largestImpression = impression.avgAnger;

        if (largestImpression < impression.avgContempt) {
            largestImpression = impression.avgContempt;
            impressionResult = 'contempt';
        }

        if (largestImpression < impression.avgDisgust) {
            largestImpression = impression.avgDisgust;
            impressionResult = 'disgust';
        }

        if (largestImpression < impression.avgFear) {
            largestImpression = impression.avgFear;
            impressionResult = 'anger';
        }

        if (largestImpression < impression.avgHappiness) {
            largestImpression = impression.avgHappiness;
            impressionResult = 'happiness';
        }

        if (largestImpression < impression.avgNeutral) {
            largestImpression = impression.avgNeutral;
            impressionResult = 'neutral';
        }

        if (largestImpression < impression.avgSadness) {
            largestImpression = impression.avgSadness;
            impressionResult = 'sadness';
        }

        if (largestImpression < impression.avgSurprise) {
            largestImpression = impression.avgSurprise;
            impressionResult = 'surpise';
        }        

        return impressionResult;
    }

    private loadAddInfo(impression) {
        if (this.currentCampaign == null) {
            debugger;
            return;
        }

        if (this.currentCampaign.ads == null) {
            debugger;
            return;
        }

        impression.ad = this.currentCampaign.ads.find((ad) => {
            return impression.displayedAdId == ad.adId;
        });

        impression.avgAnger = 0;
        impression.avgContempt = 0;
        impression.avgDisgust = 0;
        impression.avgFear = 0;
        impression.avgHappiness = 0;
        impression.avgNeutral = 0;
        impression.avgSadness = 0;
        impression.avgSurprise = 0;

        // TODO: Do this on the server side
        // calculate the averages
        angular.forEach(impression.faces, (face, index) => {
            // sum up the scores
            impression.avgAnger += face.scoreAnger;
            impression.avgContempt += face.scoreContempt;
            impression.avgDisgust += face.scoreDisgust;
            impression.avgFear += face.scoreFear;
            impression.avgHappiness += face.scoreHappiness;
            impression.avgNeutral += face.scoreNeutral;
            impression.avgSadness += face.scoreSadness;
            impression.avgSurprise += face.scoreSurprise;
        });

        // now calcualte the avg
        impression.avgAnger = impression.avgAnger / impression.faces.length;
        impression.avgContempt = impression.avgContempt / impression.faces.length;
        impression.avgDisgust = impression.avgDisgust / impression.faces.length;
        impression.avgFear = impression.avgFear / impression.faces.length;
        impression.avgHappiness = impression.avgHappiness / impression.faces.length;
        impression.avgNeutral = impression.avgNeutral / impression.faces.length;
        impression.avgSadness = impression.avgSadness  / impression.faces.length;
        impression.avgSurprise = impression.avgSurprise  / impression.faces.length;
    }

    private initializeCharts() {
        $("#clients-bar").sparkline([70, 80, 65, 78, 58, 80, 78, 80, 70, 50, 75, 65, 80, 70, 65, 90, 65, 80, 70, 65, 90], {
            type: 'bar',
            height: '25',
            barWidth: 7,
            barSpacing: 4,
            barColor: '#C7FCC9',
            negBarColor: '#81d4fa',
            zeroColor: '#81d4fa',
        });

        $("#invoice-line").sparkline([5, 6, 7, 9, 9, 5, 3, 2, 2, 4, 6, 7, 5, 6, 7, 9, 9, 5], {
            type: 'line',
            width: '100%',
            height: '25',
            lineWidth: 2,
            lineColor: '#E1D0FF',
            fillColor: 'rgba(233, 30, 99, 0.4)',
            highlightSpotColor: '#E1D0FF',
            highlightLineColor: '#E1D0FF',
            minSpotColor: '#f44336',
            maxSpotColor: '#4caf50',
            spotColor: '#E1D0FF',
            spotRadius: 4,

            // //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        });


        // Tristate chart (Today Profit)
        $("#profit-tristate").sparkline([2, 3, 0, 4, -5, -6, 7, -2, 3, 0, 2, 3, -1, 0, 2, 3, 3, -1, 0, 2, 3], {
            type: 'tristate',
            width: '100%',
            height: '25',
            posBarColor: '#B9DBEC',
            negBarColor: '#C7EBFC',
            barWidth: 7,
            barSpacing: 4,
            zeroAxis: false,
            //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        });

        // Bar + line composite charts (Total Sales)
        $('#sales-compositebar').sparkline([4, 6, 7, 7, 4, 3, 2, 3, 1, 4, 6, 5, 9, 4, 6, 7, 7, 4, 6, 5, 9, 4, 6, 7], {
            type: 'bar',
            barColor: '#F6CAFD',
            height: '25',
            width: '100%',
            barWidth: '7',
            barSpacing: 2,
            //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        });
        $('#sales-compositebar').sparkline([4, 1, 5, 7, 9, 9, 8, 8, 4, 2, 5, 6, 7], {
            composite: true,
            type: 'line',
            width: '100%',
            lineWidth: 2,
            lineColor: '#fff3e0',
            fillColor: 'rgba(153,114,181,0.3)',
            highlightSpotColor: '#fff3e0',
            highlightLineColor: '#fff3e0',
            minSpotColor: '#f44336',
            maxSpotColor: '#4caf50',
            spotColor: '#fff3e0',
            spotRadius: 4,
            //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        });


    }

    private startMonitor() {
        if (this.liveStreamTimer != null) {
            return; 
        }         
        
        this.liveStreamTimer = this.$interval(() => {            
            var afterTimestamp = this.currentAfterDate.utc().format("YYYY-MM-DD HH:mm");

            this.argonneService
                .getImpressionsForCampaign(this.CAMPAIGN_ID, afterTimestamp)
                .then((impressions) => {
                    this.impressions = impressions;
                    this.$log.log('Retreived ' + this.impressions.length + ' impressions after ' + this.currentAfterDate.format());
                })
                ;

            //this.currentAfterDate = this.currentAfterDate.subtract("month", 1);

            //$timeout(() => {
            //    debugger;
            //    this.loaded = true;
            //}, 3000);
        }, 10000);
    }

    private stopTimer() {
        if (this.liveStreamTimer == null) {
            return;
        }

        this.$interval.cancel(this.liveStreamTimer);

        this.liveStreamTimer = null;
    }
}

export const admin: angular.IComponentOptions = {
    templateUrl: 'src/app/admin/admin.html',
    controller: AdminController,
    controllerAs: 'vm'
};
