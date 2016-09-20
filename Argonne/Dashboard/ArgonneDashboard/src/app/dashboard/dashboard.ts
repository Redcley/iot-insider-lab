class DashboardController {
    public testString: string = "Rashid is testing from controller";

    constructor(private $http: angular.IHttpService, private $window: angular.IWindowService) {
        debugger;        
    }
}

export const dashboard: angular.IComponentOptions = {
    templateUrl: 'src/app/dashboard/dashboard.html',
    controller: ['$http', DashboardController]
};
