(function () {

    'use strict';

    angular
        .module("app")
        .service("DocumentInformationService", DocumentInformationService);

    DocumentInformationService.$inject = ["$http"];

    function DocumentInformationService($http) {

        var documentInformationService = this;

        documentInformationService.getCourseDocumentInformation = function (courseId) {
            return $http.get(apiServer + "/documentInformation/GetCourseDocumentInformation/" + courseId);
        };

        documentInformationService.getClientDocumentInformation = function (clientId) {
            return $http.get(apiServer + "/documentInformation/GetClientDocumentInformation/" + clientId);
        };
    }

})();