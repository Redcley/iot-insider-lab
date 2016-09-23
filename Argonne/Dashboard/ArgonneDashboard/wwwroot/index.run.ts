/**
    Angular run code.
*/
import { PreloaderService } from './app/components/preloader/preloaderService.ts';

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

export function appRun($rootScope: IMGScopeRootScope, $state: IMGState/*ng.ui.IStateService*/, $transitions: any, $timeout: ng.ITimeoutService, preloader: PreloaderService, $trace: any) {
    $trace.enable('TRANSITION');

    //$rootScope.$on('$viewContentLoaded', function (event, viewConfig) {
    //    preloader.setStatus(false);        
    //});    

    //$rootScope.$on('$viewContentLoading', function (event, viewConfig) {
    //    preloader.setStatus(true);        
    //});    

    $transitions.onStart({ /*to: 'auth.**'*/ }, function (trans) {
        preloader.setStatus(true);        
    });

    $transitions.onSuccess({ /*to: 'auth.**'*/ }, function (trans) {
        $timeout(() => {
            preloader.setStatus(false);
        }, 250);        
    });
};