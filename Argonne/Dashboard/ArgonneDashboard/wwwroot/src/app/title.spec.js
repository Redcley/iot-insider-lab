/// <reference path="../../typings/index.d.ts" />
"use strict";
var angular = require('angular');
require('angular-mocks');
var title_1 = require('./title');
describe('title component', function () {
    beforeEach(function () {
        angular
            .module('fountainTitle', ['app/title.html'])
            .component('fountainTitle', title_1.title);
        angular.mock.module('fountainTitle');
    });
    it('should render \'Allo, \'Allo!', angular.mock.inject(function ($rootScope, $compile) {
        var element = $compile('<fountain-title></fountain-title>')($rootScope);
        $rootScope.$digest();
        var title = element.find('h1');
        expect(title.html().trim()).toEqual('\'Allo, \'Allo!');
    }));
});
//# sourceMappingURL=title.spec.js.map