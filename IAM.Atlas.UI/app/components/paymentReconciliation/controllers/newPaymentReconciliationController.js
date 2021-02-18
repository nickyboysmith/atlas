(function () {
    'use strict';

    angular
        .module('app')
        .controller('NewPaymentReconciliationCtrl', NewPaymentReconciliationCtrl);

    NewPaymentReconciliationCtrl.$inject = ["$scope", "PaymentReconciliationService", "UserService", "activeUserProfile", "DateFactory", "ModalService", "ReconciliationConfigurationService"];

    function NewPaymentReconciliationCtrl($scope, PaymentReconciliationService, UserService, activeUserProfile, DateFactory, ModalService, ReconciliationConfigurationService) {

        $scope.configurations = [];
        $scope.configurationId = -1;
        $scope.fromDate = '';
        $scope.toDate = '';
        $scope.reconciliation = {};
        $scope.displayFromCalendar = false;
        $scope.displayToCalendar = false;
        $scope.validationMessage = '';
        $scope.configurationId = -1;
        $scope.theLabel = "Reconciliation Source";
        $scope.theMaxSize = 5000;


        $scope.getConfigurations = function (organisationId) {
            ReconciliationConfigurationService.getPaymentReconciliationData(organisationId)
            .then(function (response) {
                $scope.configurations = response;
            });
        };

        $scope.getConfigurationData = function (reconciliationId) {
            $scope.configurationId = reconciliationId;
            ReconciliationConfigurationService.getPaymentReconciliationData(reconciliationId)
            .then(function (response) {
                $scope.selectedConfiguration = response;
            });
        };

        $scope.toggleFromCalendar = function (fromDate) {
            $scope.displayFromCalendar = !$scope.displayFromCalendar;
            if (fromDate) {
                $scope.fromDate = fromDate;
            }
        }

        $scope.toggleToCalendar = function (toDate) {
            $scope.displayToCalendar = !$scope.displayToCalendar;
            if (toDate) {
                $scope.toDate = toDate;
            }
        }

        $scope.formatDate = function (date) {
            return DateFactory.formatDateddMONyyyy(date);
        }

        $scope.checkDateRange = function (fromDate, toDate) {
            $scope.validationMessage = "";
            var isValidDateRange = false;

            if (!fromDate || !toDate) {
                $scope.validationMessage = "Please populate both From and To Dates";
                return isValidDateRange;
            }

            if ((toDate < fromDate)) {
                $scope.validationMessage = "'To' Date must be equal or greater than 'From' date";
                return isValidDateRange;
            }
            else {
                isValidDateRange = true;
            }
            return isValidDateRange;
        }

        $scope.saveFile = function (document) {
            var fileName = document.FileName;
            var ext = fileName.split('.').pop();
            if (ext === 'csv') {
                $scope.validationMessage = "";
                var dateCheck = false;
                dateCheck = $scope.checkDateRange($scope.fromDate, $scope.toDate);
                if (dateCheck === true && $scope.configurationId > 0) {
                    PaymentReconciliationService.SaveNewReconciliation($scope.convertFormData(document))
                        .then(
                                function (data) {
                                    if (data < 1) {
                                        $scope.validationMessage = "Document upload failed.";
                                    }
                                    else if (data > 1) {
                                        $scope.validationMessage = "Uploaded successfully.";
                                        $scope.$parent.getPaymentReconciliationList(activeUserProfile.selectedOrganisation.Id);
                                    }
                                    else {
                                        $scope.errorMessage = 'An error occurred: ' +data.ExceptionMessage;
                                }
                });
                } else {
                    $scope.validationMessage = "Please check that you have entered a correct date range and have selected a configuration.";
            }
            } else {
                $scope.validationMessage = "Only CSV files are supported for reconciliations.";
            }
        }

        //$scope.saveFile = function (document) {
        //    PaymentReconciliationService.saveNewReconciliation($scope.convertFormData())
        //                    .then(
        //                        function (data) {
        //                            if (data < 1) {
        //                                $scope.errorMessage = 'Letter template upload failed.';
        //                            }
        //                            else if (data > 0) {
        //                                $scope.successMessage = "Letter template uploaded successfully.";
        //                                $scope.loadLetters($scope.selectedOrganisationId);
        //                            }
        //                            else {
        //                                $scope.errorMessage = 'An error occurred: ' + data.ExceptionMessage;
        //                            }
        //                    );
        //}

        $scope.convertFormData = function (document) {
            var formData = new FormData();
            formData.append("reference", $scope.reconciliation.reference);
            formData.append("fromDate", $scope.fromDate);
            formData.append("toDate", $scope.toDate);
            formData.append("fileName", document.Name);
            formData.append("file", document.File);
            formData.append("originalFileName", document.FileName);
            formData.append("description", document.Description);
            formData.append("title", document.Title);
            formData.append("createdByUserId", activeUserProfile.UserId);
            formData.append("organisationId", activeUserProfile.selectedOrganisation.Id);
            formData.append("configurationId", $scope.configurationId);
            formData.append("name", $scope.reconciliation.name);
            return formData;
        };

        $scope.getConfigurations(activeUserProfile.selectedOrganisation.Id);
    }
})();