/// <reference path="../../typings/index.d.ts" />
"use strict";
var angular = require('angular');
require('angular-mocks');
var main_1 = require('./main');
describe('main component', function () {
    beforeEach(function () {
        angular
            .module('app', ['app/main.html'])
            .component('app', main_1.main);
        angular.mock.module('app');
    });
    it('should render the header, title, techs and footer', angular.mock.inject(function ($rootScope, $compile) {
        var element = $compile('<app></app>')($rootScope);
        $rootScope.$digest();
        expect(element.find('fountain-header').length).toEqual(1);
        expect(element.find('fountain-title').length).toEqual(1);
        expect(element.find('fountain-techs').length).toEqual(1);
        expect(element.find('fountain-footer').length).toEqual(1);
    }));
});
//# sourceMappingURL=main.spec.js.map