(function () {

    'use strict';


    angular
    .module("app.controllers")
    .controller("ReminderSMSCtrl", ReminderSMSCtrl);


    ReminderSMSCtrl.$inject = ["$scope", "$rootScope",  "AtlasCookieFactory", "CourseService", "UserService", "$compile", "activeUserProfile"];


    function ReminderSMSCtrl($scope, $rootScope, AtlasCookieFactory, CourseService, UserService, $compile, activeUserProfile) {

        $scope.userService = UserService;
        $scope.userId = activeUserProfile.UserId;

        $scope.courseService = CourseService;

        $scope.reminderSMS = {};

        $scope.insertClientName = "<!Client Name!>";
        $scope.insertCourseType = "<!Course Type!>";
        $scope.insertCourseDate = "<!Course Date!>";

        $scope.clientNameLink = $scope.insertClientName + " with the Client's Name";
        $scope.courseTypeLink = $scope.insertCourseType + " with the Course Type";
        $scope.courseDateLink = $scope.insertCourseDate + " with the Course Start Date";

        $scope.items = [];

        $scope.insertText = function (insertText) {
            $scope.items.push(insertText);
            $rootScope.$broadcast('insertText', insertText);
        }

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

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (data) {
                    $scope.isAdmin = data;
                });

                // are we displaying from the admin menu or from OrganisationSelfConfiguration
                if (!angular.isUndefined($scope.$parent.fromSelfConfiguration)) {
                    $scope.organisationId = $scope.$parent.organisationId;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        //Get Reminder SMS Template
        $scope.getReminderSMS = function (organisationId) {

            var courseCode = "CourseReminder";

            $scope.courseService.getReminderSMSByOrganisationCourseCode(organisationId, courseCode)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.reminderSMS = response.data;

                        $scope.successMessage = "";
                        $scope.validationMessage = "";
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        $scope.save = function () {

            reminderSMS.UpdatedByUserId = $scope.userId;

            $scope.courseService.saveReminderSMSTemplate($scope.reminderSMS)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.successMessage = "Save Sucessful";
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

        $scope.getOrganisations($scope.userId);
        $scope.getReminderSMS($scope.organisationId);

    }
})();