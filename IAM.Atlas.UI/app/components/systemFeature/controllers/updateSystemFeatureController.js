(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('SystemFeatureCtrl', SystemFeatureCtrl);

    SystemFeatureCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "ModalService", "PaymentProviderService", "SystemFeatureService"];

    function SystemFeatureCtrl($scope, $location, $window, $http, UserService, activeUserProfile, ModalService, PaymentProviderService, SystemFeatureService) {

        $scope.systemFeatureService = SystemFeatureService;
        $scope.modalService = ModalService;
        
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.featureGroup = {};
        $scope.featureGroupDetails = {};
        $scope.featureGroupItem = {};
        $scope.featureGroupItemDetails = {};

        $scope.selectedFeatureGroup = -1;
        $scope.selectedFeatureGroupItem = -1;
        

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        //Get SystemFeature Groups
        $scope.getFeatureGroups = function () {

            $scope.systemFeatureService.Get()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.featureGroup = response.data;

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        // Selected Feature Group
        $scope.selectFeatureGroup = function (selectedFeatureGroup) {

            $scope.selectedFeatureGroup = selectedFeatureGroup;
           

            // Reset Item Details
            $scope.featureGroupItemDetails = {};
            $scope.selectedFeatureGroupItem = -1;
            
            $scope.systemFeatureService.GetFeatureGroupDetails($scope.selectedFeatureGroup)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.featureGroupDetails = response.data[0];

                        $scope.getFeatureGroupItem($scope.selectedFeatureGroup);

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        // Selected Feature Group
        $scope.getFeatureGroupItem = function (selectedFeatureGroup) {

            $scope.systemFeatureService.GetFeatureGroupItems(selectedFeatureGroup)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.featureGroupItem = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        // Selected Feature Group
        $scope.selectFeatureGroupItem = function (selectedFeatureGroupItem) {

            $scope.selectedFeatureGroupItem = selectedFeatureGroupItem;
           
            $scope.systemFeatureService.GetFeatureGroupItemDetails($scope.selectedFeatureGroupItem)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.featureGroupItemDetails = response.data[0];
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        // Save System Feature Group
        $scope.saveFeatureGroup = function () {

            $scope.systemFeatureService.SaveFeatureGroup($scope.featureGroupDetails)
                        .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);
                                $scope.successMessage = "Save Successful";
                                $scope.validationMessage = "";
                            },
                            function (response) {
                                console.log("Error");
                                console.log(response);
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            }
                        );

        }

        // Save System Feature Group Item
        $scope.saveFeatureGroupItem = function () {

            $scope.systemFeatureService.SaveFeatureGroupItem($scope.featureGroupItemDetails)
                        .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);
                                $scope.successMessage = "Save Successful";
                                $scope.validationMessage = "";
                            },
                            function (response) {
                                console.log("Error");
                                console.log(response);
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            }
                        );

        }

        // Display Add System Feature Group Modal
        $scope.newGroup = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Feature Group",
                cssClass: "addSystemFeatureGroupModal",
                filePath: "/app/components/systemFeature/addSystemFeatureGroup.html",
                controllerName: "AddSystemFeatureGroupCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        // Display Add System Feature Item Modal
        $scope.newGroupItem = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Feature Item",
                cssClass: "addSystemFeatureGroupItemModal",
                filePath: "/app/components/systemFeature/addSystemFeatureGroupItem.html",
                controllerName: "AddSystemFeatureGroupItemCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });

        }

        // Display Add Existing System Feature Item Modal
        $scope.existingGroupItem = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Feature Item",
                cssClass: "addExistingSystemFeatureGroupItemModal",
                filePath: "/app/components/systemFeature/addExistingSystemFeatureGroupItem.html",
                controllerName: "AddExistingSystemFeatureGroupItemCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });

        }

        // Disable Save If No Group Selected
        $scope.IsGroupSelected = function () {

            if ($scope.selectedFeatureGroup > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        // Disable Save, New and Add Existing If No Group Item Selected
        $scope.IsGroupItemSelected = function () {

            if ($scope.selectedFeatureGroupItem > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        // Close
        $scope.close = function () {
            $('button.close').last().trigger('click');
        }


        $scope.getFeatureGroups();

    }

})();