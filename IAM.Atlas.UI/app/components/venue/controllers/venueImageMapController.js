(function () {
    'use strict';

    angular
        .module('app')
        .controller('VenueImageMapCtrl', VenueImageMapCtrl);

    VenueImageMapCtrl.$inject = ['$scope', 'ModalService', "activeUserProfile", 'OrganisationSystemConfigurationService', 'VenueImageMapService'];

    function VenueImageMapCtrl($scope, ModalService, activeUserProfile, OrganisationSystemConfigurationService, VenueImageMapService) {

        $scope.maximumFileSize = 0;
        $scope.venueImageMap = {
            OriginalFileName: '', 
            FileName: '',
            Title: '',
            Description: '',           
            OrganisationId: 0,
            VenueId: $scope.venueId,
            UserId: activeUserProfile.UserId
        };

        $scope.file = null;
        $scope.fileSize = 0;
        $scope.uploadedFile = null;
        $scope.src = '';

        $scope.showingExistingVenueImageMap = false;

        $scope.imageDataURL = function () {
            var fileReader = new FileReader();
            fileReader.onload = function (e) {
                $scope.src = e.target.result;
                $scope.$apply();
            }
            fileReader.readAsDataURL(VenueImageMapService.downloadVenueImageMapBlob($scope.venueId, activeUserProfile.UserId, $scope.venueImageMap.FileName));
        }

        $scope.getOrganisationSettings = function () {
            var organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.venueImageMap.OrganisationId = organisationId;
            OrganisationSystemConfigurationService.GetByOrganisation(organisationId)
                .then(
                    function successCallback(response) {
                        var osc = response.data;
                        $scope.maximumFileSize = osc.MaximumIndividualFileSize;
                        VenueImageMapService.getVenueImageMap($scope.venueId)
                        .then(
                            function successCallback(response) {
                                if (response.data) {
                                    $scope.venueImageMap = response.data;
                                    $scope.src = VenueImageMapService.VenueImageMapUrl($scope.venueId, activeUserProfile.UserId, $scope.venueImageMap.FileName);
                                    $scope.showingExistingVenueImageMap = true;
                                }
                            },
                            function errorCallback(response) {

                            }
                        );
                    },
                    function errorCallback(response) {
                        // called asynchronously if an error occurs
                        // or server returns response with an error status.
                    }
                );
        }

        $scope.fileSelected = function (event) {
            var files = event.target.files;
            if (event.target.files.length > 0) {
                $scope.showingExistingVenueImageMap = false;
                $scope.venueImageMap.OriginalFileName = event.target.files[0].name;
                $scope.fileSize = (event.target.files[0].size) / 1024;  // B to KB conversion
                $scope.uploadedFile = event.target.files[0];
                $scope.venueImageMap.FileName = event.target.files[0].name;
                $scope.venueImageMap.Title = $scope.removeExtension(event.target.files[0].name);

                var fileReader = new FileReader();
                fileReader.onload = function (e) {
                    $scope.src = e.target.result;
                    $scope.$apply();
                }
                fileReader.readAsDataURL(event.target.files[0]);

            }
        }

        

        $scope.removeExtension = function removeExtension(filename) {
            var lastDotPosition = filename.lastIndexOf(".");
            if (lastDotPosition === -1) return filename;
            else return filename.substr(0, lastDotPosition);
        }

        $scope.isValidFile = function () {
            var validFile = false;
            if ($scope.fileSize <= $scope.maximumFileSize && $scope.fileSize > 0) {
                validFile = true;
            }
            return validFile;
        }

        /**
        * Create form data to send to the web api
        * ?? Put  in a factory
        */
        $scope.convertFormData = function () {

            var formData = new FormData();
            formData.append("Title", $scope.venueImageMap.Title);
            formData.append("Description", $scope.venueImageMap.Description);
            formData.append("FileName", $scope.venueImageMap.FileName);
            formData.append("OriginalFileName", $scope.venueImageMap.OriginalFileName);
            formData.append("file", $scope.uploadedFile);
            formData.append("UserId", activeUserProfile.UserId);
            formData.append("OrganisationId", activeUserProfile.selectedOrganisation.Id);
            formData.append("VenueId", $scope.venueImageMap.VenueId);
            return formData;
        };

        $scope.Save = function () {
            if ($scope.showingExistingVenueImageMap == true) {
                VenueImageMapService.updateVenueImageMap($scope.venueImageMap)
                    .then(
                        function successCallback(response) {
                            if (response.data > 0) {
                                $scope.errorMessage = '';
                                $scope.statusMessage = 'Venue Image Map updated successfully.';
                                $scope.$parent.venueImageMapTitle = $scope.venueImageMap.Title;
                            }
                            else {
                                $scope.statusMessage = '';
                                $scope.errorMessage = 'Venue Image Map not updated please try again.';
                            }
                        },
                        function errorCallback(response) {
                            $scope.statusMessage = '';
                            $scope.errorMessage = 'An error occurred: ' +response.data.Message;
                        }
                    );
            }
            else {
                var formData = $scope.convertFormData();
                VenueImageMapService.uploadVenueImageMap(formData)
                    .then(
                        function successCallback(response) {
                            if (response.data > 0) {
                                $scope.errorMessage = '';
                                $scope.statusMessage = 'Venue Image Map saved successfully.';
                                $scope.$parent.venueImageMapTitle = $scope.venueImageMap.Title;
                            }
                            else {
                                $scope.statusMessage = '';
                                $scope.errorMessage = 'Venue Image Map not saved please try again.';
                            }
                        },
                        function errorCallback(response) {
                            $scope.statusMessage = '';
                            $scope.errorMessage = 'An error occurred: ' + response.data.Message;
                        }
                    );
            }
        }

        $scope.formatFileName = function () {
            var allowedCharacters = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-.";
            var fileName = $scope.venueImageMap.FileName;
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
            $scope.venueImageMap.FileName = cleanedFileName;
        }

        $scope.openDownloadModal = function()
        {
            ModalService.displayModal({
                scope: $scope,
                title: "Download Venue Map Image",
                filePath: "/app/components/venue/downloadVenueImageMap.html",
                controllerName: "DownloadVenueImageMapCtrl",
                cssClass: "downloadVenueImageMapModal",
            });
        }

        $scope.getOrganisationSettings();

    }
})();


