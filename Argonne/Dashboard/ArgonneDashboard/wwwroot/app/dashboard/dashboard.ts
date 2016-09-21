import {ArgonneService} from '../services/argonneService.ts';
import moment = require("moment");
//import 'jquery-sparkline';
//import rxjs = require('rx');
//import d3 = require("d3");

interface CampaignDto extends ArgonneService.Models.CampaignDto {
    ads: ArgonneService.Models.AdInCampaignDto[];
}

class Sentiment {
    public name: string;
    public score: number;   // total score of the sentiment
    public count: number;   // total count of the sent

    constructor(name: string, score: number, count: number) {
        this.name = name;
        this.score = score;
        this.count = count;
    }
}

class AggregatedData {
    public sentiment: Sentiment;
    public avgAge: number = 0;
    public maleCount: number = 0;
    public femaleCount: number = 0;

    public smallestAge: number = 0;
    public largestAge: number = 0;

    public sentimentCounts: Sentiment[] = [];

    constructor() {
    }

    public static getSentiment(face: ArgonneService.Models.FaceForImpressionDto) {
        var sentiment = 'anger';
        var sentimentValue = face.scoreAnger;

        if (sentimentValue < face.scoreContempt) {
            sentiment = 'contempt';
            sentimentValue = face.scoreContempt;
        }

        if (sentimentValue < face.scoreDisgust) {
            sentiment = 'disgust';
            sentimentValue = face.scoreDisgust;
        }

        if (sentimentValue < face.scoreFear) {
            sentiment = 'fear';
            sentimentValue = face.scoreFear;
        }

        if (sentimentValue < face.scoreHappiness) {
            sentiment = 'happiness';
            sentimentValue = face.scoreHappiness;
        }

        if (sentimentValue < face.scoreNeutral) {
            sentiment = 'neutral';
            sentimentValue = face.scoreNeutral;
        }

        if (sentimentValue < face.scoreSadness) {
            sentiment = 'sadness';
            sentimentValue = face.scoreSadness;
        }

        if (sentimentValue < face.scoreSurprise) {
            sentiment = 'surprise';
            sentimentValue = face.scoreSurprise;
        }

        return new Sentiment(sentiment, sentimentValue, 1);
    }

    public static aggregateForImpression(sourceImpression: ArgonneService.Models.ImpressionDto): AggregatedData {
        // TODO: should really get the aggregation from services than doing it this way
        var aggregations: AggregatedData = new AggregatedData();

        sourceImpression.faces.forEach((agData) => {
            aggregations.avgAge += agData.age;
            aggregations.femaleCount += agData.gender == 'female' ? 1 : 0;
            aggregations.maleCount += agData.gender == 'male' ? 1 : 0;

            if (agData.age > aggregations.largestAge || aggregations.largestAge == 0) {
                aggregations.largestAge = agData.age;
            }

            if (agData.age < aggregations.smallestAge || aggregations.smallestAge == 0) {
                aggregations.smallestAge = agData.age;
            }

            var sentiment = AggregatedData.getSentiment(agData);

            if (aggregations.sentimentCounts[sentiment.name] == null) {
                aggregations.sentimentCounts[sentiment.name] = new Sentiment(sentiment.name, sentiment.score, 1);
            } else {
                aggregations.sentimentCounts[sentiment.name].score += sentiment.score;
                aggregations.sentimentCounts[sentiment.name].count++;
            }
        });

        aggregations.avgAge = aggregations.avgAge / sourceImpression.faces.length;

        var largestSentiment: Sentiment = null;

        var keys = Object.keys(aggregations.sentimentCounts);

        for (var index = 0; index < keys.length; index++) {
            var sentName = keys[index];
            var sentiment = aggregations.sentimentCounts[sentName];

            if (largestSentiment == null) {
                largestSentiment = sentiment;
            } else {
                // if the current sentiment value is less than the current, reset to the current
                if (largestSentiment.count < sentiment.count) {
                    largestSentiment = sentiment;
                }
            }
        }

        aggregations.sentiment = largestSentiment;

        return aggregations;

    }
}

