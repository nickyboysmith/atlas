(function () {

    'use strict';

    angular
        .module("app")
        .controller("RecordPaymentCtrl", RecordPaymentCtrl);

    RecordPaymentCtrl.$inject = ["$scope", "$timeout", "activeUserProfile", "ModalService", "PaymentManagementService", "RecordPaymentService"];

    function RecordPaymentCtrl($scope, $timeout, activeUserProfile, ModalService, PaymentManagementService, RecordPaymentService) {

        $scope.errorMessage = "";

        /**
         * Instantiate payment detail object
         */
        $scope.paymentDetail = {
            isAssignedTo: "empty",
            main: {},
            additional: {}
        };       

        /**
         * Check to see if the success object has been set
         * If it has 
         * Add the appropriate properties to the paymentDetail object
         */
        if ($scope.$parent.successfulPayment !== undefined) {

            var successfulPaymentObject = $scope.$parent.successfulPayment;

            /**
             * Check to see if the payment Id has been set
             */
            if (successfulPaymentObject.paymentId !== undefined) {
                $scope.paymentDetail.paymentId = successfulPaymentObject.paymentId;
            }

            /**
             * Check to see if the amount has been set
             */
            if (successfulPaymentObject.amount !== undefined) {
                $scope.paymentDetail.main.amount = successfulPaymentObject.amount;
            }

            /**
             * Check to see if the authcode has been set
             */
            if (successfulPaymentObject.authCode !== undefined) {
                $scope.paymentDetail.authCode = successfulPaymentObject.authCode;
            }

            $scope.paymentDetail.isAssignedTo = successfulPaymentObject.isAssignedTo;

            if (
                successfulPaymentObject.isAssignedTo === "client" ||
                successfulPaymentObject.isAssignedTo === "clientCourse")
            {
                $scope.paymentDetail.client = successfulPaymentObject.clientName;
                $scope.paymentDetail.from = successfulPaymentObject.clientName;
                $scope.paymentDetail.clientId = successfulPaymentObject.clientId;
            }

            if (successfulPaymentObject.isAssignedTo === "clientCourse") {
                $scope.paymentDetail.course = successfulPaymentObject.courseName;
                $scope.paymentDetail.courses = successfulPaymentObject.courses;
            }

        };



        /**
         * For the checkbox
         * Set open to false
         */
        $scope.openAdditionalContainer = false;

        /**
         * For the checkbox
         * Set close to true
         */
        $scope.closeAdditionalContainer = true;

        /**
         * Set the disabled button
         */
        $scope.disableButton = true;

        /**
         * Set the disabled message
         */
        $scope.disableMessage = "Please select ";


        /**
         * Initially hide the date picker div
         */
        $scope.showRecordPaymentDate = false;

        /**
         * Default the datepicker to todays date
         */
        $scope.paymentDetail.date = new Date().toDateString()

        /**
         * Get payment types from DB
         */
        $scope.getPaymentTypes = function () {
            PaymentManagementService.getPaymentTypes(activeUserProfile.selectedOrganisation.Id)
            .then(
                function (data) {
                    $scope.paymentTypes = data;
                },
                function (data) {
                    /**
                     * @todo handle errors globally
                     */
                }
            );
        };

        /**
         * Get payment methods from the DB
         */
        $scope.getPaymentMethods = function () {
            PaymentManagementService.getPaymentMethods(activeUserProfile.selectedOrganisation.Id)
            .then(
                function (data) {
                    $scope.paymentMethods =data;
                },
                function (data) {
                    /**
                     * @todo handle errors globally
                     */
                }
            );
        };

        /**
         * Call the method S
         * Which will populate the drop down
         */
        $scope.getPaymentTypes();
        $scope.getPaymentMethods();

        /**
         * Opens and close the opposite checkbox 
         * based on which one was clicked
         */
        $scope.updateShowAdditionalPayment = function (status)
        {

            if (status === true) {
                $scope.closeAdditionalContainer = false;
                $scope.openAdditionalContainer = true;
                $("#additionalPaymentContainer").show(); // Show the div
            }

            if (status === false) {
                $scope.openAdditionalContainer = false;
                $scope.closeAdditionalContainer = true;
                $("#additionalPaymentContainer").hide(); // hide the div
            }
        };

        /**
         * Assign a client
         * To the current payment about to be recorded
         */
        $scope.assignClient = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Assign Client",
                cssClass: "recordPaymentAssignClientModal",
                filePath: "/app/components/client/findSingle.html",
                controllerName: "FindSingleClientCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        /**
         * Record the payment
         */
        $scope.recordPayment = function () {

            var paymentDetailRequest = angular.extend($scope.paymentDetail, {
                userId: activeUserProfile.UserId
            });

            
            /**
             * Send updated object 
             * To the web api
             */
            RecordPaymentService.save(paymentDetailRequest)
            .then(
                function (data) {
                    console.log(data);

                    /**
                     * 
                     * Display message
                     * Then close
                     */
                    /**
                     * Empty object
                     */
                    $scope.paymentDetail = {
                        isAssignedTo: "empty",
                        main: {},
                        additional: {}
                    };

                    // refresh client details if exists...
                    if ($scope.loadClientDetails && $scope.clientId) {
                        $scope.loadClientDetails($scope.clientId);
                    }

                    /**
                     * Set the completed message
                     * Show the completed message
                     */
                    $scope.completedMessage = response.data;
                    $scope.showCompletedMessage = true;

                    /**
                     * Close the modal
                     * After 3.5 seconds
                     */
                    //$timeout(ModalService.closeCurrentModal("recordPaymentModal"), 6500);

                },
                function (data) {
                    console.log(data);
                    if (data) {
                        $scope.errorMessage = data;
                    }
                }
            );

        };

        /**
         * Update the payment 
         * With the client object
         * 
         * Check to see where we should assign the client to [client/course]
         */
        $scope.updateAssignedClient = function (assignedClient) {

            /**
             * Check where we should assign user to
             */
            if (assignedClient.courses.length === 0) {
                $scope.paymentDetail.isAssignedTo = "client";
            } else {
                $scope.paymentDetail.isAssignedTo = "clientCourse";
            }

            /**
             * add the names to the paymentDetail object
             */
            $scope.paymentDetail.client = assignedClient.clientName;
            $scope.paymentDetail.from = assignedClient.clientName;
            $scope.paymentDetail.course = assignedClient.courseName;

            /**
             * Add new properties to the paymentDetail object
             */
            $scope.paymentDetail["clientId"] = assignedClient.clientId;
            $scope.paymentDetail["courses"] = assignedClient.courses;

        };

        /**
         * Show / hide trhe datepicker 
         * Based on what the current input is
         */
        $scope.showDatePicker = function () {
            if ($scope.showRecordPaymentDate) {
                $scope.showRecordPaymentDate = false;
                return false;
            }
            $scope.showRecordPaymentDate = true;
        };

        /**
         * Close the date picker 
         * Properly so we can reopen on click
         */
        $scope.closeDatePicker = function () {
            $scope.showRecordPaymentDate = false;
        };

        /**
         * update the total amount
         * from the [main] + [additional]
         */
        $scope.updateTotalAmount = function (mainAmount, additionalAmount) {

            var main = parseFloat(mainAmount);
            var additional = parseFloat(additionalAmount);

            if (isNaN(main)) {
                main = 0;
            };

            if (isNaN(additional)) {
                additional = 0;
            };

            $scope.totalAmount = (main + additional).toFixed(2);

        };



    };


})();