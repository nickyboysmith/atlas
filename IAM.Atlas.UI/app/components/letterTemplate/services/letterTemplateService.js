(function () {
    'use strict';
    angular
        .module('app')
        .service('LetterTemplateService', LetterTemplateService);

    LetterTemplateService.$inject = ["$http"];

    function LetterTemplateService($http) {

        var letterTemplateService = this;

        letterTemplateService.getLetterTemplateCategoriesByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/Letters/GetLetterTemplateCategoriesByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        letterTemplateService.requestDocumentFromLetterDocumentTemplate = function (selectedTemplateDetails) {
            return $http.post(apiServer + "/Letters/requestDocumentFromLetterDocumentTemplate/", selectedTemplateDetails,
                                {
                                    headers: {
                                        'Content-Type': undefined
                                    },
                                    transformRequest: angular.identity
                                }
            )
                .then(function (response) {
                    return response.data;
                },
                function (response, status) {
                    return response.data;
                });
        };

        letterTemplateService.createDocumentTemplate = function (letterTemplateDocumentId) {
            return $http.get(schedulerServer + "/api/Document/CreateDocumentFromLetterTemplate/" + letterTemplateDocumentId)
                .then(function (response) {
                    return response.data;
                },
                function (response, status) {
                    return response.data;
                });
        };

        letterTemplateService.checkDocumentCreationStatus = function (letterTemplateDocumentId) {
            return $http.get(apiServer + "/letters/checkDocumentCreationStatus/" + letterTemplateDocumentId)
                .then(function (response) {
                    return response.data;
                },
                function (response, status) {
                    return response.data;
                });
        };


    };
}
)();