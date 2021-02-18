(function () {

    'use strict';

    angular
        .module('app')
        .service('SystemFeatureService', SystemFeatureService);


    SystemFeatureService.$inject = ["$http"];

    function SystemFeatureService($http) {

        var systemFeatureService = this;

        /**
         * Get the all the System Feature Groups
         */
        systemFeatureService.Get = function () {
            return $http.get(apiServer + "/systemFeature/GetFeatureGroups")
        };

        /**
         * Get the System Feature Information
         */
        systemFeatureService.getInformation = function (systemFeatureId, organisationId) {
            var endpoint = apiServer + "/systemFeature/Information/" + systemFeatureId + "/" + organisationId;
            return $http.get(endpoint)
        };

        /**
         * Get the SystemFeature Group Details By GroupId
         */
        systemFeatureService.GetFeatureGroupDetails = function (FeatureGroupId) {
            return $http.get(apiServer + "/systemFeature/GetFeatureGroupDetailsByGroupId/" + FeatureGroupId)
        };

        /**
         * Get the SystemFeature Group Items By GroupId
         */
        systemFeatureService.GetFeatureGroupItems = function (FeatureGroupId) {
            return $http.get(apiServer + "/systemFeature/GetFeatureGroupItemsByGroupId/" + FeatureGroupId)
        };

        /**
         * Get the systemFeature Group Item Details By GroupItemId
         */
        systemFeatureService.GetFeatureGroupItemDetails = function (FeatureGroupId) {
            return $http.get(apiServer + "/systemFeature/GetFeatureGroupItemDetailsByGroupItemId/" + FeatureGroupId)
        };

        /**
         * Get Existing systemFeature Group Item Details That Do NOT Exist for GroupItemId
         */
        systemFeatureService.GetAddExistingFeatureGroupItemDetails = function (FeatureGroupId) {
            return $http.get(apiServer + "/systemFeature/GetAddExistingFeatureGroupItemDetailsByGroupItemId/" + FeatureGroupId)
        };

        /**
        * creates or updates the systemFeature Group
        */
        systemFeatureService.SaveFeatureGroup = function (systemFeatureGroup) {
            return $http.post(apiServer + "/systemFeature/SaveFeatureGroup", systemFeatureGroup)
        };

        /**
        * creates or updates the systemFeature GroupItem
        */
        systemFeatureService.SaveFeatureGroupItem = function (systemFeatureGroupItem) {
            return $http.post(apiServer + "/systemFeature/SaveFeatureGroupItem", systemFeatureGroupItem)
        };

        /**
        * assigns existing systemFeatureGroupItems to the current systemFeatureGroup
        */
        systemFeatureService.SaveAddExistingFeatureGroupItems = function (systemFeatureGroupItems) {
            return $http.post(apiServer + "/systemFeature/SaveAddExistingFeatureGroupItems", systemFeatureGroupItems)
        };


        /**
        * Gets Feature Description and Notes based on Feature Name
        */
        systemFeatureService.GetFeatureDescriptionNotesByFeatureName = function (FeatureItemName, organisationId, userId) {
            return $http.get(apiServer + "/systemFeature/GetFeatureDescriptionNotesByFeatureName/" + FeatureItemName + "/" + organisationId + "/" + userId)
        };

        /**
        * Gets the NoteTypes
        */
        systemFeatureService.GetNoteTypes = function () {
            return $http.get(apiServer + "/systemFeature/GetNoteTypes")
        };

        /**
         * 
         */
        systemFeatureService.saveNote = function (noteObject) {
            var endPoint = apiServer + "/systemFeature/AddNote";
            return $http.post(endPoint, noteObject);
        };

        /**
        * Save the Note
        */
        systemFeatureService.SaveNote = function (note) {
            return $http.post(apiServer + "/systemFeature/SaveNote", note)
        };
    }

})();