class DashboardController {
    private currentAfterDate: any;
    public impressions: ArgonneService.Models.ImpressionDto[];
    public currentCampaign: CampaignDto;
    public enableLiveStream: boolean = true;
    public liveStreamTimer: ng.IPromise<any>;
    public campaignAgData: ArgonneService.Models.AdAggregateData;
    public uniqueChartOptions: any;
    public uniqueChartData: any;
    public aggregatedData: AggregatedData;
    public adImpressions: AggregatedData[] = []; // stores the impressions by adid
    public chartAdGenderData: any[][];
    public chartAdGenderOptions: any;
    public chartAdGenderLabels: string[];
    public chartAdGenderSeries: string[];
    public chartAdGenderType: string;
    public chartAdGenderDatasetOverride: any[];    
    public chartImpressionSentimentType: string = 'line';
    public chartImpressionSentimentData: any[];
    public chartImpressionSentimentLabels: string[];
    public chartImpressionSentimentSeries: string[];
    public chartImpressionSentimentOption: any;
    public chartImpressionSentitmentDatasetOverride: any[];
    public currentCampaignId: string;
    public allCampaigns: ArgonneService.Models.CampaignDto[];

    // Specify the default campaign
    private CAMPAIGN_ID = <Default Campaign ID Here>;

    constructor(private argonneService: ArgonneService, private $interval: ng.IIntervalService, private $log: ng.ILogService, private $scope: ng.IScope, private $q: ng.IQService, private $stateParams: any) {
        this.currentAfterDate = moment.utc();//.subtract('days', 1);

        if ($stateParams.campaignId == null || $stateParams.campaignId == '') {
            this.currentCampaignId = this.CAMPAIGN_ID;
        }
        else {
            this.currentCampaignId = $stateParams.campaignId;
        }

        // kickoff the initdata
        this.initData();

        var self = this;

        $scope.$watch('vm.currentCampaignId', function (newCampaignId, oldCampaignId) {
            if (newCampaignId != null) {
                self.initData();
            }
        });

        $scope.$watch('vm.enableLiveStream', function (isEnabled, prevVal) {
            if (isEnabled == true) {
                self.startMonitor();
            }
            else {
                self.stopTimer();
            }
        });
    }

    public loadCampaigns() {        
        this.argonneService.getAllCampaigns()
            .then(function (allCamp) {
                return this.allCampaigns = allCamp;
            });
    };

    public getCampaignDetails(campaign: CampaignDto, allAds: ArgonneService.Models.AdDto[]) {
        this.argonneService.getCampaignAds(campaign.campaignId)
            .then((ads) => {
                campaign.ads = ads;

                // now go through each ad and fill in the details
                campaign.ads.forEach((c: ArgonneService.Models.AdInCampaignDto) => {
                    // now find the 

                    var foundAd = allAds.find(a => a.adId == c.adId);

                    angular.merge(c, foundAd);
                });

                // init the chart.
                this.initGenderChart();
                this.initLiveSentimentChart();
            });
    }

    public getAdDetails(ad: ArgonneService.Models.AdDto) {
        //this.argonneService.getAdDetails(ad.adId)
        //    .then((adDetail) => {
        //        ad = angular.extend(ad, adDetail);

        //        ad.aggregated = this.adImpressions[ad.adId];

        //        // now get the ad's metrics
        //    });
    }

    private updateChart() {
        this.chartAdGenderData = [
            [this.campaignAgData.ageBracket1, this.campaignAgData.ageBracket2, this.campaignAgData.ageBracket3, this.campaignAgData.ageBracket4, this.campaignAgData.ageBracket5, this.campaignAgData.ageBracket6]
            //this.currentCampaign.ads.map(v => v.males),
            //this.currentCampaign.ads.map(v => v.females),
            //this.currentCampaign.ads.map(v => v.males + v.females)            
        ];
    }

    private initLiveSentimentChart() {
        this.chartImpressionSentitmentDatasetOverride = [
            {
                label: "Male",
                //fillColor: "rgba(255,255,255,0)",
                fill: false,
                //strokeColor: "#fff",
                //pointColor: "#00796b ",
                //pointStrokeColor: "#fff",
                //pointHighlightFill: "#fff",
                //pointHighlightStroke: "rgba(220,220,220,1)"
            },
            {
                label: "Female",
                //fillColor: "rgba(255,255,255,0)",
                //fill: false,
                //strokeColor: "#fff",
                //pointColor: "#00796b ",
                //pointStrokeColor: "#fff",
                //pointHighlightFill: "#fff",
                //pointHighlightStroke: "rgba(220,220,220,1)"
            }
        ];

        this.chartImpressionSentimentLabels = [];
        //this.chartImpressionSentimentSeries = ['Sentiment'];
        this.chartImpressionSentimentOption = {
            scaleShowGridLines: false,
            bezierCurve: true,
            scaleFontSize: 12,
            scaleFontStyle: "normal",
            scaleFontColor: "#fff",
            responsive: true,
            scales: {
                xAxes: [{
                    //stacked: true,
                    display: false
                }],
                yAxes: [{
                    //stacked: true,
                    display: false
                }]
            }
        };

        this.chartImpressionSentimentData = [];        
    }

