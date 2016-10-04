export class PreloaderService {
    constructor(private $rootScope: angular.IRootScopeService, $state: angular.ui.IState) {
        $rootScope.$on('preloader', (event, data) => {
            $(document.body).toggleClass('loaded', !data.loaded);
        });
    }

    public setStatus(isLoading: boolean) {
        this.$rootScope.$broadcast('preloader', { loaded: isLoading });
    }
}