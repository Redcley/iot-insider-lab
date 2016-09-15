import * as angular from 'angular';

import {dashboard} from './dashboard.ts';
//import {techs} from './techs.ts';

export const dashboardModule = 'dashboard';

angular
    .module(dashboardModule, [])
    .component('dashboard', dashboard)
    //.component('fountainTechs', techs)
    ;