    private initGenderChart() {
        var ageCategories = ['0-15', '16-19', '20s', '30s', '40s', '50s+'];

        // Configure all line charts                
        this.chartAdGenderData = [[]];

        this.chartAdGenderDatasetOverride = [
            {
                type: 'bar',
                backgroundColor: 'rgba(72, 111, 136, 0.7)',
                borderWidth: 0
            },
            {
                type: 'bar'
            },
            {
                type: 'bar',
                backgroundColor: "#46BFBD",
                borderWidth: 0,
            }
        ];

        this.chartAdGenderType = "bar";
        this.chartAdGenderLabels = ageCategories;
        //this.chartAdGenderSeries = ['Female', 'Male'];
        this.chartAdGenderOptions = {
            //fillColor: "#46BFBD",
            //strokeColor: "#46BFBD",
            //scaleGridLineColor: "rgba(255,255,255,0.4)",//String - Colour of the grid lines		
            //highlightFill: "rgba(70, 191, 189, 0.4)",
            //highlightStroke: "rgba(70, 191, 189, 0.9)",
            //scaleFontStyle: "normal",// String - Scale label font weight style		
            //scaleFontColor: "#fff",// String - Scale label font colour
            scaleShowGridLines: false,///Boolean - Whether grid lines are shown across the chart
            showScale: false,
            animationSteps: 15,
            //tooltipTitleFontFamily: "'Roboto','Helvetica Neue', 'Helvetica', 'Arial', sans-serif",// String - Tooltip title font declaration for the scale label		
            responsive: true,
            scales: {
                xAxes: [{
                    stacked: true,
                    display: true
                }],
                yAxes: [{
                    stacked: true,
                    display: false
                }]
            }
        };        
    }

    private initData() {
        this.$q.all([this.argonneService.getAllAds(),
            this.argonneService.getCampaignDetails(this.CAMPAIGN_ID)])
            .then((resolves: any[]) => {
                var allAds = resolves[0];

                this.currentCampaign = resolves[1] as CampaignDto;

                // now get the current campaign details
                this.getCampaignDetails(this.currentCampaign, allAds);
            });
    }

