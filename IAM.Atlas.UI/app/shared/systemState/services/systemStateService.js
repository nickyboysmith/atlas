(function () {


    'use strict';

    angular
        .module("app")
        .service("SystemStateService", SystemStateService);


    SystemStateService.$inject = ["$http"];

    function SystemStateService($http) {

        var systemStateService = this;

        systemStateService.getStatuses = function (organisationId) {
            return $http.get(apiServer + "/systemstate/getstatuses/" + organisationId);
                //.then(
                //    function successCallback(response) {
                //        // this callback will be called asynchronously
                //        // when the response is available
                //    },
                //    function errorCallback(response) {
                //        // called asynchronously if an error occurs
                //        // or server returns response with an error status.
                //    }
                //);

        };
    }

})();




