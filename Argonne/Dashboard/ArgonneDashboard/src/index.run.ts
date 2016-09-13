import { ArgonneService } from './app/services/argonneService.ts';

interface IMGScope extends ng.IScope {
    $state: ng.ui.IState;
}

interface IMGState extends ng.ui.IState {
    loaded: boolean;
}

interface IMGScopeRootScope extends ng.IRootScopeService {
    state: ng.ui.IState;
    $stateParams: ng.ui.IStateParamsService;
    navstates: [any];
    loaded: boolean;
}

export function appRun($rootScope: IMGScopeRootScope, $state: IMGState/*ng.ui.IStateService*/, $stateParams: ng.ui.IStateParamsService, $transitions: any, $timeout: ng.ITimeoutService, argonneService: ArgonneService) {    
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

    $transitions.onStart({ /*to: 'auth.**'*/ }, function (trans) {
        //$state.current.loaded = false;
        //$rootScope.loaded = false;
        //debugger;  
        //debugger;
        //$timeout(() => {
        //    $rootScope.$broadcast('preloader', { loaded: false });
        //}, 100);        
    });

    $transitions.onSuccess({ /*to: 'auth.**'*/ }, function (trans) {
        //debugger;
        //$timeout(() => {
        //    $rootScope.$broadcast('preloader', { loaded: true });
        //}, 100);        
    });
};