(function () {

    'use strict';

    angular
        .module("app")
        .service("DataViewService", DataViewService);

    DataViewService.$inject = ["$http"];

    function DataViewService($http) {

        var dataViewService = this;
        
        /**
         * Get the Data Views
         */
        dataViewService.getDataViews = function (userID) {
            return $http.get(apiServer + "/dataView/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the DataView details for the DataView
         */
        dataViewService.getDataView = function (dataViewID, userID) {
            return $http.get(apiServer + "/dataView/GetDataView/" + dataViewID + "/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };


        /**
         * Get the Columns for the DataView
         */
        dataViewService.getDataViewColumns = function (dataViewID, userID) {
            return $http.get(apiServer + "/dataView/getcolumnsfordataview/" + dataViewID + "/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * saves or updates the dataView details
         */
        dataViewService.saveDataViewDetails = function (dataView) {
            return $http.post(apiServer + "/dataView", dataView)
                    .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }    
    }
})();