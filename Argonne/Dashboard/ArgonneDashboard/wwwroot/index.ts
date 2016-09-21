/// <reference path="../typings/index.d.ts" />

import * as angular from 'angular';
import 'chartjs';
import 'chartist';
//import 'd3';
//import 'angular-nvd3';
import 'jquery-sparkline';
import 'angular-chart.js';

//import {techsModule} from './app/techs/index.ts';
import {dashboardModule} from './app/dashboard/index.ts';
import {adminModule} from './app/admin/index.ts';
import 'angular-ui-router';
import 'ui-router-state-events';
import routesConfig from './routes.ts';

import {main} from './app/main.ts';
//import {header} from './app/header.ts';
//import {title} from './app/title.ts';
//import {footer} from './app/footer.ts';
//import {dashboard} from './app/dashboard/dashboard.ts';
import {preloader} from './app/components/preloader/preloader.ts';
import {ArgonneService} from './app/services/argonneService.ts';
//import {admin} from './app/admin/admin.ts';
import {appRun} from './index.run.ts';

import 'materialize-css';

angular
    .module('app', [dashboardModule, adminModule, 'ui.router', 'ui.router.state.events','chart.js'])
    .component('preloader', preloader)
    //.service('preloader', Preloader)
    .service('argonneService', ArgonneService)
    .run(appRun)
    .config(['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider', routesConfig])
    .component('app', main)
    //.component('admin', admin)
    //.component('fountainTitle', title)    
    //.component('fountainFooter', footer)    
    ;