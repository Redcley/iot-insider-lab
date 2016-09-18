"use strict";
var moment = require("moment");
require('jquery-sparkline');
//import rxjs = require('rx');
var d3 = require("d3");
var Sentiment = (function () {
    function Sentiment(name, score, count) {
        this.name = name;
        this.score = score;
        this.count = count;
    }
    return Sentiment;
}());
var AggregatedData = (function () {
    function AggregatedData() {
        this.avgAge = 0;
        this.maleCount = 0;
        this.femaleCount = 0;
        this.smallestAge = 0;
        this.largestAge = 0;
        this.sentimentCounts = [];
    }
    AggregatedData.getSentiment = function (face) {
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
    };
    AggregatedData.aggregateForImpression = function (sourceImpression) {
        var aggregations = new AggregatedData();
        sourceImpression.faces.forEach(function (agData) {
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
            }
            else {
                aggregations.sentimentCounts[sentiment.name].score += sentiment.score;
                aggregations.sentimentCounts[sentiment.name].count++;
            }
        });
        aggregations.avgAge = aggregations.avgAge / sourceImpression.faces.length;
        var largestSentiment = null;
        var keys = Object.keys(aggregations.sentimentCounts);
        for (var index = 0; index < keys.length; index++) {
            var sentName = keys[index];
            var sentiment = aggregations.sentimentCounts[sentName];
            if (largestSentiment == null) {
                largestSentiment = sentiment;
            }
            else {
                // if the current sentiment value is less than the current, reset to the current
                if (largestSentiment.count < sentiment.count) {
                    largestSentiment = sentiment;
                }
            }
        }
        aggregations.sentiment = largestSentiment;
        return aggregations;
    };
    return AggregatedData;
}());
var DashboardController = (function () {
    function DashboardController(argonneService, $interval, $log, $scope) {
        var _this = this;
        this.argonneService = argonneService;
        this.$interval = $interval;
        this.$log = $log;
        this.$scope = $scope;
        this.enableLiveStream = true;
        //public loaded: boolean = false;
        //private CAMPAIGN_ID = '3149351f-3c9e-4d0a-bfa5-d8caacfd77f0';
        this.CAMPAIGN_ID = '7c69a011-f039-4fb2-8c45-986bfae5c13d';
        this.currentAfterDate = moment.utc(); //.subtract('days', 1);        
        //this.startMonitor();
        this.initializeCharts();
        this.argonneService.getAllCampaigns().then(function (campaigns) {
            _this.campaigns = campaigns;
        });
        this.argonneService.getCampaignDetails(this.CAMPAIGN_ID).then(function (c) {
            _this.currentCampaign = c;
            // now get the current campaign details
            _this.getCampaignDetails(_this.currentCampaign);
        });
        $scope.$watch('vm.enableLiveStream', function (isEnabled, prevVal) {
            if (isEnabled == true) {
                _this.startMonitor();
            }
            else {
                _this.stopTimer();
            }
        });
    }
    DashboardController.prototype.getCampaignDetails = function (campaign) {
        this.argonneService.getCampaignAds(campaign.campaignId)
            .then(function (ads) {
            campaign.ads = ads;
        });
    };
    DashboardController.prototype.getAdDetails = function (ad) {
        this.argonneService.getAdDetails(ad.adId)
            .then(function (adDetail) {
            ad = angular.extend(ad, adDetail);
            // now get the ad's metrics
        });
    };
    DashboardController.prototype.getImpressionResult = function (impression) {
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
    };
    DashboardController.prototype.loadAddInfo = function (impression) {
        if (this.currentCampaign == null) {
            debugger;
            return;
        }
        if (this.currentCampaign.ads == null) {
            debugger;
            return;
        }
        impression.ad = this.currentCampaign.ads.find(function (ad) {
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
        angular.forEach(impression.faces, function (face, index) {
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
    };
    /*Random Data Generator */
    DashboardController.prototype.sinAndCos = function () {
        var sin = [], sin2 = [], cos = [];
        //Data is represented as an array of {x,y} pairs.
        for (var i = 0; i < 100; i++) {
            sin.push({ x: i, y: Math.sin(i / 10) });
            sin2.push({ x: i, y: i % 10 == 5 ? null : Math.sin(i / 10) * 0.25 + 0.5 });
            cos.push({ x: i, y: .5 * Math.cos(i / 10 + 2) + Math.random() / 10 });
        }
        //Line chart data should be sent as an array of series objects.
        return [
            {
                values: sin,
                key: 'Sine Wave',
                color: '#ff7f0e',
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
                area: true //area - set to true if you want this line to turn into a filled area chart.
            }
        ];
    };
    DashboardController.prototype.initializeCharts = function () {
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
        $("#chart-unique-users").sparkline([70, 80, 65, 78, 58, 80, 78, 80], {
            type: 'bar',
            height: '25',
            barWidth: 7,
            barSpacing: 4,
            barColor: 'white',
            negBarColor: '#81d4fa',
            zeroColor: '#81d4fa'
        });
        $("#invoice-line").sparkline([5, 6, 7, 9, 9, 5, 3, 2, 2, 4, 6, 7, 5, 6, 7, 9, 9, 5], {
            type: 'line',
            width: '100%',
            height: '25',
            lineWidth: 2,
            lineColor: 'white',
            fillColor: 'white',
            highlightSpotColor: '#E1D0FF',
            highlightLineColor: '#E1D0FF',
            minSpotColor: '#f44336',
            maxSpotColor: '#4caf50',
            spotColor: '#E1D0FF',
            spotRadius: 4
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
            zeroAxis: false
        });
        // Bar + line composite charts (Total Sales)
        $('#sales-compositebar').sparkline([4, 6, 7, 7, 4, 3, 2, 3, 1, 4, 6, 5, 9, 4, 6, 7, 7, 4, 6, 5, 9, 4, 6, 7], {
            type: 'bar',
            barColor: '#F6CAFD',
            height: '25',
            width: '100%',
            barWidth: '7',
            barSpacing: 2
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
            spotRadius: 4
        });
        $('#sales-compositebar').sparkline([40, 11, 5, 37, 9, 29, 18, 8, 4, 2, 5, 6, 7], {
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
            spotRadius: 4
        });
    };
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
    DashboardController.prototype.getData = function () {
        var _this = this;
        var afterTimestamp = this.currentAfterDate.utc().format("YYYY-MM-DD HH:mm");
        // now reset the time stamp to right now
        //this.currentAfterDate = moment.utc();
        this.argonneService.getCampaignAggregate(this.CAMPAIGN_ID, afterTimestamp).then(function (aggregatedData) {
            aggregatedData.forEach(function (data, index) {
                //if (this.campaignAgData == null) {
                _this.campaignAgData = data;
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
            .then(function (impressions) {
            //if (this.impressions == null) {
            _this.impressions = impressions;
            //this.aggregatedData = new AggregatedData(); 
            //} else {
            //    this.impressions = this.impressions.concat(impressions);
            //}
            //this.$log.log('Retreived ' + this.impressions.length + ' impressions after ' + this.currentAfterDate.format());
            // now aggregate the campaigns impressions
            _this.aggregatedData = new AggregatedData();
            var totalImpressionSentiments = [];
            impressions.forEach(function (imp) {
                // calculate and add
                var impressionsAggregations = AggregatedData.aggregateForImpression(imp);
                _this.aggregatedData.avgAge += impressionsAggregations.avgAge;
                _this.aggregatedData.femaleCount += impressionsAggregations.femaleCount;
                _this.aggregatedData.maleCount += impressionsAggregations.maleCount;
                if (_this.aggregatedData.largestAge < impressionsAggregations.largestAge || _this.aggregatedData.largestAge == 0) {
                    _this.aggregatedData.largestAge = impressionsAggregations.largestAge;
                }
                if (_this.aggregatedData.smallestAge > impressionsAggregations.smallestAge || _this.aggregatedData.smallestAge == 0) {
                    _this.aggregatedData.smallestAge = impressionsAggregations.smallestAge;
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
                    }
                    else {
                        totalImpressionSentiments[impressionsAggregations.sentiment.name].score += impressionsAggregations.sentiment.score;
                        totalImpressionSentiments[impressionsAggregations.sentiment.name].count++;
                    }
                }
            });
            // average out all of the impressions aggregated age
            _this.aggregatedData.avgAge = _this.aggregatedData.avgAge / impressions.length;
            var keys = Object.keys(totalImpressionSentiments);
            var overallSentiment;
            for (var index = 0; index < keys.length; index++) {
                var sentName = keys[index];
                var sentiment = totalImpressionSentiments[sentName];
                if (overallSentiment == null) {
                    overallSentiment = sentiment;
                }
                else {
                    // if the current sentiment value is less than the current, reset to the current
                    if (overallSentiment.count < sentiment.count) {
                        overallSentiment = sentiment;
                    }
                }
            }
            _this.aggregatedData.sentiment = overallSentiment;
            debugger;
        });
        //this.currentAfterDate = this.currentAfterDate.subtract("month", 1);
        //$timeout(() => {
        //    debugger;
        //    this.loaded = true;
        //}, 3000);
    };
    DashboardController.prototype.startMonitor = function () {
        var _this = this;
        if (this.liveStreamTimer != null) {
            return;
        }
        // kickoff the initial call
        this.getData();
        this.liveStreamTimer = this.$interval(function () { return _this.getData(); }, 15000);
    };
    DashboardController.prototype.stopTimer = function () {
        if (this.liveStreamTimer == null) {
            return;
        }
        this.$interval.cancel(this.liveStreamTimer);
        this.liveStreamTimer = null;
    };
    DashboardController.$inject = ['argonneService', '$interval', '$log', '$scope'];
    return DashboardController;
}());
exports.dashboard = {
    templateUrl: 'src/app/dashboard/dashboard.html',
    controller: DashboardController,
    controllerAs: 'vm'
};
//# sourceMappingURL=dashboard.js.map