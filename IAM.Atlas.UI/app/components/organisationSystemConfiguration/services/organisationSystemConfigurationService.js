(function () {

    'use strict';

    angular
        .module('app')
        .service('OrganisationSystemConfigurationService', OrganisationSystemConfigurationService);


    OrganisationSystemConfigurationService.$inject = ["$http"];

    function OrganisationSystemConfigurationService($http) {

        var organisationSystemConfiguration = this;

        /**
         * Get the organisationSystemConfiguration
         */
        organisationSystemConfiguration.GetByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/organisationSystemConfiguration/GetByOrganisation/" + organisationId)
        };

        /**
        * updates the organisationSystemConfiguration
        */
        organisationSystemConfiguration.saveSettings = function (organisationSystemConfigurationSettings) {
            return $http.post(apiServer + "/organisationSystemConfiguration/SaveSettings", organisationSystemConfigurationSettings)
        };


        /**
         * Get the main organisations (an organisation that isn't managed by any other)
         */
        organisationSystemConfiguration.getMainOrganisations = function () {
            return $http.get(apiServer + "/organisationSystemConfiguration/getMainOrganisations")
        };

        /**
        * Get the Organisation System Configuration Settings for Client Registration Process
        * Cannot use getOrganisationSystemConfiguration as it has the AuthorizationRequired attribute 
        */
        organisationSystemConfiguration.getByOrganisationForClientRegistration = function (organisationId) {
            return $http.get(apiServer + "/organisationsystemconfiguration/GetByOrganisationForClientRegistration/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };


    }

})();