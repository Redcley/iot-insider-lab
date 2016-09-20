/// <reference path="../typings/index.d.ts" />

export default routesConfig;

/** @ngInject */
function routesConfig($stateProvider: angular.ui.IStateProvider, $urlRouterProvider: angular.ui.IUrlRouterProvider, $locationProvider: angular.ILocationProvider, $httpProvider: ng.IHttpProvider) {
    //$locationProvider.html5Mode(true).hashPrefix('!');
    $urlRouterProvider.otherwise('/');

    //$httpProvider.defaults.useXDomain = true;
    //delete $httpProvider.defaults.headers.common['X-Requested-With'];

    $httpProvider.defaults.cache = false;
    //if (!$httpProvider.defaults.headers.get) {
    //    $httpProvider.defaults.headers.get = {};
    //}    

    // disable IE ajax request caching
    //$httpProvider.defaults.headers.get['If-Modified-Since'] = '0';
    //initialize get if not there
    if ($httpProvider.defaults.headers.get) {
        // Answer edited to include suggestions from comments
        // because previous version of code introduced browser-related errors

        //disable IE ajax request caching
        $httpProvider.defaults.headers.get['If-Modified-Since'] = 'Mon, 26 Jul 1997 05:00:00 GMT';
        // extra
        $httpProvider.defaults.headers.get['Cache-Control'] = 'no-cache';
        $httpProvider.defaults.headers.get['Pragma'] = 'no-cache';
    }

    $stateProvider
        .state('app', {
            url: '/',
            component: 'app'
        })
        .state('admin', {
            url: '/admin',
            component: 'admin'
        })
        ;
}
