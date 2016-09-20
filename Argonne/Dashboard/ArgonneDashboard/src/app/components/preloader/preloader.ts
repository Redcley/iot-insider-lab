class PreloaderController {
    constructor($scope: any, $timeout: angular.ITimeoutService, $rootScope: any, $state: angular.ui.IState) {
        //debugger;
        $scope.$on('preloader', (event, data) => {
            $(document.body).toggleClass('loaded', data.loaded);
        });        
    }
}

export const preloader: angular.IComponentOptions = {    
    //templateUrl: 'src/app/components/preloader/preloader.html',
    controller: ['$scope', '$timeout', '$rootScope', '$state', PreloaderController]
};
