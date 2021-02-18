(function () {

    'use strict';

    angular
        .module('app')
        .service('StringService', StringService);

    //StringService.$inject = ["$compile"];

    function StringService() {

        var stringService = this;

        

        stringService.Capitalize = function (s) {
            return s.replace(/(?:^|\s)\S/g, function (a) { return a.toUpperCase(); });
        }

        stringService.toTitleCase = function (str) {
            return str.replace(/\w\S*/g, function (txt) { return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase(); });
        };
    }
})();