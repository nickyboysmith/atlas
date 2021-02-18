(function () {
    'use strict';

    angular
        .module('app')
        .controller('addCourseStencilCtrl', ['$scope', '$location', '$window', '$http', '$filter', 'CourseStencilService', 'CourseService', 'activeUserProfile', 'CourseReferenceService', 'OrganisationSelfConfigurationService', 'DateFactory', 'ModalService',  addCourseStencilCtrl]);

    function addCourseStencilCtrl($scope, $location, $window, $http, $filter, CourseStencilService, CourseService, activeUserProfile, CourseReferenceService, OrganisationSelfConfigurationService, DateFactory, ModalService, $route) {
        $scope.displayCalendar = false;
        $scope.disableName = false;
        $scope.showCancel = true;
        $scope.hideCloning = false;
        $scope.displayCalendar2 = false;
        $scope.isDORSCourseType = false;
        $scope.courseStencil = {
            listOfCourseStencils: [],
            listOfCourseTypes: [],
            listOfCourseTypeCategories: [],
            listOfVenues: [],
            listOfCourseReferenceGenerators: [],
            listOfDaysInAWeek: [],
            listOfDaysInAMonth: [],
            listOfSkipDays: [],
            courseTypeCategoryId: "",
            courseTypeId: "",
            venueId: "",
            courseReferenceGeneratorId: "",
            versionNumber: leftPadString(1, "000"),
            dailyCourses: false,
            weeklyCourses:false,
            monthlyCourses: false
        };
        $scope.courseStencilService = CourseStencilService;
        $scope.courseService = CourseService;
        $scope.courseReferenceService = CourseReferenceService;

        $scope.orgSystemConfig = new Object();

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.courseStencil.userId = activeUserProfile.UserId;
        $scope.courseStencil.organisationId = activeUserProfile.selectedOrganisation.Id
        $scope.courseStencil.Id = 0;

        $scope.courseStencilSelected = function (c) {
            $http({
            url: apiServer + "/courseStencil",
                method: "GET",
                params: {
                    courseStencilId: c,
                    userId: $scope.courseStencil.userId
            },
            })
           .then(function (data) {
               if ($scope.$parent.editStencilVersionId) {
                    createCourseStencil(data.data, false);
               }
               else {
                   createCourseStencil(data.data, true);
                }

           })
        }

        //coming in from the maintain course stencils modal
        if ($scope.$parent.editStencilVersionId) {
            if ($scope.$parent.editStencilVersionId > 0) {
                $scope.courseStencilSelected($scope.$parent.editStencilVersionId);
                $scope.hideCloning = true;
                $scope.disableName = true;

                if ($scope.$parent.newVersion == true) {
                    $scope.courseStencil.versionNumber++;
                    $scope.courseStencil.ParentCourseStencilId = $scope.$parent.editStencilVersionId;
                    $scope.courseStencil.Id = 0;
                    }
            }
         }

        //************
        // All lookups
        //************ 
        /** Get the Course Stencils associated with the organisation */
        GetAvailableCourseStencils();

        /** Get the Course Types associated with the organisation */
        $scope.courseService.getRelatedCourseTypes($scope.courseStencil.organisationId)
             .then(function (data) {
                 $scope.courseStencil.listOfCourseTypes = data;
                 //if ($scope.courseStencil.courseTypeId != -1) {
                 //    $scope.courseStencil.courseTypeId = $scope.courseStencil.listOfCourseTypes[0].Id;
                 //}
             }, function (data) {
                 console.log("Can't get related course types");
             });

        /** Get the Course Types Categories associated with the organisation **/
        $scope.courseService.getRelatedCourseCategories($scope.courseStencil.organisationId, $scope.courseStencil.userId)
             .then(function (data) {
                 $scope.courseStencil.listOfCourseTypeCategories = data;
                 //if ($scope.courseStencil.courseTypeCategoryId != -1) {
                 //    $scope.courseStencil.courseTypeCategoryId = $scope.courseStencil.listOfCourseTypeCategories[0].Id;
                 //}
             }, function (data) {
                 console.log("Can't get related course type categories");
             });

        /** Get the Venues associated with the organisation */
        $scope.courseService.getRelatedVenues($scope.courseStencil.organisationId)
             .then(function (data) {
                 $scope.courseStencil.listOfVenues = data;

                 //if ($scope.courseStencil.venueId != -1) {
                 //    $scope.courseStencil.venueId = $scope.courseStencil.listOfVenues[0];
                 //}
             }, function (data) {
                 console.log("Can't get related venues");
             });

        /** Get the Course Reference Generators associated with the organisation */
        $scope.courseReferenceService.GetAll()
            .then(function (data) {
                $scope.courseStencil.listOfCourseReferenceGenerators = data.data;
                //$scope.courseStencil.courseReferenceGeneratorId = $scope.courseStencil.listOfCourseReferenceGenerators[0];
            }, function (data) {
                console.log("Can't get course reference generator");
            });

        /** Get the Days of the week */
        var data = [
              { day: "Monday", id: 1, weekday: true },
              { day: "Tuesday", id: 2, weekday: true },
              { day: "Wednesday", id: 3, weekday: true },
              { day: "Thursday", id: 4, weekday: true },
              { day: "Friday", id: 5, weekday: true },
              { day: "Saturday", id: 6, weekday: false },
              { day: "Sunday", id: 7, weekday: false }
        ];
        $scope.courseStencil.listOfDaysInAWeek = data;
        $scope.courseStencil.weeklyCourseStartDay = $scope.courseStencil.listOfDaysInAWeek[0].id

        /** Get the Days in a month */
        var noOfDays = [];
        for (var i = 1; i <= 31; i++) {
            var element = { day: String("0" + i).slice(-2), id: i }
            noOfDays.push(element);
        }
        $scope.courseStencil.listOfDaysInAMonth = noOfDays;
        $scope.courseStencil.monthlyCoursesPreferredDayStart = $scope.courseStencil.listOfDaysInAMonth[0].id;

        /** Get the skip days */
        var skipDays = [
            { skipday: "0", Id: 0 },
            { skipday: "2", Id: 2 },
            { skipday: "3", Id: 3 },
        ];
        $scope.courseStencil.listOfSkipDays = skipDays;
        $scope.courseStencil.dailyCoursesSkipDays = $scope.courseStencil.listOfSkipDays[0].Id;



        //*************************
        // Methods used on the view
        //************************* 
        $scope.courseTypeChange = function (courseTypeId) {
            buildNewStencilName(courseTypeId);
            var selectedCourseTypes = $filter('filter')($scope.courseStencil.listOfCourseTypes, {Id: courseTypeId});
            if(selectedCourseTypes.length > 0) {
                $scope.isDORSCourseType = selectedCourseTypes[0].DORSOnly;
            }
        }

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
            if ($scope.displayCalendar) {
                $scope.displayCalendar2 = false;
            }
        }

        $scope.toggleCalendar2 = function () {
            $scope.displayCalendar2 = !$scope.displayCalendar2;
            if ($scope.displayCalendar2) {
                $scope.displayCalendar = false;
            }
        }

        $scope.addCourseStencil = function () {

            if ($scope.courseStencil) {

                $http.defaults.headers.post["Content-Type"]= "application/x-www-form-urlencoded";

                if (!ValidCourseStencil())
                    return false;

                $http.post(apiServer + '/courseStencil', $scope.courseStencil)
                .then(function (data, status, headers, config) {

                    $scope.showSuccessFader = true;
                    if ($scope.$parent.editStencilVersionId) {
                        $scope.$parent.showStencils($scope.$parent.organisationId);
                    }
                    //if (c == 'c') {
                    //    $('button.close').trigger('click');
                    //}

                    $scope.validationMessage = data.data.actionMessage;
                    GetAvailableCourseStencils();
                    if (data.data.valid == true) {
                        //once saved it's not a new version so need to reset
                        $scope.$parent.newVersion = false;
                        $scope.showCancel = false;
                        createCourseStencil(data.data, false);

                    }
                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.showErrorFader = true;
                    $scope.validationMessage = data.data.actionMessage;
                });
            }
            else {
                $scope.validationMessage = "An error occurred please try again";
            }
        }

        $scope.preferredWeekdayStartSelected = function (preferredStartDay) {

            switch (preferredStartDay) {
                case 1:
                    $scope.courseStencil.excludeMonday = false;
                    break;
                case 2:
                    $scope.courseStencil.excludeTuesday = false;
                    break;
                case 3:
                    $scope.courseStencil.excludeWednesday = false;
                    break;
                case 4:
                    $scope.courseStencil.excludeThursday = false;
                    break;
                case 5:
                    $scope.courseStencil.excludeFriday = false;
                    break;
                case 6:
                    $scope.courseStencil.excludeSaturday = false;
                    break;
                case 7:
                    $scope.courseStencil.excludeSunday = false;
                    break;
            }

        }

        $scope.toggleCourseIntervalCheckboxes = function (courseIntervalinterval) {
            if ($scope.courseStencil.weeklyCourses && courseIntervalinterval == "weekly") {
                $scope.courseStencil.monthlyCourses = false;
                $scope.courseStencil.monthlyCoursesPreferredDayStart = $scope.courseStencil.listOfDaysInAMonth[0].id;
                $scope.courseStencil.dailyCourses = false;
                $scope.courseStencil.dailyCoursesSkipDays = $scope.courseStencil.listOfSkipDays[0].Id;

                if ($scope.courseStencil.excludeMonday == true && $scope.courseStencil.weeklyCourseStartDay == 1)
                {
                    $scope.preferredWeekdayStartSelected(1);
                }
            } else if ($scope.courseStencil.monthlyCourses && courseIntervalinterval == "monthly") {
                $scope.courseStencil.weeklyCourses = false;
                $scope.courseStencil.weeklyCourseStartDay = $scope.courseStencil.listOfDaysInAWeek[0].id;
                $scope.courseStencil.dailyCourses = false;
                $scope.courseStencil.dailyCoursesSkipDays = $scope.courseStencil.listOfSkipDays[0].Id;
            } else if ($scope.courseStencil.dailyCourses && courseIntervalinterval == "daily") {
                $scope.courseStencil.weeklyCourses = false;
                $scope.courseStencil.weeklyCourseStartDay = $scope.courseStencil.listOfDaysInAWeek[0].id;
                $scope.courseStencil.monthlyCourses = false;
                $scope.courseStencil.monthlyCoursesPreferredDayStart = $scope.courseStencil.listOfDaysInAMonth[0].id;
            }
        }
        
        $scope.formatDate = function (date) {
            return DateFactory.formatDateddMONyyyy(date);
        }

        function createCourseStencil(data, resetCourseStencilId) {

            $scope.courseStencil.Id = data.Id;
            $scope.courseStencil.name = data.name;
            $scope.courseStencil.versionNumber = data.versionNumber;
            $scope.courseStencil.maxCourses = data.maxCourses;
            $scope.courseStencil.excludeBankHolidays = data.excludeBankHolidays;
            $scope.courseStencil.excludeWeekends = data.excludeWeekends;

            if (data.earliestStartDate != null) {
                $scope.courseStencil.earliestStartDate = DateFactory.formatDateddMONyyyy(DateFactory.parseDate(data.earliestStartDate));
            } else {
                $scope.courseStencil.earliestStartDate = null;
            }

            if (data.latestStartDate != null) {
                $scope.courseStencil.latestStartDate = DateFactory.formatDateddMONyyyy(DateFactory.parseDate(data.latestStartDate));
            } else {
                $scope.courseStencil.latestStartDate = null;
            }

            $scope.courseStencil.sessionStartTime1 = data.sessionStartTime1;
            $scope.courseStencil.sessionEndTime1 = data.sessionEndTime1;
            $scope.courseStencil.sessionStartTime2 = data.sessionStartTime2;
            $scope.courseStencil.sessionEndTime2 = data.sessionEndTime2;
            $scope.courseStencil.sessionStartTime3 = data.sessionStartTime3;
            $scope.courseStencil.sessionEndTime3 = data.sessionEndTime3;

            if (data.sessionStartTime2 != null || data.sessionStartTime2 != null) {
                $scope.courseStencil.allowSessionTime2 = true;
            } else {
                $scope.courseStencil.allowSessionTime2 = false;
            }

            if (data.sessionStartTime3 != null || data.sessionStartTime3 != null) {
                $scope.courseStencil.allowSessionTime3 = true;
            } else {
                $scope.courseStencil.allowSessionTime3 = false;
            }

            $scope.courseStencil.multiDayCourseDaysBetween = data.multiDayCourseDaysBetween;
            $scope.courseStencil.courseTypeId = data.courseTypeId;
            $scope.courseStencil.courseTypeCategoryId = data.courseTypeCategoryId;
            $scope.courseStencil.venueId = data.venueId;
            $scope.courseStencil.trainerCost = data.trainerCost;
            $scope.courseStencil.trainersRequired = data.trainersRequired;
            $scope.courseStencil.coursePlaces = data.coursePlaces;
            $scope.courseStencil.reservedPlaces = data.reservedPlaces;
            $scope.courseStencil.courseReferenceGeneratorId = data.courseReferenceGeneratorId;
            $scope.courseStencil.beginReferenceWith = data.beginReferenceWith;
            $scope.courseStencil.endReferenceWith = data.endReferenceWith;

            $scope.courseStencil.weeklyCourses = data.weeklyCourses;
            $scope.courseStencil.weeklyCourseStartDay = data.weeklyCourseStartDay;
            $scope.courseStencil.monthlyCourses = data.monthlyCourses;
            $scope.courseStencil.monthlyCoursesPreferredDayStart = data.monthlyCoursesPreferredDayStart;
            $scope.courseStencil.dailyCourses = data.dailyCourses;
            $scope.courseStencil.dailyCoursesSkipDays = data.dailyCoursesSkipDays;

            $scope.courseStencil.excludeMonday = data.excludeMonday;
            $scope.courseStencil.excludeTuesday = data.excludeTuesday;
            $scope.courseStencil.excludeWednesday = data.excludeWednesday;
            $scope.courseStencil.excludeThursday = data.excludeThursday;
            $scope.courseStencil.excludeFriday = data.excludeFriday;
            $scope.courseStencil.excludeSaturday = data.excludeSaturday;
            $scope.courseStencil.excludeSunday = data.excludeSunday;

            $scope.courseStencil.notes = data.notes;
            $scope.courseStencil.createCourses = data.createCourses;
            $scope.courseStencil.versionNumber = data.versionNumber;
            $scope.courseStencil.disabled = false;

            //Fields to reset if cloning
            if (resetCourseStencilId == true && $scope.$parent.newVersion != true) {
                $scope.courseStencil.Id = 0;
                $scope.courseStencil.name = "";
                $scope.courseStencil.notes = "";
                $scope.courseStencil.createCourses = false;
                $scope.courseStencil.removeCourses = false;
                $scope.validationMessage = "";
                $scope.courseStencil.versionNumber = 1;
                buildNewStencilName($scope.courseStencil.courseTypeId);
            }

            if ($scope.$parent.newVersion == true)
            {
                $scope.courseStencil.versionNumber++;
                $scope.courseStencil.Id = 0;
                $scope.courseStencil.createCourses = false;
                $scope.courseStencil.removeCourses = false;
            }

        }

        $scope.setCreateCourses = function ($event) {
            $event.currentTarget.disabled = true;
            $event.currentTarget.innerText = "'Creating....'";
            $scope.courseStencilService.setCreateCourses($scope.courseStencil.Id, $scope.courseStencil.userId, $scope.courseStencil.organisationId)
             .then(function (data) {
                 $scope.validationMessage = data.data;
                 $scope.courseStencil.createCourses = true;
                 $scope.showCancel = false;
                 $event.currentTarget.disabled = false;
                 $event.currentTarget.innerText = "Create Courses";
                 //$scope.closeDialog();
             }, function (data) {
                console.log("Can't set create courses");
                $scope.validationMessage = data.ExceptionMessage;
                $event.currentTarget.disabled = false;
                $event.currentTarget.innerText = "Create Courses";

                //$scope.closeDialog();
            });

        }

        function ValidCourseStencil() {
            var today = new Date();
            var earliestStartDate = new Date($scope.courseStencil.earliestStartDate);
            var latestStartDate = new Date($scope.courseStencil.latestStartDate);

            $scope.validationMessage = '';

            if ($scope.courseStencil.name == null) {
                $scope.validationMessage = 'The Name is required.';
            }

            if ($scope.courseStencil.coursePlaces == undefined || isNaN($scope.courseStencil.coursePlaces) || $scope.courseStencil.coursePlaces < 1) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'Course Places must be a number greater than zero.';
            }

            if ($scope.courseStencil.earliestStartDate == null) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'The Earliest Start Date is required.';
            }

            if ($scope.courseStencil.earliestStartDate != null && today.setDate(today.getDate() + 2) > earliestStartDate) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'The Earliest Start Date must be at least 2 days into the future.';
            }

            if ((earliestStartDate >= latestStartDate) && $scope.courseStencil.latestStartDate != null) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'The Earliest End Date must after the Earliest Start Date.';
            }


            // Session time validations
            var validSessionStartTime1 = false;
            var validSessionEndTime1 = false;
            var validSessionStartTime2 = false;
            var validSessionEndTime2 = false;
            var validSessionStartTime3 = false;
            var validSessionEndTime3 = false;
            var reTime = new RegExp("^([0-1][0-9]|2[0-3]):[0-5][0-9]$");
            var reCurrency = new RegExp("(?=.)^(([1-9][0-9]{0,2}(,[0-9]{3})*)|[0-9]+)?(\.[0-9]{1,2})?$");

            // session 1
            if (!String.IsNullOrEmpty($scope.courseStencil.sessionStartTime1)) {
                var match = reTime.exec($scope.courseStencil.sessionStartTime1);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Session Start Time 1 is as invalid time (HH:MM)';
                } else {
                    validSessionStartTime1 = true;
                }
            }

            if (!String.IsNullOrEmpty($scope.courseStencil.sessionEndTime1)) {
                var match = reTime.exec($scope.courseStencil.sessionEndTime1);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Session End Time 1 is as invalid time (HH:MM)';
                } else {
                    validSessionEndTime1 = true;
                }
            }

            if (validSessionStartTime1 && validSessionEndTime1) {
                if ($scope.courseStencil.sessionStartTime1 > $scope.courseStencil.sessionEndTime1) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Sesion End Time 1 has to be after Session Start Time 1.';
                }
            }

            // session 2
            if (!String.IsNullOrEmpty($scope.courseStencil.sessionStartTime2)) {
                var match = reTime.exec($scope.courseStencil.sessionStartTime2);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Session Start Time 2 is as invalid time (HH:MM)';
                } else {
                    validSessionStartTime2 = true;
                }
            }

            if (!String.IsNullOrEmpty($scope.courseStencil.sessionEndTime2)) {
                var match = reTime.exec($scope.courseStencil.sessionEndTime2);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Session End Time 2 is as invalid time (HH:MM)';
                } else {
                    validSessionEndTime2 = true;
                }
            }

            if (validSessionStartTime2 && validSessionEndTime2) {
                if ($scope.courseStencil.sessionStartTime2 > $scope.courseStencil.sessionEndTime2) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Sesion End Time 2 has to be after Session Start Time 2.';
                }
            }

            // session 3
            if (!String.IsNullOrEmpty($scope.courseStencil.sessionStartTime3)) {
                var match = reTime.exec($scope.courseStencil.sessionStartTime3);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Session Start Time 3 is as invalid time (HH:MM)';
                } else {
                    validSessionStartTime3 = true;
                }
            }

            if (!String.IsNullOrEmpty($scope.courseStencil.sessionEndTime3)) {
                var match = reTime.exec($scope.courseStencil.sessionEndTime3);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Session End Time 3 is as invalid time (HH:MM)';
                } else {
                    validSessionEndTime3 = true;
                }
            }

            if (validSessionStartTime3 && validSessionEndTime3) {
                if ($scope.courseStencil.sessionStartTime3 > $scope.courseStencil.sessionEndTime3) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Sesion End Time 3 has to be after Session Start Time 3.';
                }
            }

            if (!$scope.courseStencil.maxCourses == false && (isNaN($scope.courseStencil.maxCourses) || $scope.courseStencil.maxCourses < 1)) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'Maximum courses must be a number greater than zero.';
            }

            if (!$scope.courseStencil.trainersRequired == false && (isNaN($scope.courseStencil.trainersRequired) || $scope.courseStencil.trainersRequired < 1)) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'Trainers required must be a number greater than zero.';
            }

            if (!$scope.courseStencil.reservedPlaces == false && (isNaN($scope.courseStencil.reservedPlaces) || $scope.courseStencil.reservedPlaces < 1)) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'Reserved places must be a number greater than zero.';
            }

            if (!String.IsNullOrEmpty($scope.courseStencil.trainerCost)) {
                var match = reCurrency.exec($scope.courseStencil.trainerCost);
                if (match == null) {
                    $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                    $scope.validationMessage += 'Trainer Cost is as invalid amount.';
                }
            }

            if (!$scope.courseStencil.courseTypeId == true) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'Course Type must be selected.';
            }

            if ($scope.courseStencil.dailyCourses == false && $scope.courseStencil.weeklyCourses == false && $scope.courseStencil.monthlyCourses == false)
            {
                $scope.validationMessage += $scope.validationMessage != "" ? "\n" : "";
                $scope.validationMessage += "Please select daily, weekly or monthly courses";
            }

            //Venue validation, ensures one is selected
            if ($scope.courseStencil.venueId == null) {
                $scope.validationMessage += $scope.validationMessage != '' ? "\n" : '';
                $scope.validationMessage += 'Please select a venue.';
            }

            if ($scope.validationMessage == '')
                return true;
            else
                return false;
        }


        //***************
        // helper methods
        //***************
        String.IsNullOrEmpty = function (value) {
            if (value) {
                if (typeof (value) == 'string') {
                    if (value.length > 0)
                        return false;
                }
                if (value != null)
                    return false;
            }
            return true;
        }

        function GetAvailableCourseStencils() {
            $scope.courseStencilService.getAvailableCourseStencils($scope.courseStencil.organisationId, $scope.courseStencil.userId)
                 .then(function (data) {
                     $scope.courseStencil.listOfCourseStencils = data.data;
                 }, function (data) {
                     console.log("Can't get course stencils");
                 });
        }

        function leftPadString(value, padding) {
            var s = padding + value;
            return s.substr(s.length - padding.length);
        }

        function buildNewStencilName(courseTypeId) {
            var today = new Date();
            var day = today.getDate();
            var month = today.getMonth() + 1;
            var year = today.getFullYear();

            var courseTypeDesc;
            var courseType = findById($scope.courseStencil.listOfCourseTypes, courseTypeId);
            if (courseType == null)
                courseTypeDesc = ''
            else
                var courseTypeDesc = courseType.Description;

            $scope.courseStencil.name = courseTypeDesc + " " + today.getFullYear() + "-" + leftPadString(month, "00") + "-" + leftPadString(day, "00");
        }

        function findById(source, id) {
            for (var i = 0; i < source.length; i++) {
                if (source[i].Id === id) {
                    return source[i];
                }
            }
            throw "Couldn't find object with id: " + id;
        }

        $scope.closeDialog = function () {
            ModalService.closeCurrentModal("courseStencilModal");
        }
    }

}) ();