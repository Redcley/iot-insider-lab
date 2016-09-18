"use strict";
var PreloaderController = (function () {
    function PreloaderController($scope, $timeout, $rootScope, $state) {
        //debugger;
        $scope.$on('preloader', function (event, data) {
            $(document.body).toggleClass('loaded', data.loaded);
        });
    }
    return PreloaderController;
}());
exports.preloader = {
    //templateUrl: 'src/app/components/preloader/preloader.html',
    controller: ['$scope', '$timeout', '$rootScope', '$state', PreloaderController]
};
//# sourceMappingURL=preloader.js.map