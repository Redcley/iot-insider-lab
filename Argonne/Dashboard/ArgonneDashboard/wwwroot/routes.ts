/**
    Defines all of the routes within the application and the defaults for how routes are handled
    See: https://ui-router.github.io/
*/

export default routesConfig;

function routesConfig($stateProvider: angular.ui.IStateProvider, $urlRouterProvider: angular.ui.IUrlRouterProvider, $locationProvider: angular.ILocationProvider, $httpProvider: ng.IHttpProvider) {    
    //$locationProvider.html5Mode(true).hashPrefix('!');
    $urlRouterProvider.otherwise('/');    
    $stateProvider
        .state('app', {
            url: '/',
            component: 'dashboard'
        })
        .state('app.compaign', {            
            url: '/c/{campaignId}',
            component: 'dashboard'
        })
        .state('admin', {
            url: '/admin',
            component: 'admin'
        })
        ;
}
