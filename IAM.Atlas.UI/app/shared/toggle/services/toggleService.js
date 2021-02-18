(function () {

    'use strict';

    angular
        .module("app")
        .service("ToggleService", ToggleService);

    ToggleService.$inject = ["$http"];

    function ToggleService($http) {

        this.getUserPreference = function (userID)
        {
            return $http.get(apiServer + "/userpreference/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        this.saveUserPreference = function (userID, alignment)
        {
            var userPreferenceObject = {
                userId: userID,
                preference: alignment
            };
            return $http.post(apiServer + "/userpreference/", userPreferenceObject)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

    }

})();