(function () {

    'use strict';

    angular
        .module("app")
        .service("RefundRequestService", RefundRequestService);


    RefundRequestService.$inject = ["$http"];

    function RefundRequestService($http) {

        var RefundRequestService = this;

        RefundRequestService.get = function (RefundRequestId) {
            return $http.get(apiServer + "/RefundRequest/" + RefundRequestId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        RefundRequestService.findRefundRequests = function (organistionId, RefundRequestType) {
            return $http.get(apiServer + "/RefundRequestSearch/find/" + organistionId + "/" + RefundRequestType)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

    }

})();