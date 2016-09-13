"use strict";
//import moment from 'moment';
require('jquery-sparkline');
var AdminController = (function () {
    function AdminController(argonneService, $interval, $log) {
        this.argonneService = argonneService;
        this.$interval = $interval;
        this.$log = $log;
        //public campaigns: Argonne.Services.ArgonneService.Models.CampaignDto[];
        //public loaded: boolean = false;
        this.CAMPAIGN_ID = '3149351f-3c9e-4d0a-bfa5-d8caacfd77f0';
        this.startMonitor();
        this.initializeCharts();
    }
    AdminController.prototype.initializeCharts = function () {
        //$("#clients-bar").sparkline([70, 80, 65, 78, 58, 80, 78, 80, 70, 50, 75, 65, 80, 70, 65, 90, 65, 80, 70, 65, 90], {
        //    type: 'bar',
        //    height: '25',
        //    barWidth: 7,
        //    barSpacing: 4,
        //    barColor: '#C7FCC9',
        //    negBarColor: '#81d4fa',
        //    zeroColor: '#81d4fa',
        //});
        //$("#invoice-line").sparkline([5, 6, 7, 9, 9, 5, 3, 2, 2, 4, 6, 7, 5, 6, 7, 9, 9, 5], {
        //    type: 'line',
        //    width: '100%',
        //    height: '25',
        //    lineWidth: 2,
        //    lineColor: '#E1D0FF',
        //    fillColor: 'rgba(233, 30, 99, 0.4)',
        //    highlightSpotColor: '#E1D0FF',
        //    highlightLineColor: '#E1D0FF',
        //    minSpotColor: '#f44336',
        //    maxSpotColor: '#4caf50',
        //    spotColor: '#E1D0FF',
        //    spotRadius: 4,
        //    // //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        //});
        //// Tristate chart (Today Profit)
        //$("#profit-tristate").sparkline([2, 3, 0, 4, -5, -6, 7, -2, 3, 0, 2, 3, -1, 0, 2, 3, 3, -1, 0, 2, 3], {
        //    type: 'tristate',
        //    width: '100%',
        //    height: '25',
        //    posBarColor: '#B9DBEC',
        //    negBarColor: '#C7EBFC',
        //    barWidth: 7,
        //    barSpacing: 4,
        //    zeroAxis: false,
        //    //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        //});
        //// Bar + line composite charts (Total Sales)
        //$('#sales-compositebar').sparkline([4, 6, 7, 7, 4, 3, 2, 3, 1, 4, 6, 5, 9, 4, 6, 7, 7, 4, 6, 5, 9, 4, 6, 7], {
        //    type: 'bar',
        //    barColor: '#F6CAFD',
        //    height: '25',
        //    width: '100%',
        //    barWidth: '7',
        //    barSpacing: 2,
        //    //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        //});
        //$('#sales-compositebar').sparkline([4, 1, 5, 7, 9, 9, 8, 8, 4, 2, 5, 6, 7], {
        //    composite: true,
        //    type: 'line',
        //    width: '100%',
        //    lineWidth: 2,
        //    lineColor: '#fff3e0',
        //    fillColor: 'rgba(153,114,181,0.3)',
        //    highlightSpotColor: '#fff3e0',
        //    highlightLineColor: '#fff3e0',
        //    minSpotColor: '#f44336',
        //    maxSpotColor: '#4caf50',
        //    spotColor: '#fff3e0',
        //    spotRadius: 4,
        //    //tooltipFormat: $.spformat('{{value}}', 'tooltip-class')
        //});
    };
    AdminController.prototype.startMonitor = function () {
        var _this = this;
        this.currentAfterDate = moment(); //.subtract('days', 1);
        this.$interval(function () {
            var afterTimestamp = _this.currentAfterDate.utc().format("YYYY-MM-DD HH:mm");
            _this.argonneService
                .getImpressionsForCampaign(_this.CAMPAIGN_ID, afterTimestamp)
                .then(function (impressions) {
                _this.impressions = impressions;
                _this.$log.log('Retreived ' + _this.impressions.length + ' impressions after ' + _this.currentAfterDate.format());
            });
            //this.currentAfterDate = this.currentAfterDate.subtract("month", 1);
            //$timeout(() => {
            //    debugger;
            //    this.loaded = true;
            //}, 3000);
        }, 5000);
    };
    AdminController.$inject = ['argonneService', '$interval', '$log'];
    return AdminController;
}());
exports.admin = {
    templateUrl: 'src/app/admin/admin.html',
    controller: AdminController,
    controllerAs: 'vm'
};
//# sourceMappingURL=admin.js.map