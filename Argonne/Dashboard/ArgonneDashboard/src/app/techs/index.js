"use strict";
var angular = require('angular');
var tech_ts_1 = require('./tech.ts');
var techs_ts_1 = require('./techs.ts');
exports.techsModule = 'techs';
angular
    .module(exports.techsModule, [])
    .component('fountainTech', tech_ts_1.tech)
    .component('fountainTechs', techs_ts_1.techs);
//# sourceMappingURL=index.js.map