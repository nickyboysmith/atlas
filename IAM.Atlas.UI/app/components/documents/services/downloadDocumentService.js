(function () {
    'use strict';
    angular
        .module('app')
        .service('DocumentDownloadService', DocumentDownloadService);

    DocumentDownloadService.$inject = ["$http"];

    function DocumentDownloadService($http) {

        var documentService = this;

        // OwningEntityPath: client, course, trainer, organisation (the WEBAPI controller where the downloadDocument is in)
        // OwningEntityId: clientId, courseId, trainerId, organisationId (the id of the entity which owns the document)
        documentService.downloadDocument = function (Id, UserId, OwningEntityId, UserSelectedOrganisationId, OwningEntityPath, DocumentSaveName, DocumentType) {

            //if (!DocumentType == false) {
            //    filename += "." + DocumentType;
            //}

            var fileURL = (apiServer + "/" + OwningEntityPath + "/downloadDocument/" + Id + "/" + UserId + "/" + OwningEntityId + "/" + UserSelectedOrganisationId + "/" + DocumentSaveName);
            var s = "";

            $http({
                method: 'GET',
                url: fileURL,
                responseType: 'blob'
            })
                .then(
                function (response) {
                    var headers = response.headers();

                    var filename = DocumentSaveName;
                    if (!DocumentType == false)
                    {
                        var extensionCheck = DocumentType.charAt(0);
                        if (extensionCheck == '.') {
                            filename += DocumentType;
                        }
                        else {
                            filename += "." + DocumentType;
                        }
                    }

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
                    }
                    catch (ex) {
                        console.log(ex);
                    }
                }
                ,
                function (data) {
                    console.log(data);
                }
                );
        }

        documentService.downloadLocalDocument = function (fileName, extension) {
            //path, fileName, DocumentType
            var fileURL = (apiServer + "/document/DownloadLocalFileContents/" + fileName + "/" + extension);

            $http({
                method: 'GET',
                url: fileURL,
                responseType: 'blob'
            })
            //$http.get(fileURL)
                .then(
                function (response) {
                    var headers = response.headers();
                    //if (!DocumentType == false) {
                    //    var extensionCheck = DocumentType.charAt(0);
                    //    if (extensionCheck == '.') {
                    //        filename += DocumentType;
                    //    }
                    //    else {
                    //        filename += "." + DocumentType;
                    //    }
                    //}

                    var contentType = headers['content-type'];
                    var fileType = headers['x-file-type'];
                    var linkElement = document.createElement('a');
                    try {
                        fileName += '.' + extension;
                        var blob = new Blob([response.data], { type: contentType });
                        var url = window.URL.createObjectURL(blob);

                        linkElement.setAttribute('href', url);
                        linkElement.setAttribute("download", fileName);

                        var clickEvent;
                        if (window.navigator.msSaveOrOpenBlob) {
                            window.navigator.msSaveOrOpenBlob(blob, fileName);
                        }
                        else {
                            clickEvent = new MouseEvent("click", {
                                "view": window,
                                "bubbles": true,
                                "cancelable": false
                            });
                            linkElement.dispatchEvent(clickEvent);
                        }
                    }
                    catch (ex) {
                        console.log(ex);
                    }
                }
                ,
                function (data) {
                    console.log(data);
                }
                );
        }
    };
}
)();