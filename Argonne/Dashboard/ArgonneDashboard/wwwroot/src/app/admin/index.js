"use strict";
var angular = require('angular');
//import {dashboard} from './dashboard.ts';
var admin_ts_1 = require('./admin.ts');
exports.adminModule = 'admin';
angular
    .module(exports.adminModule, [])
    .component('admin', admin_ts_1.admin);
//# sourceMappingURL=index.js.map