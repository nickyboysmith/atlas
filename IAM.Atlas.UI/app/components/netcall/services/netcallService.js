(function () {

    'use strict';

    angular
        .module("app")
        .service("NetcallService", NetcallService);


    NetcallService.$inject = ["$http"];

    function NetcallService($http) {

        var netcallService = this;

        netcallService.getAccountDetails = function (requestId, appContext, agentsPhoneExtension) {
            return $http.get(apiServer + "/NetcallTest/GetAccountDetails/" + requestId+"/" + appContext + "/" + agentsPhoneExtension);
        }

        netcallService.postAccountPaymentResult = function (requestId, appContext, clientId, paymentResult, authorisationReference) {
            var url = apiServer + "/NetcallTest/PostAccountPaymentResult/" + requestId + "/" + appContext +"/" + clientId + "/" + paymentResult + "/" + authorisationReference;
            return $http.get(url);
        }
    }

})();