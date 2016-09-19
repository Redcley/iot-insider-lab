import {ArgonneService} from '../services/argonneService.ts';
import moment = require("moment");
import 'jquery-sparkline';
//import rxjs = require('rx');
//import d3 = require("d3");

interface CampaignDto extends ArgonneService.Models.CampaignDto {
    ads: ArgonneService.Models.getCampaignAds[];
}

interface AJQuery extends JQuery {
    sparkline(data: any[], config: any);
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
    //public facesMap: { [key: string]: ArgonneService.Models.FaceForImpressionDto[]; } = {};
}

class DashboardController {
    private currentAfterDate: any;
    public impressions: ArgonneService.Models.ImpressionDto[];
    //public campaigns: CampaignDto[];
    public currentCampaign: CampaignDto;
    public enableLiveStream: boolean = true;
    public liveStreamTimer: ng.IPromise<any>;
    public campaignAgData: ArgonneService.Models.AdAggregateData;
    public uniqueChartOptions: any;
    public uniqueChartData: any;
    public aggregatedData: AggregatedData;
    public campaignAdAggregations: ArgonneService.Models.AdAggregateData[];
    public adImpressions: AggregatedData[] = []; // stores the impressions by adid
    public chartAdGenderData: any[][];
    public chartAdGenderOptions: any;
    public chartAdGenderLabels: string[];
    public chartAdGenderSeries: string[];
    public chartAdGenderType: string;
    public chartAdGenderDatasetOverride: [];
    public allAds: ArgonneService.Models.AdDto[];

    //public loaded: boolean = false;
    private CAMPAIGN_ID = '3149351f-3c9e-4d0a-bfa5-d8caacfd77f0';
    //private CAMPAIGN_ID = '7c69a011-f039-4fb2-8c45-986bfae5c13d';

    static $inject = ['argonneService', '$interval', '$log', '$scope', '$q'];

