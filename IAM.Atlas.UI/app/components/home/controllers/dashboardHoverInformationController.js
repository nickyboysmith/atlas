(function () {

    'use strict';

    angular
        .module("app")
        .controller("DashboardHoverInformationCtrl", DashboardHoverInformationCtrl);

    DashboardHoverInformationCtrl.$inject = ["$scope", "activeUserProfile", "DashboardService", "DateFactory", "DorsService", "ModalService", "CourseAttendanceService"];

    function DashboardHoverInformationCtrl($scope, activeUserProfile, DashboardService, DateFactory, DorsService, ModalService, CourseAttendanceService) {

        /**
         * Initialize the table headers array
         */
        $scope.tableHeaders = [];

        /**
         * Initialize an empty array
         * For the collection to copy the hoverInformation Array
         */
        $scope.hoverInformationCollection = [];

        /**
         * Initialize array for the hover information
         */
        $scope.hoverInformation = [];

        /**
         * Initialize the date information
         */
        $scope.showDate = false;

        /**
         * Initialize the show results
         */
        $scope.showResults = false;

        /**
         * Initialize the show loading
         */
        $scope.showLoading = true;

        /**
         * Initialize the show error
         */
        $scope.showError = false;

        



        /**
         * get the meter's data from the web api
         */
        $scope.getMeterData = function () {

            /**
             * Build object
             * To send to the web api
             * That says which meter and which parameter
             * We want the extra information for
             */
            var buildObject = {
                meterName: $scope.$parent.hoverMeterName,
                parameter: $scope.$parent.hoverParamName,
                organisationId: activeUserProfile.selectedOrganisation.Id,
                userId: activeUserProfile.UserId
            };

            /**
             * Set hoverParamName so this can be used to display the correct table in the html dashboardHoverInformationController.html
             * Two specific view and one generic
             * TODO: probably need to refactor as not the best implementation
             */
            if ($scope.$parent.hoverParamName == "NumberOfAttendanceUpdatesDue" ||
                    $scope.$parent.hoverParamName == "UnableToUpdateInDORS" ||
                    $scope.$parent.hoverParamName == "AttendanceNotUploadedToDORS" ||
                    $scope.$parent.hoverParamName == "ClientsWithMissingReferringAuthorityCreatedThisWeek" ||
                    $scope.$parent.hoverParamName == "ClientsWithMissingReferringAuthorityCreatedThisMonth" || 
                    $scope.$parent.hoverParamName == "ClientsWithMissingReferringAuthorityCreatedLastMonth" || 
                    $scope.$parent.hoverParamName == "NumberOfAttendanceVerificationsDue")
            {
                $scope.hoverParamName = $scope.$parent.hoverParamName;
            }
            else if ($scope.$parent.hoverParamName == "OffersWithdrawnToday" ||
                        $scope.$parent.hoverParamName == "OffersWithdrawnThisWeek" ||
                        $scope.$parent.hoverParamName == "OffersWithdrawnThisMonth" ||
                        $scope.$parent.hoverParamName == "OffersWithdrawnPreviousMonth")
            {
                $scope.hoverParamName = "DORSWithdrawnOffers";
            }
            else if ($scope.$parent.hoverParamName.indexOf("|") !== -1 && $scope.$parent.hoverMeterName === "Payments") {
                $scope.hoverParamName = "Payments";
            }
            else {
                $scope.hoverParamName = "AllOthers";
            }

            DashboardService.getHoverInformation(buildObject)
                .then(
                    function (response) {

                        if (response.data.length > 0) {
                            /**
                             * Get the first row of data 
                             * Then loop through to get the table headers
                             */
                            $scope.tableHeaders = $scope.getKeys(response.data[0]);

                            /**
                             * Assign returned list of data
                             * To the hover information array
                             */
                            $scope.hoverInformation = response.data;

                            /**
                             * Set the show date to true
                             * & fill the date
                             */
                            if (buildObject.parameter === "RegisteredToday" || buildObject.parameter === "RegisteredOnlineToday") {
                                $scope.showDate = true;

                                var theDate = new Date();

                                /**
                                 * If the yesterday exists
                                 * Set date for yesterday
                                 * 
                                 * Don't uncomment until yesterday's dates 
                                 * exist on the dashboard meter
                                 */
                                //theDate.setDate(theDate.getDate() - 1); 

                                $scope.displayDate = theDate.toLocaleDateString("en-GB", {
                                    weekday: 'long',
                                    year: 'numeric',
                                    month: 'long',
                                    day: 'numeric'
                                });
                            }

                            /**
                             * Show table
                             */
                            $scope.showLoading = false;
                            $scope.showResults = true;
                        } else {
                            $scope.showLoading = false;
                            $scope.showError = true;
                            $scope.errorMessage = "No results have been found.";
                        }

                    },
                    function (reason) {
                        $scope.showLoading = false;
                        $scope.showError = true;
                        $scope.errorMessage = "There has been an issue loading your results.";
                    }
                );
        }
        

        /**
         * Loop through the object
         * Get the headers for table
         */
        $scope.getKeys = function (loopObject) {
            var tableHeaders = [];
            angular.forEach(loopObject, function (value, key) {
                if (key !== "$$hashKey") {

                    tableHeaders.push(key);
                }
            });
            return tableHeaders;
        }

        /**
         * 
         */
        $scope.splitUppercase = function(key) {
            return $scope.$parent.splitUppercase(key);
        }

        /**
         * Convert the DOB
         * Into a readable format
         */
        $scope.dateConversion = function (dateString) {
            return DateFactory.convertWebApiDate(dateString, "/");
        };

        $scope.formatDate = function (datetime) {
            return DateFactory.formatDateddMonyyyyDashes(DateFactory.parseDate(datetime));
        }

        $scope.attendanceFix = function (DORSClientIdentifier, DORSCourseIdentifier) {
            CourseAttendanceService.ClearDORSClientCourseAttendanceLog(DORSCourseIdentifier, DORSClientIdentifier, activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        // refresh the table
                        $scope.getMeterData();
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = "An error occurred, Client not removed from meter.";
                    }
                );
        }


        /**
         * Fire the related modal
         */
        $scope.fireModal = function (type, value) {
            /**
             * Create Modal Buttons Aobject
             */
            var modalDetails = {
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            };

            /**
             * Set parameters based on what is clicked
             */
            if (type === "ClientId" || type === "Name") {
                $scope.clientId = value;
                modalDetails = angular.extend(modalDetails, {
                    scope: $scope,
                    title: "Client Details",
                    cssClass: "clientDetailModal",
                    filePath: "/app/components/client/cd_view.html",
                    controllerName: "clientDetailsCtrl",
                });
            } else if (type === "Course") {
                var courseSplit = value.split(" : ");
                var courseId = courseSplit[0];
                $scope.courseId = parseInt(courseId);
                $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
                $scope.userId = activeUserProfile.UserId;
                modalDetails = angular.extend(modalDetails, {
                    scope: $scope,
                    title: "View course",
                    cssClass: "courseViewModal",
                    filePath: "/app/components/course/edit.html",
                    controllerName: "editCourseCtrl",
                });
            }

            /**
             * Fire the modal
             */
            ModalService.displayModal(modalDetails);
        };

        $scope.openClientModal = function (clientId) {
            /**
             * Create Modal Buttons Object
             */
            var modalDetails = {
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            };

            $scope.clientId = clientId;
            modalDetails = angular.extend(modalDetails, {
                scope: $scope,
                title: "Client Details",
                cssClass: "clientDetailModal",
                filePath: "/app/components/client/cd_view.html",
                controllerName: "clientDetailsCtrl",
            });

            /**
             * Fire the modal
             */
            ModalService.displayModal(modalDetails);
        };

        $scope.openCourseModal = function (courseId) {
            /**
             * Create Modal Buttons Aobject
             */
            var modalDetails = {
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            };

            $scope.courseId = parseInt(courseId);
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
            $scope.userId = activeUserProfile.UserId;
            modalDetails = angular.extend(modalDetails, {
                scope: $scope,
                title: "View course",
                cssClass: "courseViewModal",
                filePath: "/app/components/course/edit.html",
                controllerName: "editCourseCtrl",
            });

            /**
             * Fire the modal
             */
            ModalService.displayModal(modalDetails);
        };


        /**
         * Fire trainer details related modal
         */
        $scope.fireTrainerDetailsModal = function (type, value) {
            /**
             * Create Modal Buttons Aobject
             */
            $scope.selectedTrainer = value;
            $scope.isModal = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Trainer Details",
                cssClass: "trainerEditModal",
                filePath: "/app/components/trainer/about/view.html",
                controllerName: "TrainerAboutCtrl",
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
         * Fire the Trainer Email related modal
         */
        $scope.fireModalTrainerEmail = function (emailAddress, trainerId, trainerName)  {

            var emailContent = "Dear " + trainerName + "\n\n"
                + "Can you please submit your Course attendance results.\n\n"
                + "Kind Regards\n\n"
                + "The Administration Team @ " + activeUserProfile.selectedOrganisation.Name;

            $scope.clientEmailAddress = emailAddress;
            $scope.clientEmailId = trainerId;
            $scope.clientEmailName = trainerName;
            $scope.recipientType = "Trainer";
            $scope.emailContent = emailContent;
            $scope.emailSubject = "Course Attendance Reminder";


            ModalService.displayModal({
                scope: $scope,
                title: "Send Trainer Email",
                cssClass: "sendClientEmailModal",
                filePath: "/app/components/email/view.html",
                controllerName: "SendEmailCtrl",
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
         * Fire the Trainer Email related modal
         */
        $scope.fireModalTrainerSMS = function (SMSPhoneNumber, trainerId, trainerName) {

            var SMSContent = "Dear " + trainerName + "\n"
                + "Can you please submit your Course attendance results.\n"
                + "Kind Regards\n"
                + "The Administration Team @ " + activeUserProfile.selectedOrganisation.Name;

            //TODO: The Client SMS code needs to be renamed to recipient as will be called for trainer and client
            //Setting the ClientID to the TrainerID is a "tactical solution"
            $scope.recipientType = "Trainer";
            $scope.clientId = trainerId;
            $scope.client = { DisplayName: trainerName };
            $scope.SMSPhoneNumber = SMSPhoneNumber;
            $scope.SMSContent = SMSContent;

            ModalService.displayModal({
                scope: $scope,
                title: "Send Trainer SMS",
                cssClass: "sendClientSMSModal",
                filePath: "/app/components/SMS/client.html",
                controllerName: "ClientSMSCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        };

        $scope.retryContactingDORS = function (clientId) {
            DorsService.retryContactingDORS(clientId)
                .then(
                    function successCallback(response) {
                        if (response.data == true) {
                            /**
                             * reload the meter's data from the web api
                             */
                            $scope.getMeterData();
                        }
                        else {
                            $scope.UnableToUpdateInDORSStatusMessage = "An error occurred, client may not be readded to the que.";
                        }
                    },
                    function errorCallback(response) {
                        $scope.UnableToUpdateInDORSStatusMessage = "An error occurred, client may not be readded to the que.";
                    }
                );
        }

        $scope.removeFromDORSQue = function (clientId) {
            DorsService.removeFromDORSQue(clientId)
                .then(
                    function successCallback(response) {
                        if (response.data == true) {
                            /**
                             * reload the meter's data from the web api
                             */
                            $scope.getMeterData();
                        }
                        else {
                            $scope.UnableToUpdateInDORSStatusMessage = "An error occurred, client may not be removed from que.";
                        }
                    },
                    function errorCallback(response) {
                        $scope.UnableToUpdateInDORSStatusMessage = "An error occurred, client may not be removed from que.";
                    }
                );
        }

        /**
         * load the meter's data from the web api
         */
        $scope.getMeterData();
    }

})();