import * as angular from 'angular';

//import {dashboard} from './dashboard.ts';
import {admin} from './admin.ts';

export const adminModule = 'admin';

angular
    .module(adminModule, [])    
    .component('admin', admin)
    ;
