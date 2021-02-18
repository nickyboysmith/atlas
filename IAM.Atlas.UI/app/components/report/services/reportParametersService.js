(function () {

    'use strict';

    angular
        .module('app')
        .service('reportParametersService', reportParametersService);

    reportParametersService.$inject = ["$http"];

    function reportParametersService($http) {

        var action = this;

        action.getReportParameters = function (reportId, organisationId) {
            var returnData =  $http.get(apiServer + "/report/getreportinputparameters/" + reportId + "/" + organisationId);
            return returnData;
        };

        action.runReportParameters = function (ReportParameters) {
            return $http.post(apiServer + "/report/runreportparameters", ReportParameters);
        };

        action.getReportRequest = function (reportId, organisationId, userId) {
            var returnData = $http.get(apiServer + "/report/getReportRequest/" + reportId + "/" + organisationId + "/" + userId); 
            return returnData;
        };

        action.postReportRequestParameterValue = function (reportRequestId, parameterId, parameterValue, parameterValueText) {
            var returnData = $http.post(apiServer + "/report/postReportRequestParameterValue/" + reportRequestId + "/" + parameterId + "/" + parameterValue + "/" + parameterValueText);
            return returnData;
        };

        action.getReportData = function (reportRequestId) {
            var returnData = $http.get(apiServer + "/report/getReportData/" + reportRequestId);
            return returnData;
        };

        action.getReportRequestData = function (reportRequestId) {
            var returnData = $http.get(apiServer + "/report/getReportRequestData/" + reportRequestId);
            return returnData;
        };

        action.getReportReferenceData = function (dataTypeName, organisationId) {
            var returnData = $http.get(apiServer + "/report/getReportReferenceData/" + dataTypeName + "/" + organisationId);
            return returnData;
        };

        action.getReportColumns = function (reportId) {
            return $http.get(apiServer + "/report/getReportColumns/" + reportId);
        };

        action.getReportsDefaults = function () {
            return $http.get(apiServer + "/report/getReportsDefaults");
        };

        action.getReportDetail = function (reportId) {
            return $http.get(apiServer + "/report/getReportDetail/" + reportId);
        };

    }
})();