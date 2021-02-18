(function () {

    'use strict';

    angular
        .module("app")
        .controller("DocumentDownloadCtrl", DocumentDownloadCtrl);

    DocumentDownloadCtrl.$inject = ["$scope", "activeUserProfile", "ModalService", "DocumentDownloadService", "UserService"];

    function DocumentDownloadCtrl($scope, activeUserProfile, ModalService, DocumentDownloadService, UserService) {

        $scope.downloadDocument = {};        

        if($scope.$parent.downloadDocumentObject) {
            $scope.downloadDocument = $scope.$parent.downloadDocumentObject;
            $scope.downloadDocument.documentSaveName = $scope.$parent.downloadDocumentObject.documentSaveName;
        }

        $scope.downloadSelectedDocument = function () {
            //Create the download request object
            return DocumentDownloadService.downloadDocument(
                $scope.downloadDocument.Id,
                activeUserProfile.UserId,
                $scope.downloadDocument.owningEntityId,
                activeUserProfile.selectedOrganisation.Id,
                $scope.downloadDocument.owningEntityPath,
                $scope.downloadDocument.documentSaveName,
                $scope.downloadDocument.typeName);
        }

        $scope.closeModal = function () {
            ModalService.closeCurrentModal("downloadDocumentModal");
        }
        
    }

})();