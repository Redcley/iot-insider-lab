/// <reference path="../typings/index.d.ts" />
"use strict";
var angular = require('angular');
require('chartjs');
require('chartist');
require('d3');
require('angular-nvd3');
require('jquery-sparkline');
require('angular-ui-router');
//import '!style!css!bootstrap/dist/css/bootstrap.min.css';
//require('ui-router-state-events');
require('materialize-css');
//import {techsModule} from './app/techs/index.ts';
var index_ts_1 = require('./app/dashboard/index.ts');
var index_ts_2 = require('./app/admin/index.ts');
var routes_ts_1 = require('./routes.ts');
var main_ts_1 = require('./app/main.ts');
//import {header} from './app/header.ts';
//import {title} from './app/title.ts';
//import {footer} from './app/footer.ts';
//import {dashboard} from './app/dashboard/dashboard.ts';
var preloader_ts_1 = require('./app/components/preloader/preloader.ts');
var argonneService_ts_1 = require('./app/services/argonneService.ts');
//import {admin} from './app/admin/admin.ts';
var index_run_ts_1 = require('./index.run.ts');
angular
    .module('app', [index_ts_1.dashboardModule, index_ts_2.adminModule, 'ui.router', 'nvd3'])
    .component('preloader', preloader_ts_1.preloader)
    .service('argonneService', argonneService_ts_1.ArgonneService)
    .run(index_run_ts_1.appRun)
    .config(['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider', routes_ts_1["default"]])
    .component('app', main_ts_1.main);
//# sourceMappingURL=index.js.map