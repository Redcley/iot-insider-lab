class PreloaderController {
    constructor($scope: any, $timeout: angular.ITimeoutService, $rootScope: any, $state: angular.ui.IState) {        
        $scope.$on('preloader', (event, data) => {
            $(document.body).toggleClass('loaded', data.loaded);
        });        
    }
}

export const preloader: angular.IComponentOptions = {        
    controller: ['$scope', '$timeout', '$rootScope', '$state', PreloaderController]
};
