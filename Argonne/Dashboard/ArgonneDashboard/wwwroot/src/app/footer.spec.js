/// <reference path="../../typings/index.d.ts" />
"use strict";
var angular = require('angular');
require('angular-mocks');
var footer_1 = require('./footer');
describe('footer component', function () {
    beforeEach(function () {
        angular
            .module('fountainFooter', ['app/footer.html'])
            .component('fountainFooter', footer_1.footer);
        angular.mock.module('fountainFooter');
    });
    it('should render \'FountainJS team\'', angular.mock.inject(function ($rootScope, $compile) {
        var element = $compile('<fountain-footer></fountain-footer>')($rootScope);
        $rootScope.$digest();
        var footer = element.find('a');
        expect(footer.html().trim()).toEqual('FountainJS team');
    }));
});
//# sourceMappingURL=footer.spec.js.map