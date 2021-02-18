(function () {

    'use strict';

    angular
        .module("app")
        .service("UserService", UserService);


    UserService.$inject = ["$http"];

    function UserService($http) {

        var userService = this;

        /**
         * Call the web api return a boolean 
         * If user is in the 
         * System administrator user table
         */
        userService.checkSystemAdminUser = function (userId) {
            return $http.get(apiServer + "/systemadmin/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Call the web api return a boolean 
         * If user is an Organisation administrator and not blocked
         */
        userService.checkOrganisationAdminUser = function (userId, organisationId) {
            return $http.get(apiServer + "/organisationadminuser/" + userId + "/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /*
         *  Returns an array of organisations for the user
         *  If user isn't a system admin user then they will have only one organisation
         */
        userService.getOrganisationIds = function (userId) {
            return $http.get(apiServer + "/organisation/getbyuser/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.getBlockedUsers = function (organisationId, userId) {
            return $http.get(apiServer + "/user/GetBlockedUsersByOrganisation/"+ organisationId +"/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        userService.unblockAllUsersInOrganisation = function (organisationId, userId) {
            return $http.get(apiServer + "/user/UnblockAllUsersInOrganisation/" + organisationId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        userService.unblockUser = function (userId)
        {
            return $http.get(apiServer + "/user/unblockUser/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }
        
        userService.getFilteredUsers = function (organisationId, userId, administrators, trainers, systemAdministrators, clients, systemUsers, disabled) {
            return $http.get(apiServer + "/user/GetFilteredUsersByOrganisation/" + organisationId + "/" + userId + "/" + administrators + "/" + trainers + "/" + systemAdministrators + "/" + clients + "/" + systemUsers + "/" + disabled)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
         * Get user quicksearch content
         */
        userService.getOrganisationUsersQuickSearch = function (orgId, searchText) {

            return $http.get(apiServer + "/User/GetUnassignedByOrganisationId/" + orgId + "/" + searchText)
                .then(function (response) {
                    return response.data.map(function (item) {
                        return item;
                    });
                });
        };

        /**
         * Check if the user is assigned to a trainer
         */
        userService.isAssignedToClient = function (userId) {
            return $http.get(apiServer + "/user/IsAssignedToClient/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Bind to the User
         */
        userService.bindToClient = function (userId, clientId) {
            return "not implimented yet";
            //return $http.get(apiServer + "/user/bindtoclient/" + userId + "/" + clientId)
            //    .then(function (data) { })
            //    .error(function (data, status) { });
        };

        /*
         * Add a user pass in the User object
         */
        userService.add = function (userDetails) {
            return $http.post(apiServer + "/user", userDetails)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /*
          * Add/Update a User by passing in the User object.
          * Used by the editUser view.
          */
        userService.postEntity = function (user) {
            return $http.post(apiServer + "/user/postEntity", user)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.get = function (id) {
            return $http.get(apiServer + "/user/" + id)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.getCurrentUserRoles = function (userId, organisationId) {
            return $http.get(apiServer + "/user/GetCurrentUserRoles/" + userId + "/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.getCurrentUserExtendedRoles = function (userId) {
            return $http.get(apiServer + "/user/GetCurrentUserExtendedRoles/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.getSystemSupportUsers = function (organisationId) {
            return $http.get(apiServer + "/user/getSystemSupportUsers/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.getNonSystemSupportUsers = function (organisationId) {
            return $http.get(apiServer + "/user/getNonSystemSupportUsers/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.makeSupportUser = function (userId, organisationId, addedByUserId) {
            return $http.get(apiServer + "/user/makeSupportUser/" + userId + "/" + organisationId + "/" + addedByUserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        userService.unmakeSupportUser = function (userId, organisationId, adminUserId) {
            return $http.get(apiServer + "/user/unmakeSupportUser/" + userId + "/" + organisationId + "/" + adminUserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        userService.getSystemAdminSupportUsers = function () {
            return $http.get(apiServer + "/user/getSystemAdminSupportUsers")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.getNonSystemAdminSupportUsers = function () {
            return $http.get(apiServer + "/user/getNonSystemAdminSupportUsers")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        userService.makeAdminSupportUser = function (userId, addedByUserId) {
            return $http.get(apiServer + "/user/makeAdminSupportUser/" + userId + "/" + addedByUserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        userService.unmakeAdminSupportUser = function (userId, adminUserId) {
            return $http.get(apiServer + "/user/unmakeAdminSupportUser/" + userId + "/" + adminUserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

         userService.getActiveSystemUsers = function (organisationId, userId) {
             return $http.get(apiServer + "/user/GetActiveUsers/" + organisationId + "/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
         }

         userService.getNetcallAgentsByOrganisation = function (organisationId) {
             return $http.get(apiServer + "/user/GetNetcallAgentsByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
         }

         userService.getAvailableNetcallAgentsByOrganisation = function (organisationId) {
             return $http.get(apiServer + "/user/GetAvailableNetcallAgentsByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
         }
         
         userService.saveNetcallAgentCallingNumber = function (netcallAgent) {
             return $http.post(apiServer + "/user/SaveNetcallAgentCallingNumber", netcallAgent)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
         }

         userService.isMysteryShopperAdministrator = function (userId) {
             return $http.get(apiServer + "/user/IsMysteryShopperAdministrator/" + userId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
         }

         userService.GetOrganisationUsers = function (organisationId) {
             return $http.get(apiServer + "/User/GetOrganisationUsers/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
         }

        //userService.makeSelectedUserANetcallAgent = function (netcallAgent) {
         //    return $http.post(apiServer + "/user/SaveNetcallAgentCallingNumber", netcallAgent);
         //}
    }
})();