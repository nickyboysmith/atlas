


(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('ViewSystemFeatureInformationCtrl', ViewSystemFeatureInformationCtrl);

    ViewSystemFeatureInformationCtrl.$inject = ["$scope", "$window", "activeUserProfile", "ModalService","SystemFeatureService"];

    function ViewSystemFeatureInformationCtrl($scope, $window, activeUserProfile, ModalService, SystemFeatureService) {

        var systemFeatureService = SystemFeatureService;
        var modalService = ModalService;

        $scope.descriptionNotes = {};
        $scope.userId = activeUserProfile.UserId;


        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        $scope.getDescriptionNotes = function () {

            systemFeatureService.GetFeatureDescriptionNotesByFeatureName($scope.SystemFeaturePageName, $scope.organisationId, $scope.userId)

            .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);

                        $scope.descriptionNotes = response.data;
                        
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);  
                    }
                );

        }

        $scope.addNote = function () {

                $scope.modalService.displayModal({
                    scope: $scope,
                    title: "Feature " + $scope.SystemFeaturePageName,
                    cssClass: "viewSystemFeatureInformationModal",
                    filePath: "/app/components/systemFeature/addSystemFeatureInformationNote.html",
                    controllerName: "AddSystemFeatureInformationNoteCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogueItself) {
                            dialogueItself.close();
                        }
                    }
                });
        }

        $scope.getDescriptionNotes();
    }

})();
