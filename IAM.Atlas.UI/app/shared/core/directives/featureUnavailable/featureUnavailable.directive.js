(function () {

    'use strict';


    angular
        .module("app.directives")
        .directive("featureUnavailable", featureUnavailable);


    function featureUnavailable() {

        return {
            restrict: 'EA', //E = element, A = attribute, C = class, M = comment         
            templateUrl: '/app/shared/core/directives/featureUnavailable/view.html'
        }

    }


})();