"use strict";
var ArgonneService = (function () {
    function ArgonneService($http) {
        this.$http = $http;
        this.BASE_URI = 'http://localhost:44685';
        //private BASE_URI: string = 'http://api-argonne.azurewebsites.net/';
        this.URI_GET_IMPRESSION = '/api/admin/Campaign/{campaignid}/Impressions';
    }
    ArgonneService.prototype.getImpressionsForCampaign = function (campaignId, showAfter) {
        if (showAfter === void 0) { showAfter = null; }
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/Impressions/After';
        return this.$http.get(url, {
            params: {
                after: showAfter,
                PageSize: 1000
            }
        })
            .then(function (response) {
            return response.data;
        });
        //return this.$http.get('/data/impressions.json')
        //    .then((response) => {
        //        debugger;
        //        this.impressions = response.data as Argonne.Services.ArgonneService.Models.ImpressionDto[];
        //        return this.impressions;
        //    });
        //var list: Models.List;
        //$http
        //    .get('src/app/techs/techs.json')
        //    .then(response => {
        //        this.techs = response.data as Tech[];
        //    });
    };
    ArgonneService.prototype.getAllCampaigns = function () {
        var url = this.BASE_URI + '/api/admin/Campaign/';
        return this.$http.get(url, {})
            .then(function (response) {
            return response.data;
        });
    };
    ArgonneService.prototype.getCampaignAds = function (campaignId) {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/Ads';
        return this.$http.get(url, {})
            .then(function (response) {
            return response.data;
        });
    };
    ArgonneService.prototype.getCampaignDetails = function (campaignId) {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId;
        return this.$http.get(url)
            .then(function (response) {
            return response.data;
        });
    };
    ArgonneService.prototype.getAdDetails = function (adId) {
        var url = this.BASE_URI + '/api/admin/Ad/' + adId;
        return this.$http.get(url)
            .then(function (response) {
            return response.data;
        });
    };
    ArgonneService.$inject = ["$http"];
    return ArgonneService;
}());
exports.ArgonneService = ArgonneService;
//# sourceMappingURL=argonneService.js.map