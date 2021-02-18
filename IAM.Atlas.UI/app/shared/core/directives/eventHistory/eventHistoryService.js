(function () {

    'use strict';

    angular
        .module("app")
        .service("EventHistoryService", EventHistoryService);

    EventHistoryService.$inject = ["$http"];

    function EventHistoryService($http) {

        var eventHistory = this;

        eventHistory.getClientHistory = function (clientId, organisationId) {
            return $http.get(apiServer + "/notehistory/getClientHistory/" + clientId + "/" + organisationId)
                .then(function (response) {
                    return response.data;
                }, function (response) {
                    return response.data;
                });
        };

        eventHistory.getClientHistoryEventTypes = function (clientId, organisationId) {
            return $http.get(apiServer + "/notehistory/getClientHistoryEventTypes/" + clientId + "/" + organisationId)
                .then(function (response) {
                    return response.data;
                }, function (response) {
                    return response.data;
                });
        };


        eventHistory.getCourseHistory = function (courseId) {
            return $http.get(apiServer + "/notehistory/getCourseHistory/" + courseId)
                .then(function (response) {
                    return response.data;
                }, function (response) {
                    return response.data;
                });
        };

        eventHistory.getCourseHistoryEventTypes = function (courseId) {
            return $http.get(apiServer + "/notehistory/getCourseHistoryEventTypes/" + courseId)
                .then(function (response) {
                    return response.data;
                }, function (response) {
                    return response.data;
                });
        };
    }

})();