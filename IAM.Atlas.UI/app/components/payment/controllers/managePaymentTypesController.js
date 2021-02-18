(function () {

    'use strict';


    angular
        .module("app")
        .controller("ManagePaymentCtrl", ManagePaymentCtrl);

    ManagePaymentCtrl.$inject = ["$scope", "PaymentManagementFactory", "PaymentManagementService", "activeUserProfile", "UserService"];

    function ManagePaymentCtrl($scope, PaymentManagementFactory, PaymentManagementService, activeUserProfile, UserService)
    {
        $scope.paymentManagementService = PaymentManagementService;
        $scope.paymentManagementFactory = PaymentManagementFactory;
        $scope.userService = UserService;

        $scope.userId = activeUserProfile.UserId;

        $scope.paymentTypes = {};
        $scope.paymentTypeDetails = {};

        /**
         * Set the organisation dropdown to the default
         */
        $scope.selectedOrganisation = "*";

        $scope.userService.checkSystemAdminUser($scope.userId)
            .then(
                function (data) {
                    $scope.isAdmin = data;
                },
                function (data) {
                    $scope.isAdmin = false;
                }
            );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {

                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getPaymentTypes = function (organisationId) {

          
            $scope.selectedOrganisation = organisationId;

            $scope.successMessage = "";
            $scope.validationMessage = "";
            
            $scope.paymentManagementService.getPaymentTypes($scope.selectedOrganisation)
                .then(function (data) {

                    $scope.paymentTypes = data;

                    if ($scope.paymentTypes.length > 0) {

                        $scope.selectedPaymentType = $scope.paymentTypes[0];
                        $scope.paymentTypeDetails = angular.copy($scope.selectedPaymentType);
                        $scope.selectedPaymentTypeId = $scope.selectedPaymentType.Id;
                    }

                }, function (data) {

                });
           
        };

        $scope.selectPaymentType = function (selectedPaymentType) {

            $scope.successMessage = "";
            $scope.validationMessage = "";
            $scope.selectedPaymentType = selectedPaymentType;
            $scope.paymentTypeDetails = angular.copy(selectedPaymentType);
            $scope.selectedPaymentTypeId = selectedPaymentType.Id;
        }

        // Reset Payment Type Details
        $scope.addPaymentType = function () {
            $scope.paymentTypeDetails = {};
            $scope.successMessage = "";
            $scope.validationMessage = "";
        }

         // Save the Payment Type
        $scope.savePaymentType = function () {
            
            if ($scope.validateForm()) {

                if (!angular.equals({}, $scope.paymentTypeDetails)) {

                    $scope.paymentTypeDetails.OrganisationId = $scope.selectedOrganisation;

                    $scope.paymentManagementService.savePaymentType($scope.paymentTypeDetails)
                    .then(function (data) {

                        $scope.getPaymentTypes($scope.selectedOrganisation);
                        
                        $scope.successMessage = "Payment Type Saved Successfully";
                        $scope.validationMessage = "";

                    }, function (data) {

                        $scope.successMessage = "";
                        $scope.validationMessage = "An Error Ocurred Saving the Payment Type";

                    });

                }
            }
        };
        
      
        $scope.closeModal = function () {
            console.log("Close the modal");
        };

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (angular.isUndefined($scope.paymentTypeDetails.Name)) {
                $scope.validationMessage = "Please Enter a Payment Type Name. \r ";
            }
            else if ($scope.paymentTypeDetails.Name.length == 0) {
                $scope.validationMessage = "Please Enter a Payment Type Name. \r ";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getPaymentTypes($scope.organisationId);
    }

})();