(function () {
    'use strict';

    angular
        .module('app')
        .controller('clientDetailsCtrl', clientDetailsCtrl);


    clientDetailsCtrl.inject = ['$scope', '$location', '$window', '$http', '$compile', '$filter', 'DateFactory', 'ModalService', 'ClientService', 'OrganisationSelfConfigurationService', 'RefundService', 'activeUserProfile', 'UserService', 'DorsService'];

    function clientDetailsCtrl($scope, $location, $window, $http, $compile, $filter, DateFactory, ModalService, ClientService, OrganisationSelfConfigurationService, RefundService, activeUserProfile, UserService, DorsService) {

        $scope.IsSystemAdmin = activeUserProfile.IsSystemAdmin;

        if ($scope.clientId == undefined) {
            $scope.clientId = $location.search().clientid;
        }

        $scope.isAdmin = false;
        UserService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );


        $scope.isReferringAuthority = activeUserProfile.IsReferringAuthority;
        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;

        $scope.formatDate = function (date) {
            if (date === undefined || date === null) {
                //return "No Birth date recorded";
                return "";
            }
            return DateFactory.formatDateddMONyyyy(DateFactory.parseDate(date));
        }

        $scope.checkSMSFunctionalityStatus = function (organisationId) {
            OrganisationSelfConfigurationService.checkSMSFunctionalityStatus(organisationId)
                    .then(function (response) {
                        $scope.isSMSEnabled = response.data
                    });
        }

        $scope.loadClientDetails = function (clientId) {

            $scope.prevClientName = undefined;
            $scope.nextClientName = undefined;

            //$http.get(apiServer + '/client/GetBasicClientInfo/' + clientId)
            ClientService.getBasicClientInfo(clientId)
                .then(function (response, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    $scope.client = response.data;
                    $scope.updateClientHistory = false;
                    $scope.getClientEmailAddresses(clientId);
                    $scope.getClientLicences(clientId);
                    $scope.getCourseInfo(clientId);
                    $scope.getClientPhoneNumbers(clientId);
                    //$scope.getClientDORSDetails(clientId);

                    //if ($scope.client.ClientMarkedForDeletions.length > 0) {
                    //    var lastDeletionAttempt = $scope.client.ClientMarkedForDeletions[$scope.client.ClientMarkedForDeletions.length - 1];
                    //    if (!lastDeletionAttempt.CancelledByUserId > 0) {
                    //        $scope.client.ClientMarkedForDeletion = lastDeletionAttempt.DeleteAfterDate.substring(8, 10) + '/' +
                    //                                                lastDeletionAttempt.DeleteAfterDate.substring(5, 7) + '/' +
                    //                                                lastDeletionAttempt.DeleteAfterDate.substring(0, 4);
                    //    } else {
                    //        $scope.client.ClientMarkedForDeletion = "";
                    //    }
                    //} else {
                    //    $scope.client.ClientMarkedForDeletion = "";
                    //}

                    if ($scope.client.DisplayName == undefined) {
                        $scope.client.DisplayName = ($scope.client.Title + " " + $scope.client.FirstName + " " + $scope.client.Surname).trim();
                    }

                    if ($scope.client.Address == undefined || $scope.client.Address == null) {
                        $scope.client.Address = response.data.Addresses[0].Address;
                    }

                    /**
                     * setup locking data
                     */
                    $scope.clientLock =
                    {
                        clientId: $scope.client.Id,
                        isReadOnly: $scope.client.LockedByUserId == null ? false : true,
                        lockedByUserName: $scope.client.LockedByUserName,
                        remainLocked: false
                    }

                    if ($scope.client.LockedByUserId == activeUserProfile.UserId) {
                        $scope.clientLock.isReadOnly = false;
                        $scope.clientLock.isLockedByCurrentUser = true;
                    }
                    else {
                        $scope.clientLock.isLockedByCurrentUser = false;
                    };


                    /**
                     * Call the client service to Add Client Lock
                     */
                    if ($scope.clientLock.isReadOnly == false && $scope.clientLock.isLockedByCurrentUser == false) {
                        ClientService.addClientLock(clientId, activeUserProfile.UserId)
                        .then(
                            function (response) {
                                var theData = $.parseJSON(response.data);
                                $scope.clientLock.ClientId = response.data
                            },
                            function (reason) {
                                console.log(reason);
                            }
                        );
                    };

                    /**
                        Get client status
                    **/

                    ClientService.getClientStatus(clientId)
                        .then(
                            function (response) {
                                if (response.data) {
                                    $scope.client.clientStatus = response.data.ClientStatus;
                                }
                                else {
                                    $scope.client.clientStatus = "";
                                }
                            }
                        )


                    UserService.isMysteryShopperAdministrator(activeUserProfile.UserId)
                        .then(
                            function (data) {
                                if (data == true) {
                                    $scope.IsMysteryShopperAdministrator = true;
                                }
                                else {
                                    $scope.IsMysteryShopperAdministrator = false;
                                }
                            },
                            function (data) {
                                $scope.IsMysteryShopperAdministrator = false;
                            }
                    );


                    /**
                     * 
                     */
                    $scope.hasLicenceDetails = $scope.client.HasLicenceDetails;

                    /**
                    * Get the client configuration options
                    */
                    $scope.getClientConfigurationOptions(activeUserProfile.selectedOrganisation.Id);
                    /**
                     * Call the method after the client details 
                     * have completed
                     */
                    $scope.getClientSpecialRequirements(clientId, activeUserProfile.selectedOrganisation.Id);


                    ///**
                    // * client lock setup close
                    //**/
                    //angular.forEach(BootstrapDialog.dialogs, function (dialog, Id) {
                    //    //ModalService.getCurrentModalByClass('clientDetailModal')
                    //    if (dialog.defaultOptions.title = 'Client Details')
                    //        {
                    //            dialog.defaultOptions.onhide = function () {
                    //                $scope.removeClientLock($scope.client.Id);
                    //            }
                    //        }   
                    //});


                    // set up the next and previous buttons
                    // can only show previous and next if coming in from main client search
                    if ($scope.clientIndex == "undefined" || $scope.clientIndex == null) {
                        $scope.hidePrevNext = true;
                    } else {
                        if ($scope.clientIndex > 0) {
                            $scope.prevClientName = $scope.clients[$scope.clientIndex - 1].clientName;
                        }
                        if ($scope.clientIndex < $scope.clients.length - 1) {
                            $scope.nextClientName = $scope.clients[$scope.clientIndex + 1].clientName;
                        }
                        $scope.hidePrevNext = false;
                    }

                    //Set up the Client Id Hover text
                    if ($scope.client.ClientUniqueIdentifier && $scope.client.ClientUniqueIdentifier.length > 0) {
                        $scope.clientIdHoverText = "Client System Identifier: " + $scope.client.Id + "; Client UID: " + $scope.client.ClientUniqueIdentifier[$scope.client.ClientUniqueIdentifier.length - 1].UniqueIdentifier + "; ";
                    } else {
                        $scope.clientIdHoverText = "Client System Identifier: " + $scope.client.Id + "; ";
                    }

                    if ($scope.client.ClientPreviousIds && $scope.client.ClientPreviousIds.length > 0) {
                        $scope.clientIdHoverText = $scope.clientIdHoverText + "Previous System Id: " + $scope.client.ClientPreviousIds[$scope.client.ClientPreviousIds.length - 1].PreviousClientId;
                    }

                    $scope.validationMessage = "Success.";
                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }


        $scope.loadClientDetails($scope.clientId);

        /**
       * Get the client configuration options
       */
        $scope.getClientConfigurationOptions = function (organisationId) {
            OrganisationSelfConfigurationService.GetByOrganisation(organisationId)
                    .then(
                        function (response) {
                            //$scope.showPhotoCardExpiry = response.data.ShowLicencePhotocardDetails;
                            //$scope.showClientDisplayName = response.data.ShowClientDisplayName;
                            $scope.showDriversLicenceExpiryDate = response.data.ShowDriversLicenceExpiryDate;
                        },
                        function (response) {
                        }
                    );
        }



        /**
         * Call the client special requirements service
         */
        $scope.getClientSpecialRequirements = function (clientId, organisationId) {
            ClientService.getSpecialRequirements(clientId, organisationId)
            .then(
                function (response) {
                    $scope.client["SpecialRequirements"] = response.data;
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };


        /**
         * Call the client service to Delete Client Lock 
         */
        $scope.removeClientLock = function (Id) {
            if ($scope.clientLock != undefined) { /* Belt and braces check */
                if ($scope.clientLock.remainLocked == false && $scope.clientLock.isReadOnly == false) {

                    ClientService.removeClientLock(Id)
                    .then(
                        function (response) {
                        },
                        function (reason) {
                            console.log(reason);
                        }
                    );
                }
            }
        };

        /**
         * Open a modal
         * Pass client Id and organisation Id
         */
        $scope.openClientSpecialRequirementModal = function () {

            $scope.specialRequirementClientId = $scope.client.Id;
            $scope.specialRequirementClientName = $scope.client.DisplayName;
            $scope.specialRequirementOrganisationId = activeUserProfile.selectedOrganisation.Id;

            ModalService.displayModal({
                scope: $scope,
                title: "Client Additional Requirements",
                cssClass: "updateClientSpecialRequirementsModal",
                filePath: "/app/components/client/updateSpecialRequirements.html",
                controllerName: "UpdateSpecialRequirementsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.addNote = function (clientId) {
            // reset the parameter so the watch is still watching
            $scope.updateClientHistory = false;

            // open client details Modal
            $scope.clientId = clientId;
            ModalService.displayModal({
                scope: $scope,
                title: "Add Client Note",
                cssClass: "addClientNoteModal",
                filePath: "/app/components/client/addNote.html",
                controllerName: "addClientNoteCtrl"
            });
            //$scope.ShowMenuItem('', '', 'addClientNoteCtrl', 'true', 'true', 'AtlasModal');
        };



        $scope.takePayment = function (clientId, clientName) {

            // find the most relevant course for this payment...
            // also ensure that the client hasn't been removed from the course and that there is an amount outstanding
            var courseName = "";
            var amountOutstanding = "";
            var courseId = "";
            if ($scope.client && $scope.client.CourseInformation) {
                var sortedCourses = ($scope.client.CourseInformation).sort(function (a, b) {
                    return a.CourseDate - b.CourseDate;
                });
                for (var i = 0; i < sortedCourses.length; i++) {
                    if (sortedCourses[i].AmountOutstanding != "0.00" && (sortedCourses[i].ClientRemoved == false)) {
                        courseName = sortedCourses[i].Reference;
                        amountOutstanding = sortedCourses[i].AmountOutstanding;
                        courseId = sortedCourses[i].Id;
                        break;
                    }
                }
                //var sortedCourses = ($scope.client.CourseInformation).CourseInformation; //The Above Lines Now Returns an Error. So doing it this way for now. //TO DO: Fix This
                ////for (var i = 0; i < sortedCourses.length; i++) {
                //    if (sortedCourses.AmountOutstanding != "0.00" && (sortedCourses.ClientRemoved == false)) {
                //        courseName = sortedCourses.Reference;
                //        amountOutstanding = sortedCourses.AmountOutstanding;
                //        courseId = sortedCourses.Id;
                //        //break;
                //    }
                //}
            }

            // open client details Modal
            console.log("Open the Take Payment");
            $scope.clientId = clientId;

            /**
             * This object originates from the 
             * Controller: AcceptPaymentCardCtrl
             * File: /app/components/payment/controllers/acceptCardPaymentController
             * Line: 233 - (As of 04/05/16)
             * Full properties that can be set are in the file as mentioned above
             */
            var courses = [{ CourseId: courseId }];

            if (clientName == undefined) {
                clientName = ($scope.client.Title + " " + $scope.client.FirstName + " " + $scope.client.Surname).trim();
            }

            // Mile's code uses this 'isAssignedTo' param to determine what you are paying for...
            var isAssignedTo = "client";
            if (courseId != "") {
                isAssignedTo = "clientCourse";
            }

            /**
             * Object to passs to the take payment screen
             */
            $scope.clientTakePaymentDetail = {
                clientName: clientName,
                courseName: courseName,
                isAssignedTo: isAssignedTo,
                clientId: clientId,
                amount: amountOutstanding,
                courses: courses
            };

            $scope.validationMessage = "";  // avoids it from being displayed in the subsequent modal on open

            ModalService.displayModal({
                scope: $scope,
                title: "Take Card Payment",
                cssClass: "acceptCardPaymentModal",
                filePath: "/app/components/payment/acceptCard.html",
                controllerName: "AcceptCardPaymentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.deleteClient = function (clientId, clientName) {

            $scope.clientId = clientId;

            /**
             * Object to pass to the take payment screen
             */
            $scope.clientDeleteDetail = {
                clientName: clientName,
                clientId: clientId
            };

            ModalService.displayModal({
                scope: $scope,
                title: "Delete Client",
                cssClass: "clientDeleteConfirmationModal",
                filePath: "/app/components/client/deleteConfirmation.html",
                controllerName: "deleteClientConfirmationCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.cancelDeletion = function (clientId) {

            $scope.clientUndeleteDetail = {
                userId: activeUserProfile.UserId,
                id: clientId
            };

            ClientService.undeleteClient($scope.clientUndeleteDetail).then
            (
               function successFunction(response) {
                   if (response.data) {
                       if (response.data == "success") {
                           //$scope.completedMessage = "Delete Successful";
                           //$scope.hideSuccessMessage = false;

                           $scope.loadClientDetails(clientId);
                           if ($scope.$parent.getClientsMarkedForDeletion) {
                               $scope.$parent.getClientsMarkedForDeletion(activeUserProfile.selectedOrganisation.Id);
                           }
                       }
                       else {
                           //$scope.errorMessage = "Delete Failed";
                           //$scope.hideErrorMessage = false;
                       }
                   }
               }
               ,
               function failedFunction() {
                   //$scope.errorMessage = "Delete Failed";
                   //$scope.hideErrorMessage = false;
               }
            );
        }

        /**
         * 
         */
        $scope.getClientAge = function (dateString) {
            var today = new Date();
            var birthDate = new Date(dateString);
            var age = today.getFullYear() - birthDate.getFullYear();
            var m = today.getMonth() - birthDate.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
            return age;
        };

        /**
         * 
         */
        $scope.enterPayment = function (clientId, clientName) {

            // find the most relevant course for this payment...
            // also ensure that the client hasn't been removed from the course and that there is an amount outstanding
            var courseName = "";
            var amountOutstanding = "";
            var courseId = "";
            if ($scope.client && $scope.client.CourseInformation) {
                var sortedCourses = ($scope.client.CourseInformation).sort(function (a, b) {
                    return a.CourseDate - b.CourseDate;
                });
                for (var i = 0; i < sortedCourses.length; i++) {
                    if (sortedCourses[i].AmountOutstanding != "0.00" && (sortedCourses[i].ClientRemoved == false)) {
                        courseName = sortedCourses[i].Reference;
                        amountOutstanding = sortedCourses[i].AmountOutstanding;
                        courseId = sortedCourses[i].Id;
                        break;
                    }
                }
               // var sortedCourses = ($scope.client.CourseInformation).CourseInformation;//The Above Lines Now Returns an Error. So doing it this way for now. //TO DO: Fix This
                //for (var i = 0; i < sortedCourses.length; i++) {
                    //if (sortedCourses.AmountOutstanding != "0.00" && (sortedCourses.ClientRemoved == false)) {
                    //    courseName = sortedCourses.Reference;
                    //    amountOutstanding = sortedCourses.AmountOutstanding;
                    //    courseId = sortedCourses.Id;
                    //    //break;
                    //}
                //}
            }

            /**
             * This object orginiates from the 
             * Controller: AcceptPaymentCardCtrl
             * File: /app/components/payment/controllers/acceptCardPaymentController
             * Line: 233 - (As of 04/05/16)
             * Full properties that can be set are in the file as mentioned above
             */
            var courses = [{ CourseId: courseId }];

            if (clientName == undefined) {
                clientName = ($scope.client.Title + " " + $scope.client.FirstName + " " + $scope.client.Surname).trim();
            }

            $scope.successfulPayment = {
                clientName: clientName,
                courseName: courseName,
                isAssignedTo: "clientCourse",
                clientId: clientId,
                amount: amountOutstanding,
                courses: courses
            };

            ModalService.displayModal({
                scope: $scope,
                title: "Enter Payment Transaction",
                cssClass: "recordPaymentModal",
                filePath: "/app/components/payment/record.html",
                controllerName: "RecordPaymentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.editClient = function (clientId) {
            $scope.clientId = clientId;
            $scope.ShowMenuItem('Edit Client', '/app/components/client/edit.html', 'editClientCtrl', 'true', 'true', 'clientEditModal');
        };

        $scope.ShowMenuItem = function (title, url, controller, enabled, modal, cssClass) {
            if (enabled == 'true') {
                if (modal == 'true') {
                    BootstrapDialog.show({
                        scope: $scope,
                        title: title,
                        closable: true,
                        closeByBackdrop: false,
                        closeByKeyboard: false,
                        draggable: true,
                        cssClass: cssClass,
                        message: function (dialog) {
                            var pageToLoad = dialog.getData('pageToLoad');
                            return $compile('<div ng-app="app" ng-controller="' + controller + '" ng-include="\'' + pageToLoad + '\'"></div>')($scope);
                        },
                        data: {
                            'pageToLoad': url,
                        }
                    });
                } else {
                    $location.url(url);
                }
            }
        };

        $scope.NextClient = function () {
            if ($scope.clientIndex < $scope.clients.length - 1) {
                $scope.removeClientLock($scope.clientLock.clientId);
                $scope.clientIndex = $scope.clientIndex + 1;
                $scope.clientId = $scope.clients[$scope.clientIndex].ClientId;
                $scope.loadClientDetails($scope.clientId);
            }
        };

        $scope.PrevClient = function () {
            if ($scope.clientIndex > 0) {
                $scope.removeClientLock($scope.clientLock.clientId);
                $scope.clientIndex = $scope.clientIndex - 1;
                $scope.clientId = $scope.clients[$scope.clientIndex].ClientId;
                $scope.loadClientDetails($scope.clientId);
            }
        };

        $scope.CloseAndRemainLocked = function () {
            $scope.clientLock.remainLocked = true;
            ModalService.closeCurrentModal("clientDetailModal");
        };

        $scope.bookCourse = function (clientId) {

            $scope.clientId = clientId;

            ModalService.displayModal({
                scope: $scope,
                title: "Available Courses - For Client",
                cssClass: "availableCoursesForClientModal",
                filePath: "/app/components/client/availableCourses.html",
                controllerName: "clientAvailableCoursesCtrl"
            });
        };

        $scope.showUniqueIdentiferModal = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Client Unique Identifiers",
                cssClass: "addIdentifierModal",
                filePath: "/app/components/client/addIdentifier.html",
                controllerName: "addIdentifierCtrl"
            });
        };

        /**
         * Show the client email modal
         */
        $scope.showEmailClientModal = function () {
            console.log("Modal firing");
            console.log("Add to scope");

            if ($scope.client.Emails.length === 0) {
                console.log("error");
                return false;
            }

            $scope.clientEmailAddress = $scope.client.Emails[0].Address;
            $scope.clientEmailName = $scope.client.DisplayName;
            $scope.clientEmailId = $scope.client.Id;

            ModalService.displayModal({
                scope: $scope,
                title: "Send Client Email",
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

        $scope.showSMSClientModal = function (phoneNumber) {

            $scope.SMSPhoneNumber = phoneNumber;

            ModalService.displayModal({
                scope: $scope,
                title: "Send Client SMS",
                cssClass: "sendClientSMSModal",
                filePath: "/app/components/SMS/client.html",
                controllerName: "ClientSMSCtrl"
            });
        }

        $scope.editCourseBooking = function (courseInfo) {
            if (courseInfo) {
                $scope.currentCourse = courseInfo;

                ModalService.displayModal({
                    scope: $scope,
                    title: "Edit Course Booking",
                    cssClass: "editCourseBookingModal",
                    filePath: "/app/components/client/editCourseBooking.html",
                    controllerName: "EditCourseBookingCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });
            }
        }

        $scope.setFlagToRefreshClientHistory = function () {
            $scope.updateClientHistory = true;
        }

        $scope.resetClientHistoryRefresh = function () {
            $scope.updateClientHistory = false;
        }

        $scope.refundPayment = function (clientId) {
            ClientService.getPaymentsByClient(clientId, activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        var payments = response.data;

                        if (payments.length == 1) {
                            // show the payment refund modal
                            $scope.refundPaymentId = payments[0].PaymentId;
                            ModalService.displayModal({
                                scope: $scope,
                                title: "Record Payment Refund",
                                cssClass: "refundPaymentModal",
                                filePath: "/app/components/payment/refund.html",
                                controllerName: "RefundPaymentCtrl",
                                buttons: {
                                    label: 'Close',
                                    cssClass: 'closeModalButton',
                                    action: function (dialogueItself) {
                                        dialogueItself.close();
                                    }
                                }
                            });
                        }
                        else {
                            // show the client payments modal
                            $scope.payments = payments;
                            ModalService.displayModal({
                                scope: $scope,
                                title: "Client Payments",
                                cssClass: "clientPaymentsModal",
                                filePath: "/app/components/client/payments.html",
                                controllerName: "ClientPaymentsCtrl",
                                buttons: {
                                    label: 'Close',
                                    cssClass: 'closeModalButton',
                                    action: function (dialogueItself) {
                                        dialogueItself.close();
                                    }
                                }
                            });
                        }
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.performDORSCheck = function () {
            if ($scope.client.Licences.length > 0) {
                var licenceNumber = $scope.client.Licences[0].LicenceNumber;
                DorsService.performDORSCheck($scope.client.Id, licenceNumber)
                    .then(
                        function successCallback(response) {
                            $scope.client.dorsClientCourseAttendances = response.data;
                        },
                        function errorCallback(response) {

                        }
                    );
            }
        }

        /**
        * client lock setup close
        **/
        $scope.clientLockSetupClose = function () {

            angular.forEach(BootstrapDialog.dialogs, function (dialog, Id) {
                if (dialog.defaultOptions.title = 'Client Details') {
                    dialog.defaultOptions.onhide = function () {
                        $scope.removeClientLock($scope.client.Id);
                    }
                }
            });
        }

        $scope.openCourseModal = function (courseInfo) {
            if (courseInfo) {
                $scope.currentCourse = courseInfo;

                $scope.courseId = courseInfo.Id;
                $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
                $scope.userId = activeUserProfile.UserId;

                ModalService.displayModal({
                    scope: $scope,
                    title: "View Course",
                    cssClass: "editCourseBookingModal",
                    filePath: "/app/components/course/edit.html",
                    controllerName: "editCourseCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });

            }
        }

        $scope.clearDORSData = function (clientId) {
            DorsService.clearDORSData(clientId, activeUserProfile.selectedOrganisation.Id, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        alert("Clearing DORS Data - successful");
                    },
                    function errorCallback(response) {
                        alert("There was an error with Clearing DORS Data.");
                    }
                );
        }
        
        $scope.getClientEmailAddresses = function (clientId) {
            ClientService.getClientEmailAddresses(clientId)
         .then(function (response) {
             $scope.client.Emails = response.data;
         });
        }

        $scope.getCourseInfo = function (clientId) {
            ClientService.getCourseInfo(clientId)
         .then(function (response) {
             $scope.client.CourseInformation = response.data;
         });
        }

        $scope.getClientLicences = function (clientId) {
            ClientService.getClientLicences(clientId)
         .then(function (response) {
             $scope.client.Licences = response.data;
         });
        }

        $scope.getClientPhoneNumbers = function (clientId) {
            ClientService.getClientPhoneNumbers(clientId)
         .then(function (response) {
             $scope.client.PhoneNumbers = response.data;
         });
        }


        $scope.checkSMSFunctionalityStatus(activeUserProfile.selectedOrganisation.Id);
        $scope.clientLockSetupClose();
        //$scope.getClientEmailAddresses()

    }
})();