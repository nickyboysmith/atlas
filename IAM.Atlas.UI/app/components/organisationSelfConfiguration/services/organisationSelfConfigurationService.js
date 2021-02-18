(function () {

    'use strict';

    angular
        .module('app')
        .service('OrganisationSelfConfigurationService', OrganisationSelfConfigurationService);


    OrganisationSelfConfigurationService.$inject = ["$http"];

    function OrganisationSelfConfigurationService($http) {

        var organisationSelfConfiguration = this;

        /**
         * Get the organisationSelfConfiguration
         */
        organisationSelfConfiguration.GetByOrganisation = function (organisationId) {
            var authToken = sessionStorage.getItem("authToken");
            return $http.get(apiServer + "/organisationSelfConfiguration/GetByOrganisation/" + organisationId, {
                headers: {
                    "X-Auth-Token": authToken
                }
            }
        )};

        //Check to see if Organisation has SMS functionaltiy enabled

        organisationSelfConfiguration.checkSMSFunctionalityStatus = function (organisationId) {
            return $http.get(apiServer + "/organisationSystemConfiguration/CheckSMSFunctionalityStatus/" + organisationId) 
            }

        /**
         * Get the organisationSelfConfigurationForClientSite
         * Need a separate one for the client site as we do not have a Auth Token
         */
        organisationSelfConfiguration.GetByOrganisationForClientSite = function (organisationId) {
            var authToken = sessionStorage.getItem("authToken");
            return $http.get(apiServer + "/organisationSelfConfiguration/GetByOrganisationForClientSite/" + organisationId, {
            }
        )
        };

        /**
         * updates the organisationSelfConfiguration
         */
        organisationSelfConfiguration.saveSettings = function (organisationSelfConfigurationSettings) {
            return $http.post(apiServer + "/organisationSelfConfiguration/SaveSettings", organisationSelfConfigurationSettings)
        };




    }



})();