/// <reference path="../typings/index.d.ts" />

/**
    Angular application bootstrapping code.
    See: https://ui-router.github.io/
*/

import * as angular from 'angular';
import 'chartjs';
import 'angular-chart.js';
import 'angular-ui-router';
import 'ui-router-state-events';
import 'materialize-css';
//import 'font-awesome/css/font-awesome.min.css!';

import {preloaderModule} from './app/components/preloader/index.ts';
import {adminModule} from './app/admin/index.ts';
import {dashboardModule} from './app/dashboard/index.ts';
import routesConfig from './routes.ts';
//import {preloader} from './app/components/preloader/preloader.ts';
import {ArgonneService} from './app/services/argonneService.ts';
import {appRun} from './index.run.ts';

angular
    .module('app', [preloaderModule, adminModule, dashboardModule, 'ui.router', 'ui.router.state.events', 'chart.js'])
    .service('argonneService', ArgonneService)
    .run(appRun)
    .config(routesConfig)    
    ;
