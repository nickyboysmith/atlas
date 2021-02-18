(function () {

    'use strict';

    angular
        .module("app")
        .controller("ClientCourseBookingsCtrl", ClientCourseBookingsCtrl);
  
    ClientCourseBookingsCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "ClientService", "ClientRegistrationService", "DateFactory", "ModalService"];

    function ClientCourseBookingsCtrl($scope, $filter, activeUserProfile, ClientService, ClientRegistrationService, DateFactory, ModalService) {

        /**
         * 
         */
        $scope.clientCourseBookings = [];

        $scope.courses = [];
        $scope.noCoursesForDateSelectedLabel = "";
        $scope.clientCourseSelection = { index: -1 };

        var rebookingFee = 0; //initialize as zero


        /**
         * Put orgname on the scope
         */
        $scope.organisationName = activeUserProfile.selectedOrganisation.Name;

        /**
         * Get client details
         */
        ClientService.getCourseBookings(activeUserProfile.ClientId, activeUserProfile.OrganisationIds[0].Id)
        .then(
            function successCallback(response) {
                $scope.clientCourseBookings = response.data;
            },
            function errorCallback(response) {
                //console.log(response);
            }
        );

        $scope.compareToToday = function (prop, comparer) {
            return function (course) {

                const tomorrow = new Date();
                
                tomorrow.setHours(23);
                tomorrow.setMinutes(59);
                tomorrow.setSeconds(59);

                if (course[prop] != null) {
                    var courseStartDate = new Date(course[prop]);

                    if (comparer == "<") {
                        return courseStartDate < tomorrow;
                    } else if (comparer == ">") {

                        return courseStartDate >= tomorrow;
                    }
                }
            }
        };

        /**
         * check
         */
        $scope.limitedPlaceCheck = function (bookedPlaces, amountOfPlaces) {
            var isLimited = "Places Available";
            var percentageOfBooked = (1 - (bookedPlaces / amountOfPlaces)) * 100;
            if (percentageOfBooked <= 10) {
                isLimited = "Limited PLaces left";
            }
            return isLimited;
        };

        $scope.removeClientCourseSelection = function() {

            var courseDateSearchObject = {};

            $("#currentCourses").css("height", "230px");
            $scope.clientCourseSelection.index = -1;
            $scope.courseSelected = {};
            $scope.courses = [];
        };

        $scope.getClientCourseSelection = function (index, courseTypeId) {
            
            var clientDORSExpiryDate;
            var regionId;

            $scope.clientCourseSelection.index = -1;

            //reschedule requested so need larger div
            $("#currentCourses").css("height", "500px");

            $("#rowProcessingSpinner_" + index).show();

            $scope.courseSelected = { };

            $scope.courses = [];

            if($scope.clientCourseBookings[index].ClientDORSExpiryDate == null) {
                clientDORSExpiryDate = new Date().toLocaleDateString();
            }
            else {
                clientDORSExpiryDate = $scope.clientCourseBookings[index].ClientDORSExpiryDate;
            }

            if ($scope.clientCourseBookings[index].RegionId != null) {
                regionId = $scope.clientCourseBookings[index].RegionId;
            }
            else {
                $scope.validationMessage = "RegionId is null";
            }

            var courseDateSearchObject = {
                courseTypeId: courseTypeId,
                organisationId: activeUserProfile.OrganisationIds[0].Id,
                date: {
                is: "between",
                startDate: new Date().toLocaleDateString(),
                endDate: clientDORSExpiryDate
                },
                regionId: regionId
            };


            /**
            * Call the web api
            */
            ClientRegistrationService.getAvailableCourses(courseDateSearchObject)
            .then(
                function successCallback(response) {
                    $scope.courses = response.data;
                    $scope.validationMessage = '';
                    if (response.data.length == 0) {
                        $scope.noCoursesForDateSelectedLabel = $scope.clientCourseBookings[index].CourseType;
                    }
                    //scroll to top of current course
                    //var container = $('#currentCourses');
                    //var firstCourse = $('#courseToReschedule_0');
                    //var courseToScrollTo = $('#courseToReschedule_' + index);
                    //container.scrollTop(courseToScrollTo.offset().top - firstCourse.offset().top + container.scrollTop());
                    
                    $("#rowProcessingSpinner_" + index).hide();

                    $scope.clientCourseSelection.index = index;

                },
                function errorCallback(response) {
                    if (!response.data == false) {
                        $scope.validationMessage = response.data;
                    }
                    else {
                        $scope.validationMessage = response.statusText;
                    }
                    $("#rowProcessingSpinner_" + index).hide();

                }
            )

        };

        $scope.selectCourse = function ($event, course) {

            /**
             * Once a new one is clicked 
             * Then remove the previous class/(es)
             */
            angular.forEach($("tr.course-selected"), function (element, index) {
                $(element).removeClass("course-selected");
            });

            /**
             * Add the class to the element
             */
            $($event.currentTarget).addClass("course-selected");

            /**
             * Find the radio buton 
             * Then selcet it on click
             */
            $($event.currentTarget).find("input").prop("checked", true);


            /**
             * Put course on scope
             */
            $scope.courseSelected = course;
            $scope.courseSelected.RebookingFee = $scope.clientCourseBookings[$scope.clientCourseSelection.index].RebookingFee;
            $scope.courseSelected.TransferredFromCourseId = $scope.clientCourseBookings[$scope.clientCourseSelection.index].CourseId;
            $scope.courseSelected.Reschedule = true; // need for reschedule functionality as course selection page (clientCourseSelectionTemplate.html) shared bertween this and client registartion

        };

        $scope.clientRescheduleCourseDetails = function (course) {

            $scope.courseSelectedVenueId = course.VenueId;
            $scope.courseSelectedVenue = course.Location;
            //$scope.courseSelectedName = $scope.confirmationDetails.DORSCourse;
            $scope.courseSelectedDate = course.StartDate;


            ModalService.displayModal({
                scope: $scope,
                title: "Rescheduled Course Details",
                cssClass: "clientRescheduleCourseDetailsModal",
                filePath: "/app/components/client/clientRescheduleCourseDetails.html",
                controllerName: "clientRescheduleCourseDetailsCtrl",
                //buttons: {
                //    label: 'Close',
                //    cssClass: 'closeModalButton',
                //    action: function (dialogItself) {
                //        dialogItself.close();
                //    }
                //}
            });
        };
    }

})();