    private getData() {
        var afterTimestamp = this.currentAfterDate.utc().format("YYYY-MM-DDTH:m");

        this.argonneService.getCampaignAggregate(this.CAMPAIGN_ID, afterTimestamp).then((campaignAdAggregations: ArgonneService.Models.AdAggregateData[]) => {

            if (this.currentCampaign != null && this.currentCampaign.ads != null) {
                this.currentCampaign.ads.forEach((ad) => {
                    // find the aggregate
                    var foundAggregation = campaignAdAggregations.find(adAg => ad.adId == adAg.adId);

                    angular.merge(ad, foundAggregation);
                });                
            }

            if (campaignAdAggregations != null && campaignAdAggregations.length > 0) {
                this.campaignAgData = campaignAdAggregations[0];
                // update the demo chart
                this.updateChart();
            }
        });

        this.argonneService
            .getImpressionsForCampaign(this.CAMPAIGN_ID, afterTimestamp)
            .then((impressions) => {
                this.impressions = impressions;
                // now aggregate the campaigns impressions

                this.aggregatedData = new AggregatedData();

                this.adImpressions = [];
                this.chartImpressionSentimentLabels = [];
                this.chartImpressionSentimentData = [];

                var totalImpressionSentiments: Sentiment[] = [];


                impressions.forEach((imp: ArgonneService.Models.ImpressionDto) => {
                    // calculate and add                    
                    var impressionsAggregations: AggregatedData = AggregatedData.aggregateForImpression(imp);

                    if (this.adImpressions[imp.displayedAdId] == null) {
                        this.adImpressions[imp.displayedAdId] = impressionsAggregations;
                    } else {
                        this.adImpressions[imp.displayedAdId].femaleCount += impressionsAggregations.femaleCount;
                        this.adImpressions[imp.displayedAdId].maleCount += impressionsAggregations.maleCount;
                        this.adImpressions[imp.displayedAdId].avgAge = (this.adImpressions[imp.displayedAdId].avgAge + impressionsAggregations.avgAge) / 2;
                    }

                    this.aggregatedData.avgAge += impressionsAggregations.avgAge;
                    this.aggregatedData.femaleCount += impressionsAggregations.femaleCount;
                    this.aggregatedData.maleCount += impressionsAggregations.maleCount;

                    if (this.aggregatedData.largestAge < impressionsAggregations.largestAge || this.aggregatedData.largestAge == 0) {
                        this.aggregatedData.largestAge = impressionsAggregations.largestAge;
                    }

                    if (this.aggregatedData.smallestAge > impressionsAggregations.smallestAge || this.aggregatedData.smallestAge == 0) {
                        this.aggregatedData.smallestAge = impressionsAggregations.smallestAge;
                    }

                    if (impressionsAggregations.sentiment != null) {
                        // keep a running ocunt of the evaluated sentiments
                        if (totalImpressionSentiments[impressionsAggregations.sentiment.name] == null) {
                            totalImpressionSentiments[impressionsAggregations.sentiment.name] = impressionsAggregations.sentiment;
                        } else {
                            totalImpressionSentiments[impressionsAggregations.sentiment.name].score += impressionsAggregations.sentiment.score;
                            totalImpressionSentiments[impressionsAggregations.sentiment.name].count++;
                        }
                    }

                    // now update the impression chart, build the chart labels and data
                    this.chartImpressionSentimentLabels.push(imp.deviceTimestamp.toString());

                    if (impressionsAggregations.sentiment.name == 'happiness') {
                        this.chartImpressionSentimentData.push(3);
                    } else if (impressionsAggregations.sentiment.name == 'surprise') {
                        this.chartImpressionSentimentData.push(2);
                    } else if (impressionsAggregations.sentiment.name == 'contempt') {
                        this.chartImpressionSentimentData.push(1);
                    } else if (impressionsAggregations.sentiment.name == 'neutral') {
                        this.chartImpressionSentimentData.push(0);
                    } else if (impressionsAggregations.sentiment.name == 'fear') {
                        this.chartImpressionSentimentData.push(-1);
                    } else if (impressionsAggregations.sentiment.name == 'sadness') {
                        this.chartImpressionSentimentData.push(-2);
                    } else if (impressionsAggregations.sentiment.name == 'disgust') {
                        this.chartImpressionSentimentData.push(-3);
                    } else if (impressionsAggregations.sentiment.name == 'anger') {
                        this.chartImpressionSentimentData.push(-4);
                    }

                    //this.chartImpressionSentimentData.push(impressionsAggregations.avgAge);//impressionsAggregations.maleCount, impressionsAggregations.femaleCount]);
                });

                // average out all of the impressions aggregated age
                this.aggregatedData.avgAge = this.aggregatedData.avgAge / impressions.length;

                var keys = Object.keys(totalImpressionSentiments);
                var overallSentiment: Sentiment;

                for (var index = 0; index < keys.length; index++) {
                    var sentName = keys[index];
                    var sentiment = totalImpressionSentiments[sentName];

                    if (overallSentiment == null) {
                        overallSentiment = sentiment;
                    } else {
                        // if the current sentiment value is less than the current, reset to the current
                        if (overallSentiment.count < sentiment.count) {
                            overallSentiment = sentiment;
                        }
                    }
                }

                this.aggregatedData.sentiment = overallSentiment;                
            });
    }

    private startMonitor() {
        if (this.liveStreamTimer != null) {
            return;
        }

        // kickoff the initial call
        this.getData();

        this.liveStreamTimer = this.$interval(() => this.getData(), 15000);
    }

    private stopTimer() {
        if (this.liveStreamTimer == null) {
            return;
        }

        this.$interval.cancel(this.liveStreamTimer);

        this.liveStreamTimer = null;
    }
}

export const dashboard: angular.IComponentOptions = {
    templateUrl: 'wwwroot/app/dashboard/dashboard.html',
    controller: DashboardController,
    controllerAs: 'vm'
};
