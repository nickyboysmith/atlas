(function () {

    'use strict';

    angular
        .module("app")
        .service("SignOutService", SignOutService);

    SignOutService.$inject = ["$http"];


    function SignOutService($http) {

        var signout = this;

        /**
         * Signout
         */
        signout.SignOut = function (Id) {
            return $http.get(apiServer + "/Signout/Signout/" + Id)
                 .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

    }


})();