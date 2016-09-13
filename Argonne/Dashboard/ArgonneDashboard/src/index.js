/// <reference path="../typings/index.d.ts" />
"use strict";
var angular = require('angular');
//import {techsModule} from './app/techs/index.ts';
var index_ts_1 = require('./app/dashboard/index.ts');
var index_ts_2 = require('./app/admin/index.ts');
require('angular-ui-router');
require('ui-router-state-events');
var routes_ts_1 = require('./routes.ts');
var main_ts_1 = require('./app/main.ts');
var preloader_ts_1 = require('./app/components/preloader/preloader.ts');
var argonneService_ts_1 = require('./app/services/argonneService.ts');
//import {admin} from './app/admin/admin.ts';
var index_run_ts_1 = require('./index.run.ts');
require('materialize-css');
angular
    .module('app', [index_ts_1.dashboardModule, index_ts_2.adminModule, 'ui.router', 'ui.router.state.events'])
    .component('preloader', preloader_ts_1.preloader)
    .service('argonneService', argonneService_ts_1.ArgonneService)
    .run(index_run_ts_1.appRun)
    .config(['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider', routes_ts_1["default"]])
    .component('app', main_ts_1.main);
//# sourceMappingURL=index.js.map