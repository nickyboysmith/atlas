(function () {

    'use strict';

    angular
        .module('app')
        .service('reportService', reportService);

    reportService.$inject = ["$http"];

    function reportService($http) {

        var action = this;

        action.getRelatedReportCategories = function (orgID) {
            return $http.get(apiServer + "/reportcategory/related/" + orgID);
        };

        action.getReportDataSources = function () {
            return $http.get(apiServer + "/report/getdatasources");
        };

        action.getReportDataColumns = function (viewID) {
            return $http.get(apiServer + "/report/getdatacolumns/" + viewID);
        };

        action.getReportDataColumnsWithSortOrder = function (reportId) {
            return $http.get(apiServer + "/report/getdatacolumnswithsortorder/" + reportId);
        };

        action.saveReportData = function (report) {
            return $http.post(apiServer + "/report/add", report);
        };

        action.get = function (reportId) {
            return $http.get(apiServer + "/report/" + reportId);
        }

        // get the users who can potentially become ReportOwners
        action.getReportAvailableUsers = function (reportId, organisationId) {
            return $http.get(apiServer + "/report/getAvailableUsers/" + reportId + "/" + organisationId);
        }

        action.removeReportOwner = function (reportId, userId) {
            return $http.get(apiServer + "/report/removeReportOwner/" + reportId + "/" + userId);
        }

        action.addReportOwner = function (reportId, userId) {
            return $http.get(apiServer + "/report/addReportOwner/" + reportId + "/" + userId);
        }
    }
})();