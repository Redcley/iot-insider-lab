class AdminController {    
    static $inject = [];

    constructor() {        
    }
}

export const admin: angular.IComponentOptions = {
    templateUrl: 'wwwroot/app/admin/admin.html',
    controller: AdminController,
    controllerAs: 'vm'
};
