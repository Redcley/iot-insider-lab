"use strict";
var angular = require('angular');
var dashboard_ts_1 = require('./dashboard.ts');
//import {techs} from './techs.ts';
exports.dashboardModule = 'dashboard';
angular
    .module(exports.dashboardModule, [])
    .component('dashboard', dashboard_ts_1.dashboard);
//# sourceMappingURL=index.js.map