    constructor(private argonneService: ArgonneService, private $interval: ng.IIntervalService, private $log: ng.ILogService, private $scope: ng.IScope, private $q: ng.IQService) {
        this.currentAfterDate = moment.utc();//.subtract('days', 1);

        //this.startMonitor();

        //this.initializeCharts();      

        this.initData();

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

                // now go through each ad and fill in the details
                campaign.ads.forEach((c: ArgonneService.Models.AdInCampaignDto) => {
                    // now find the 

                    var foundAd = this.allAds.find(a => a.adId == c.adId);
                    
                    angular.merge(c, foundAd);                    
                });

                // init the chart.
                this.initGenderChart();
            });
    }

    public getAdDetails(ad: ArgonneService.Models.AdDto) {
        this.argonneService.getAdDetails(ad.adId)
            .then((adDetail) => {
                ad = angular.extend(ad, adDetail);

                ad.aggregated = this.adImpressions[ad.adId];

                // now get the ad's metrics
            });
    }

    private updateChart() {
        this.chartAdGenderData = [
            this.currentCampaign.ads.map(v => v.males),
            this.currentCampaign.ads.map(v => v.females),
            this.currentCampaign.ads.map(v => v.males + v.females)            
            //[65, 59, 90, 81, 56, 55, 40],
            //[28, 48, 40, 19, 96, 27, 100]
        ];
    }

    private initGenderChart() {
        // Configure all line charts        
        debugger;
        this.chartAdGenderData = [[],[],[]];

        this.chartAdGenderDatasetOverride = [
            {
                type: 'line',
                strokeColor: 'blue',
                fillColor: 'blue'
            },
            {
                type: 'line',
                strokeColor: 'red',
                fillColor: 'red',
                fill: false,
                backgroundColor: 'red'
            },
            {
                backgroundColor: "#46BFBD",
                borderWidth: 0,
            }            
        ];

        this.chartAdGenderType = "bar";
        this.chartAdGenderLabels = this.currentCampaign.ads.map(v => v.adName); //['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];        
        this.chartAdGenderSeries = ['Male', 'Female', 'Total'];
        this.chartAdGenderOptions = {
            //fillColor: "#46BFBD",
            //strokeColor: "#46BFBD",
            highlightFill: "rgba(70, 191, 189, 0.4)",
            highlightStroke: "rgba(70, 191, 189, 0.9)",
            scaleShowGridLines: false,///Boolean - Whether grid lines are shown across the chart
            showScale: false,
            animationSteps: 15,
            //tooltipTitleFontFamily: "'Roboto','Helvetica Neue', 'Helvetica', 'Arial', sans-serif",// String - Tooltip title font declaration for the scale label		
            responsive: true,
            scales: {
                xAxes: [{
                    stacked: true,
                    display: false
                }],
                yAxes: [{
                    stacked: true,
                    display: false
                }]
            }
        };

        //this.chartAdGenderData = [
        //    this.currentCampaign.ads.map(v => v.males),
        //    this.currentCampaign.ads.map(v => v.females)
        //    //[65, 59, 90, 81, 56, 55, 40],
        //    //[28, 48, 40, 19, 96, 27, 100]
        //];
    }

    private initializeCharts() {
        //this.initGenderChart();

        //this.colors = ['white', '#ff6384', '#ff8e72'];

        //this.labels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        //this.data = [
        //    [65, -59, 80, 81, -56, 55, -40],
        //    [28, 48, -40, 19, 86, 27, 90]
        //];
        /*this.datasetOverride = [
            {
                label: "Bar chart",
                borderWidth: 1,
                type: 'bar'
            },
            {
                label: "Line chart",
                borderWidth: 3,
                hoverBackgroundColor: "rgba(255,99,132,0.4)",
                hoverBorderColor: "rgba(255,99,132,1)",
                type: 'bar'
            }
        ];*/

        //this.labels = ["January", "February", "March", "April", "May", "June", "July"];
        //this.series = ['Series A', 'Series B'];
        //this.data = [
        //    [50, 30, 50, 20, 11, 8, 2],
        //    [65, 59, 80, 81, 56, 55, 40],
        //    [28, 48, 40, 19, 86, 27, 90]
        //];
        //this.onClick = function (points, evt) {
        //    console.log(points, evt);
        //};
        //this.datasetOverride = [{ yAxisID: 'y-axis-1' }, { yAxisID: 'y-axis-2' }];
        //this.options = {
        //    scales: {
        //        yAxes: [
        //            {
        //                id: 'y-axis-1',
        //                type: 'linear',
        //                display: true,
        //                position: 'left'
        //            },
        //            {
        //                id: 'y-axis-2',
        //                type: 'linear',
        //                display: true,
        //                position: 'right'
        //            }
        //        ]
        //    }
        //};

        this.uniqueChartOptions = {
            chart: {
                type: 'multiBarChart',
                height: 450,
                margin: {
                    top: 20,
                    right: 20,
                    bottom: 45,
                    left: 45
                },
                clipEdge: true,
                duration: 500,
                stacked: true,
                xAxis: {
                    axisLabel: 'Time (ms)',
                    showMaxMin: false,
                    tickFormat: function (d) {
                        return d3.format(',f')(d);
                    }
                },
                yAxis: {
                    axisLabel: 'Y Axis',
                    axisLabelDistance: -20,
                    tickFormat: function (d) {
                        return d3.format(',.1f')(d);
                    }
                }
            }
        };
    }

    private initData() {
        this.$q.all([this.argonneService.getAllAds(),
            this.argonneService.getCampaignDetails(this.CAMPAIGN_ID)])
            .then((resolves: any[]) => {
                this.allAds = resolves[0];

                this.currentCampaign = resolves[1] as CampaignDto;

                //this.campaignAdAggregations = resolves[2];

                // go through each aggregations
                //this.campaignAdAggregations.forEach((data: ArgonneService.Models.AdAggregateData, index) => {
                //    this.campaignAgData = data;

                //    debugger;

                //    // now get the map the data
                //});

                // todo: aggregate the real
                //this.campaignAgData = this.campaignAdAggregations[0];

                // now get the current campaign details
                this.getCampaignDetails(this.currentCampaign);
            });
    }

    private getData() {
        var afterTimestamp = this.currentAfterDate.subtract('days', 10).utc().format("YYYY-MM-DD HH:mm");

        //this.$q.all([this.argonneService.getAllAds(),
        //    this.argonneService.getCampaignDetails(this.CAMPAIGN_ID),
        //    this.argonneService.getCampaignAggregate(this.CAMPAIGN_ID, afterTimestamp)])
        //    .then((resolves: any[]) => {
        //        this.allAds = resolves[0];

        //        this.currentCampaign = resolves[1] as CampaignDto;

        //        this.campaignAdAggregations = resolves[2];

        //        // go through each aggregations
        //        //this.campaignAdAggregations.forEach((data: ArgonneService.Models.AdAggregateData, index) => {
        //        //    this.campaignAgData = data;

        //        //    debugger;

        //        //    // now get the map the data
        //        //});

        //        // todo: aggregate the real
        //        this.campaignAgData = this.campaignAdAggregations[0];

        //        // now get the current campaign details
        //        this.getCampaignDetails(this.currentCampaign);
        //    });

        //this.argonneService.getAllCampaigns().then((campaigns) => {
        //    this.campaigns = campaigns as CampaignDto[];
        //});

        this.argonneService.getCampaignAggregate(this.CAMPAIGN_ID, afterTimestamp).then((campaignAdAggregations: ArgonneService.Models.AdAggregateData[]) => {
            this.campaignAdAggregations = campaignAdAggregations;

            this.currentCampaign.ads.forEach((ad) => {
                // find the aggregate
                var foundAggregation = this.campaignAdAggregations.find(adAg => ad.adId == adAg.adId);

                angular.merge(ad, foundAggregation);
            });


            this.updateChart();

            // go through each aggregations
            this.campaignAdAggregations.forEach((data: ArgonneService.Models.AdAggregateData, index) => {
                this.campaignAgData = data;
            });
        });

        this.argonneService
            .getImpressionsForCampaign(this.CAMPAIGN_ID, afterTimestamp)
            .then((impressions) => {
                this.impressions = impressions;
                // now aggregate the campaigns impressions

                this.aggregatedData = new AggregatedData();

                this.adImpressions = [];

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
            })
            ;
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

    /*Random Data Generator */
    private sinAndCos() {
        var sin = [], sin2 = [],
            cos = [];

        //Data is represented as an array of {x,y} pairs.
        for (var i = 0; i < 100; i++) {
            sin.push({ x: i, y: Math.sin(i / 10) });
            sin2.push({ x: i, y: i % 10 == 5 ? null : Math.sin(i / 10) * 0.25 + 0.5 });
            cos.push({ x: i, y: .5 * Math.cos(i / 10 + 2) + Math.random() / 10 });
        }

        //Line chart data should be sent as an array of series objects.
        return [
            {
                values: sin,      //values - represents the array of {x,y} data points
                key: 'Sine Wave', //key  - the name of the series.
                color: '#ff7f0e',  //color - optional: choose your own line color.
                strokeWidth: 2,
                classed: 'dashed'
            },
            {
                values: cos,
                key: 'Cosine Wave',
                color: '#2ca02c'
            },
            {
                values: sin2,
                key: 'Another sine wave',
                color: '#7777ff',
                area: true      //area - set to true if you want this line to turn into a filled area chart.
            }
        ];
    };
}

export const dashboard: angular.IComponentOptions = {
    templateUrl: 'src/app/dashboard/dashboard.html',
    controller: DashboardController,
    controllerAs: 'vm'
};
