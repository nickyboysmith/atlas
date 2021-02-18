(function () {

    'use strict';

    angular
        .module("app")
        .service("LetterService", LetterService);


    LetterService.$inject = ["$http"];

    function LetterService($http) {

        var letterService = this;

        letterService.getByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/letters/getByOrganisation/" + organisationId)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        letterService.getLetterTemplateCategoriesByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/letters/GetLetterTemplateCategoriesByOrganisation/" + organisationId)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        letterService.uploadTemplateDocument = function (document) {
            return $http.post(apiServer + "/letters/uploadTemplateDocument", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            )
            .then(function (response)
            { return response.data;},
            function (response, status)
            { return response.data; });
        }

        letterService.saveTemplate = function(id, title)
        {
            return $http.get(apiServer + "/letters/saveTemplate/" + id + "/" + title)
                .then(
                    function (response) {
                        return response.data;
                    }, function (response, status) {
                        return response.data;
                    });
        }

        letterService.downloadTemplate = function (UserId, letterTemplateDocumentId) {
            var fileURL = apiServer + "/letters/downloadTemplate/" + UserId + "/" + letterTemplateDocumentId;

            $http({
                method: 'GET',
                url: fileURL,
                responseType: 'blob'
            })
            .then(
                function (response) {
                    var headers = response.headers();

                    var filename = headers['x-filename'];
                    var contentType = headers['content-type'];
                    var fileType = headers['x-file-type'];
                    var linkElement = document.createElement('a');
                    try {
                        var blob = new Blob([response.data], { type: contentType });
                        var url = window.URL.createObjectURL(blob);

                        linkElement.setAttribute('href', url);
                        linkElement.setAttribute("download", filename);

                        var clickEvent;
                        if (window.navigator.msSaveOrOpenBlob) {
                            window.navigator.msSaveOrOpenBlob(blob, filename);
                        }
                        else {
                            clickEvent = new MouseEvent("click", {
                                "view": window,
                                "bubbles": true,
                                "cancelable": false
                            });
                            linkElement.dispatchEvent(clickEvent);
                        }
                    } catch (ex) {
                        console.log(ex);
                    }

                    return response.data;
                }
                ,function (response, status) { return response.data; }
            );
        }
    }

})();