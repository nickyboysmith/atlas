(function () {

    'use strict';

    angular
        .module("app")
        .service("NavigationService", NavigationService);

    NavigationService.$inject = ["$http"];

    function NavigationService($http) {

        var navigation = this;

        /**
         * Get the report menu items
         */
        navigation.reportMenuItems = function (userId, organisationId) {
            var callPath = "/Navigation/Report/" + userId + "/" + organisationId;
            return $http.get(apiServer + callPath)
                        .then(
                            function (response) {
                                return response.data;
                            }
                            , function (response) {
                                var status = response.status;
                                var statusText = response.statusText;
                                var errMessage = "'" + callPath + "' ERROR: (" + status + ") " + statusText;
                                console.log(errMessage);
                                return false;
                            }
                        );
        };

        /**
         * Get the User Report Menu Items
         */
        navigation.userReportList = function (userId, organisationId) {
            var callPath = "/Navigation/UserReportList/" + userId + "/" + organisationId;
            return $http.get(apiServer + callPath)
                        .then(
                            function (response) {
                                return response.data;
                            }
                            , function (response) {
                                var status = response.status;
                                var statusText = response.statusText;
                                var errMessage = "'" + callPath + "' ERROR: (" + status + ") " + statusText;
                                console.log(errMessage);
                                return false;
                            }
                        );
        };

        /**
         * Get the main navigation Items
         */
        navigation.getMainNavigationItems = function (userId) {
            var callPath = "/Navigation/" + userId;
            return $http.get(apiServer + callPath)
                        .then(
                            function (response) {
                                return response.data;
                            }
                            , function (response) {
                                var status = response.status;
                                var statusText = response.statusText;
                                var errMessage = "'" + callPath + "' ERROR: (" + status + ") " + statusText;
                                console.log(errMessage);
                                return false;
                            }
                        );
        };

        navigation.getPaymentReconciliationStatus = function (organisationId) {
            return $http.get(apiServer + "/Navigation/showPaymentReconciliation/" + organisationId)
                .then(
                    function (response) {
                        return response.data
                    }, function (response) {

                    });
        };

    };

})();