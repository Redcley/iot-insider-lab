"use strict";
var DashboardController = (function () {
    function DashboardController($http, $window) {
        this.$http = $http;
        this.$window = $window;
        this.testString = "Rashid is testing from controller";
        debugger;
    }
    return DashboardController;
}());
exports.dashboard = {
    templateUrl: 'src/app/dashboard/dashboard.html',
    controller: ['$http', DashboardController]
};
//# sourceMappingURL=dashboard.js.map