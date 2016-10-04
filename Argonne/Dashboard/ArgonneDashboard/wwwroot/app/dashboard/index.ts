import * as angular from 'angular';

import {dashboard} from './dashboard.ts';

export const dashboardModule = 'dashboard';

angular
    .module(dashboardModule, [])
    .component('dashboard', dashboard)
    ;
