import {ArgonneService} from '../services/argonneService.ts';
import moment = require("moment");
import 'jquery-sparkline';
//import rxjs = require('rx');
import d3 = require("d3");

interface CampaignDto extends ArgonneService.Models.CampaignDto {
    ads: ArgonneService.Models.AdDto[];
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
    public campaigns: CampaignDto[];
    public currentCampaign: CampaignDto;
    public enableLiveStream: boolean = true;
    public liveStreamTimer: ng.IPromise<any>;
    public campaignAgData: ArgonneService.Models.AdAggregateData;
    public uniqueChartOptions: any;
    public uniqueChartData: any;
    public aggregatedData: AggregatedData;

    //public loaded: boolean = false;
    //private CAMPAIGN_ID = '3149351f-3c9e-4d0a-bfa5-d8caacfd77f0';
    private CAMPAIGN_ID = '7c69a011-f039-4fb2-8c45-986bfae5c13d';

    static $inject = ['argonneService', '$interval', '$log', '$scope'];

    constructor(private argonneService: ArgonneService, private $interval: ng.IIntervalService, private $log: ng.ILogService, private $scope: ng.IScope) {
        this.currentAfterDate = moment.utc();//.subtract('days', 1);        

        //this.startMonitor();
        this.initializeCharts();

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

    public getAdDetails(ad: ArgonneService.Models.AdDto) {
        this.argonneService.getAdDetails(ad.adId)
            .then((adDetail) => {
                ad = angular.extend(ad, adDetail);

                // now get the ad's metrics
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
        impression.avgSadness = impression.avgSadness / impression.faces.length;
        impression.avgSurprise = impression.avgSurprise / impression.faces.length;
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
    }

    private initializeCharts() {

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

        this.uniqueChartData = this.sinAndCos();

        (<AJQuery>$("#chart-unique-users")).sparkline([70, 80, 65, 78, 58, 80, 78, 80], {
            type: 'bar',
            height: '25',
            barWidth: 7,
            barSpacing: 4,
            barColor: 'white', //rgba(233, 30, 99, 0.4)
            negBarColor: '#81d4fa',
            zeroColor: '#81d4fa',
        });

        (<AJQuery>$("#invoice-line")).sparkline([5, 6, 7, 9, 9, 5, 3, 2, 2, 4, 6, 7, 5, 6, 7, 9, 9, 5], {
            type: 'line',
            width: '100%',
            height: '25',
            lineWidth: 2,
            lineColor: 'white', //#E1D0FF
            fillColor: 'white', //#C7FCC9
            highlightSpotColor: '#E1D0FF',
            highlightLineColor: '#E1D0FF',
            minSpotColor: '#f44336',
            maxSpotColor: '#4caf50',
            spotColor: '#E1D0FF',
            spotRadius: 4,

            // //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        });


        // Tristate chart (Today Profit)
        (<AJQuery>$("#profit-tristate")).sparkline([2, 3, 0, 4, -5, -6, 7, -2, 3, 0, 2, 3, -1, 0, 2, 3, 3, -1, 0, 2, 3], {
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
        (<AJQuery>$('#sales-compositebar')).sparkline([4, 6, 7, 7, 4, 3, 2, 3, 1, 4, 6, 5, 9, 4, 6, 7, 7, 4, 6, 5, 9, 4, 6, 7], {
            type: 'bar',
            barColor: '#F6CAFD',
            height: '25',
            width: '100%',
            barWidth: '7',
            barSpacing: 2,
            //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        });
        (<AJQuery>$('#sales-compositebar')).sparkline([4, 1, 5, 7, 9, 9, 8, 8, 4, 2, 5, 6, 7], {
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

        (<AJQuery>$('#sales-compositebar')).sparkline([40, 11, 5, 37, 9, 29, 18, 8, 4, 2, 5, 6, 7], {
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

    //public getSentiment(face: ArgonneService.Models.FaceForImpressionDto) {
    //    var sentiment = 'anger';
    //    var sentimentValue = face.scoreAnger;

    //    if (sentimentValue < face.scoreContempt) {
    //        sentiment = 'contempt';
    //        sentimentValue = face.scoreContempt;
    //    }

    //    if (sentimentValue < face.scoreDisgust) {
    //        sentiment = 'disgust';
    //        sentimentValue = face.scoreDisgust;
    //    }

    //    if (sentimentValue < face.scoreFear) {
    //        sentiment = 'fear';
    //        sentimentValue = face.scoreFear;
    //    }

    //    if (sentimentValue < face.scoreHappiness) {
    //        sentiment = 'happiness';
    //        sentimentValue = face.scoreHappiness;
    //    }

    //    if (sentimentValue < face.scoreNeutral) {
    //        sentiment = 'neutral';
    //        sentimentValue = face.scoreNeutral;
    //    }

    //    if (sentimentValue < face.scoreSadness) {
    //        sentiment = 'sadness';
    //        sentimentValue = face.scoreSadness;
    //    }

    //    if (sentimentValue < face.scoreSurprise) {
    //        sentiment = 'surprise';
    //        sentimentValue = face.scoreSurprise;
    //    }

    //    return new Sentiment(sentiment, sentimentValue, 1);
    //}

    private getData() {
        var afterTimestamp = this.currentAfterDate.utc().format("YYYY-MM-DD HH:mm");

        // now reset the time stamp to right now
        //this.currentAfterDate = moment.utc();


        this.argonneService.getCampaignAggregate(this.CAMPAIGN_ID, afterTimestamp).then((aggregatedData: ArgonneService.Models.AdAggregateData[]) => {
            aggregatedData.forEach((data: ArgonneService.Models.AdAggregateData, index) => {
                //if (this.campaignAgData == null) {
                this.campaignAgData = data;
                /*} else {
                    //this.campaignAgData = new ArgonneService.Models.AdAggregateData();
                    this.campaignAgData.ageBracket1 += data.ageBracket1;
                    this.campaignAgData.ageBracket2 += data.ageBracket2;
                    this.campaignAgData.ageBracket3 += data.ageBracket3;
                    this.campaignAgData.ageBracket4 += data.ageBracket4;
                    this.campaignAgData.ageBracket5 += data.ageBracket5;
                    this.campaignAgData.ageBracket6 += data.ageBracket6;
                    this.campaignAgData.totalFaces += data.totalFaces;
                    this.campaignAgData.uniqueFaces += data.uniqueFaces;
                    this.campaignAgData.females += data.females;
                    this.campaignAgData.males += data.males;                    
                }*/
            });
        });

        this.argonneService
            .getImpressionsForCampaign(this.CAMPAIGN_ID, afterTimestamp)
            .then((impressions) => {
                //if (this.impressions == null) {
                this.impressions = impressions;
                //this.aggregatedData = new AggregatedData(); 
                //} else {
                //    this.impressions = this.impressions.concat(impressions);
                //}

                //this.$log.log('Retreived ' + this.impressions.length + ' impressions after ' + this.currentAfterDate.format());

                // now aggregate the campaigns impressions

                this.aggregatedData = new AggregatedData();
                
                var totalImpressionSentiments: Sentiment[] = [];

                impressions.forEach((imp) => {
                    // calculate and add
                    var impressionsAggregations: AggregatedData = AggregatedData.aggregateForImpression(imp);

                    this.aggregatedData.avgAge += impressionsAggregations.avgAge;
                    this.aggregatedData.femaleCount += impressionsAggregations.femaleCount;
                    this.aggregatedData.maleCount += impressionsAggregations.maleCount;

                    if (this.aggregatedData.largestAge < impressionsAggregations.largestAge || this.aggregatedData.largestAge == 0) {
                        this.aggregatedData.largestAge = impressionsAggregations.largestAge;
                    }

                    if (this.aggregatedData.smallestAge > impressionsAggregations.smallestAge || this.aggregatedData.smallestAge == 0) {
                        this.aggregatedData.smallestAge = impressionsAggregations.smallestAge;
                    }

                    //this.aggregatedData.sentimentCounts = angular.merge({}, this.aggregatedData.sentimentCounts, impressionsAggregations.sentimentCounts);
                    //for (var sent in impressionsAggregations.sentimentCounts) {
                    //    if (this.aggregatedData.sentimentCounts[sent] == null) {
                    //        this.aggregatedData.sentimentCounts[sent] = sent;
                    //    } else {
                    //        this.aggregatedData.sentimentCounts[sent] += sent.value;
                    //    }
                    //}

                    //var keys = Object.keys(impressionsAggregations.sentimentCounts);

                    //for (var index = 0; index < keys.length; index++) {
                    //    var sentName = keys[index];
                    //    var sent = impressionsAggregations.sentimentCounts[sentName];

                    //    if (this.aggregatedData.sentimentCounts[sentName] == null) {
                    //        this.aggregatedData.sentimentCounts[sentName] = sent;
                    //    } else {
                    //        this.aggregatedData.sentimentCounts[sentName].value += sent.value;
                    //        this.aggregatedData.sentimentCounts[sentName].count++;
                    //    }
                    //}

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
                debugger;                
            })
            ;        

        //this.currentAfterDate = this.currentAfterDate.subtract("month", 1);

        //$timeout(() => {
        //    debugger;
        //    this.loaded = true;
        //}, 3000);
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
    templateUrl: 'src/app/dashboard/dashboard.html',
    controller: DashboardController,
    controllerAs: 'vm'
};
