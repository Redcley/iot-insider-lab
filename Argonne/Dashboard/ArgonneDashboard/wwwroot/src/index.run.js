"use strict";
function appRun($rootScope, $state /*ng.ui.IStateService*/, $stateParams, $transitions, $timeout, argonneService) {
    //$transitions.onStart({}, function (trans) {
    //    debugger;
    //});
    //$transitions.onSuccess({}, function (trans) {
    //    debugger;
    //});
    //$transitions.onBefore({}, function (trans) {
    //    debugger;
    //});
    //$transitions.onStart({}, function (trans) {
    //    debugger;
    //    //var SpinnerService = trans.injector.get('SpinnerService');
    //    //SpinnerService.transitionStart();
    //    //trans.promise.finally(SpinnerService.transitionEnd);
    //});
    //$rootScope.$on('$stateChangeStart', function (event: any, toState: IMGState, toParams: any, fromState: IMGState, fromParams: any) {
    //    debugger;
    //    $rootScope.loaded = false;
    //});
    //$rootScope.$on('$stateChangeSuccess', function (event: any, toState: IMGState, toParams: any, fromState: IMGState, fromParams: any, transition: any) {
    //    debugger;
    //    toState.loaded = true;
    //    toParams.loadedParam = true;
    //    $rootScope.state = toState;
    //    $rootScope.loaded = true;
    //});
    $transitions.onStart({}, function (trans) {
        //$state.current.loaded = false;
        //$rootScope.loaded = false;
        //debugger;  
        //debugger;
        //$timeout(() => {
        //    $rootScope.$broadcast('preloader', { loaded: false });
        //}, 100);        
    });
    $transitions.onSuccess({}, function (trans) {
        //debugger;
        //$timeout(() => {
        //    $rootScope.$broadcast('preloader', { loaded: true });
        //}, 100);        
    });
}
exports.appRun = appRun;
;
//# sourceMappingURL=index.run.js.map