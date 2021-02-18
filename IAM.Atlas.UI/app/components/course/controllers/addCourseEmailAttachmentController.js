(function () {
    'use strict';

    angular
        .module('app')
        .controller('addCourseEmailAttachmentCtrl', addCourseEmailAttachmentCtrl);

    addCourseEmailAttachmentCtrl.$inject = ['$scope', '$location', '$window', '$http', 'activeUserProfile', 'CourseService', 'OrganisationSystemConfigurationService']

    function addCourseEmailAttachmentCtrl($scope, $location, $window, $http, activeUserProfile, CourseService, OrganisationSystemConfigurationService) {

        $scope.document = {};
        $scope.document.FileName = '';
        $scope.document.Description = '';
        $scope.uploadedFileSize = 0;
        $scope.maximumFileSize = 0;
        $scope.showFileNameCharacterMessage = false;
        $scope.document.UpdatedByUserId = activeUserProfile.UserId;
        $scope.document.CourseId = $scope.course.Id;


        $scope.getOrganisationSettings = function () {
            var organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.document.OrganisationId = organisationId;
            OrganisationSystemConfigurationService.GetByOrganisation(organisationId)
                .then(
                    function successCallback(response) {
                        var osc = response.data;
                        $scope.maximumFileSize = osc.MaximumIndividualFileSize;
                    },
                    function errorCallback(response) {
                        // called asynchronously if an error occurs
                        // or server returns response with an error status.
                    }
                );
        }

        $scope.closeModal = function () {
            $('button.close').last().trigger('click');
        }

        $scope.Save = function () {
            CourseService.addDocument($scope.document)
                .then(
                    function successCallback(response) {
                        var s = 1;
                        if (response.data > 0) {
                            // document added successfully.
                            // close modal and refresh document list (but not in that order!)
                            $scope.refreshDocuments()
                                .then(
                                    function successCallback(response) {
                                        $scope.closeModal();
                                    },
                                    function errorCallback(response) {
                                        // called asynchronously if an error occurs
                                        // or server returns response with an error status.
                                        $scope.errorMessage = "Error refreshing document list.";
                                    }
                                );
                        }
                    },
                    function errorCallback(response) {
                        // called asynchronously if an error occurs
                        // or server returns response with an error status.
                        $scope.errorMessage = response.data.ExceptionMessage;
                    }
                );
        }

        $scope.removeExtension = function removeExtension(filename) {
            var lastDotPosition = filename.lastIndexOf(".");
            if (lastDotPosition === -1) return filename;
            else return filename.substr(0, lastDotPosition);
        }

        $scope.uploadFile = function (files) {
            $scope.document.UploadedFile = files[0];
            $scope.uploadedFileSize = $scope.document.UploadedFile.size / 1000;
            $scope.document.OriginalFileName = files[0].name;
            $scope.document.FileName = files[0].name;

            $scope.formatFileName();
            $scope.document.Title = $scope.removeExtension(files[0].name);
        };

        $scope.formatFileName = function () {
            var allowedCharacters = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-.";
            var fileName = $scope.document.FileName;
            var cleanedFileName = "";
            $scope.showFileNameCharacterMessage = false;
            for (var i = 0; i < fileName.length; i++) {
                var c = fileName[i];
                if (allowedCharacters.indexOf(c) > -1) {
                    cleanedFileName += c;
                }
                else {
                    $scope.showFileNameCharacterMessage = true;
                }
            }
            $scope.document.FileName = cleanedFileName;
            $scope.errorMessage = '';
        }

        $scope.getOrganisationSettings();
    }



})();