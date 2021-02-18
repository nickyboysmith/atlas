(function () {

    'use strict';

    angular
        .module("app")
        .service("SystemFontService", SystemFontService);


    SystemFontService.$inject = ["$http"];

    function SystemFontService($http) {

        var systemFonts = this;

        systemFonts.getFonts = function () {
            return $http.get(apiServer + "/systemfont")
                .then(function (data) {
                }, function() {
                });
        };

    }

})();