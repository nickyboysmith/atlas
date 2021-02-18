(function () {

    'use strict';

    angular
        .module('app')
        .service('ArchiveControlService', ArchiveControlService);


    ArchiveControlService.$inject = ["$http"];

    function ArchiveControlService($http) {

        var archiveControlService = this;

        /**
         * Get the archiveControl
         */
        archiveControlService.Get = function () {
            return $http.get(apiServer + "/archiveControl/Get")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Get the organisationArchiveControl
        */
        archiveControlService.GetArchiveSettingsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/archiveControl/GetArchiveSettingsByOrganisation/" + organisationId)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Saves the archiveControl
        */
        archiveControlService.Save = function (archiveControlSettings) {
            return $http.post(apiServer + "/archiveControl/Save", archiveControlSettings)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Saves the organisationArchiveControl
        */
        archiveControlService.SaveArchiveSettingsByOrganisation = function (archiveControlSettings) {
            return $http.post(apiServer + "/archiveControl/SaveArchiveSettingsByOrganisation", archiveControlSettings)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

    }



})();