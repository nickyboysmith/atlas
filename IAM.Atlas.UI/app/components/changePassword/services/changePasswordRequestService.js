
(function () {
    'use strict';

    angular
        .module('app')
        .service('ChangePasswordRequestService', ChangePasswordRequestService);
    
    ChangePasswordRequestService.$inject = ["$http"];

    function ChangePasswordRequestService($http) {
          
        this.sendPasswordChangeToWebAPI = function (loginId) {
            /**
             * This is where the HTTP Backend call will go
             */
            
            $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

            return $http.post(apiServer + '/password/ResetRequest', loginId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        }
    }

})();