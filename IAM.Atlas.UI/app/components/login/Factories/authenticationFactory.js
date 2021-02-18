(function () {

    'use strict';

    angular
        .module("app")
        .factory("AuthenticationFactory", AuthenticationFactory);

    AuthenticationFactory.$inject = [];

    function AuthenticationFactory() {

        this.getPageLocation = function (theLocation) {
            var getPath = theLocation.$$path;
            return getPath.replace("/login", "");
        };

        return {
            getLocation: this.getPageLocation
        };

    }


})();