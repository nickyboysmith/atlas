(function () {

    'use strict';

    angular
        .module("app")
        .service("AdministrationMenuService", AdministrationMenuService);

    AdministrationMenuService.$inject = ["$http"];

    function AdministrationMenuService($http) {

        var administrationMenuService = this;
        

        /**
        * Get the Admin Menu Groups
        */
        administrationMenuService.getAdminMenuGroups = function (userID) {
            return $http.get(apiServer + "/adminMenu/GetMenuGroups/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the Admin Menu Items
         */
        administrationMenuService.getAdminMenuItems = function (adminMenuGroupId) {
            return $http.get(apiServer + "/adminMenu/GetMenuGroupItems/" + adminMenuGroupId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

       
        /**
         * Get the Admin Menu Item Details
         */
        administrationMenuService.getAdminMenuItemDetails = function (adminMenuGroupItemId) {
            return $http.get(apiServer + "/adminMenu/GetMenuGroupItemDetails/" + adminMenuGroupItemId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * saves or updates the Admin Menu Items
         */
        administrationMenuService.saveAdminMenuItemDetails = function (adminMenuItemDetails) {
            return $http.post(apiServer + "/adminMenu/SaveMenuItemDetail", adminMenuItemDetails)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * saves  Admin Menu Group
         */
        administrationMenuService.saveAdminMenuGroup = function (adminMenuGroup) {
            return $http.post(apiServer + "/adminMenu/SaveMenuGroup", adminMenuGroup)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }
    }
})();