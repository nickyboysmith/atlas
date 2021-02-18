(function () {
    'use strict';

    angular
        .module('app')
        .controller('addCourseCtrl', addCourseCtrl);

    addCourseCtrl.$inject = [
        '$scope',
        '$location',
        '$window',
        'DateFactory',
        '$http',
        '$filter',
        'CourseService',
        'DorsService',
        'activeUserProfile',
        'ModalService',
        'CourseTypeService',
        'OrganisationSelfConfigurationService'
    ];


    function addCourseCtrl(
        $scope,
        $location,
        $window,
        DateFactory,
        $http,
        $filter,
        CourseService,
        DorsService,
        activeUserProfile,
        ModalService,
        CourseTypeService,
        OrganisationSelfConfigurationService
        )
    {
        $scope.defaultErrorMessage = "An error occurred please try again.";
        $scope.validationMessageAdditionalInformation = '';
        $scope.displayCalendar = false;
        $scope.displayCalendar2 = false;
        $scope.course = {};
        $scope.courseService = CourseService;
        $scope.disableDORSCheckbox = false;
        $scope.showDORSCheckbox = true;
        $scope.course.TheoryCourse = true;
        $scope.modalService = ModalService;
        $scope.theoryDisabled = false;
        $scope.practicalDisabled = false;
        $scope.MaxPlaces = -1;  // -1 means no limit(@TODO: ask Rob?)
        $scope.course.NumberOfCourseDates = 2; //Default Number of Dates
        $scope.MinNumberOfCourseDates = 2; //Default Number of Dates
        $scope.MaxNumberOfCourseDates = 10; //Default Number of Dates

        $scope.course.MultiDatesAndTimes = [];
        for (var i = 0; i < $scope.MaxNumberOfCourseDates; i++) {
            var EmptyDateAndTime = { Indx: i, StartDate: '', EndDate: '', Session: '', StartTime: '', EndTime: '', DisplayCalendar: false };
            //EmptyDateAndTime.Indx = i;
            $scope.course.MultiDatesAndTimes.push(EmptyDateAndTime);
        }


        /**
            * Initialize
            */
        $scope.orgSystemConfig = {};

        /**
         * Check if user is Systems Admin
         * 
         */
        $scope.isSystemAdmin = activeUserProfile.IsSystemAdmin;

        /**
         * Check if user is Systems Admin
         * 
         */
        $scope.isOrganisationAdmin = activeUserProfile.IsOrganisationAdmin;

        /**
         * To show info box under course type
         * Set default to false
         */
        $scope.selectedCourseType = {};
        $scope.courseTypeInfo = "";
        $scope.showCourseTypeAdditionalInformation = false;

        /**
         * To show info box under venue
         * Set default to false
         */
        $scope.selectedVenue = {};
        $scope.venueInfo = "";
        $scope.showVenueAdditionalInformation = false;

        /**
         * 
         */
        $scope.course.courseDorsCourse = false;
        $scope.showDORSCheckbox = false;
        $scope.disableDORSCheckbox = true;

        $scope.NthNumber = function (theNumber) {
            var nthNumber = '' + theNumber + 'th';
            if (theNumber === 1) {
                nthNumber = theNumber + 'st';
            }
            if (theNumber === 2) {
                nthNumber = theNumber + 'nd';
            }
            if (theNumber === 3) {
                nthNumber = theNumber + 'rd';
            }
            return nthNumber;
        }

        $scope.toggleCalendar = function (calendarIndex) {
            if (calendarIndex === undefined) {
                //Not MultiDate Calendar
                $scope.displayCalendar = !$scope.displayCalendar;
            } else {
                $scope.moveCalendarToPosition(calendarIndex);
                $scope.course.MultiDatesAndTimes[calendarIndex].DisplayCalendar = !$scope.course.MultiDatesAndTimes[calendarIndex].DisplayCalendar;
            }
        }

        $scope.hideCalendar = function (calendarIndex) {
            if (calendarIndex === undefined) {
                //Not MultiDate Calendar
                $scope.displayCalendar = false;
            } else {
                $scope.course.MultiDatesAndTimes[calendarIndex].DisplayCalendar = false;
            }
        }

        $scope.moveCalendarToPosition = function (calendarIndex) {
            $(".Calendar" +calendarIndex).position({ my: "left top", at: "left bottom", of: ".StartDate" + calendarIndex});
        }

        Date.prototype.addDays = function (num) {
            var value = this.valueOf();
            value += 86400000 * num;
            return new Date(value);
        }

        $scope.CheckDateEntries = function () {
            var previousDate = '~';
            var firstDate = '';
            var lastDate = '';
            for (var i = 0; i < $scope.MaxNumberOfCourseDates; i++) {
                //{ Indx: i, StartDate: '', EndDate: '', Session: '', StartTime: '', EndTime: '', DisplayCalendar: false };
                if (previousDate === '' && $scope.course.MultiDatesAndTimes[i].StartDate !== '' && i > 0) {
                    //In Case there is a Gap
                    previousDate = $scope.course.MultiDatesAndTimes[i].StartDate;
                    $scope.course.MultiDatesAndTimes[i -1].StartDate = $scope.course.MultiDatesAndTimes[i].StartDate;
                }
                if (i > 0 && $scope.course.MultiDatesAndTimes[i].StartDate !== '') {
                    if (Date.parse($scope.course.MultiDatesAndTimes[i].StartDate) <= Date.parse($scope.course.MultiDatesAndTimes[i -1].StartDate)) {
                        var stDate = Date.parse($scope.course.MultiDatesAndTimes[i -1].StartDate);
                        $scope.course.MultiDatesAndTimes[i].StartDate = (new Date(stDate +24*60*60*1000)).toString();
                    }
                }
                if ($scope.course.MultiDatesAndTimes[i].StartDate !== '' && ($scope.course.MultiDatesAndTimes[i].Session === null || $scope.course.MultiDatesAndTimes[i].Session === '')) {
                    $scope.course.MultiDatesAndTimes[i].Session = $scope.getSessionObject('AM');
                    $scope.MultiDateSessionChanged(i);
                }
                $scope.course.MultiDatesAndTimes[i].StartDate = $scope.course.MultiDatesAndTimes[i].StartDate.replace(' 00:00:00 GMT+0000 (GMT Standard Time)', '').trim();
                $scope.course.MultiDatesAndTimes[i].EndDate = $scope.course.MultiDatesAndTimes[i].StartDate;
                previousDate = $scope.course.MultiDatesAndTimes[i].StartDate;
            }
            $scope.course.courseDateStart = $scope.course.MultiDatesAndTimes[0].StartDate + ' ' + $scope.course.MultiDatesAndTimes[0].StartTime;
            $scope.course.courseDateEnd = $scope.course.MultiDatesAndTimes[$scope.course.NumberOfCourseDates - 1].StartDate
                                                + ' ' + $scope.course.MultiDatesAndTimes[$scope.course.NumberOfCourseDates - 1].EndTime;
            $scope.course.courseTimeStart = $scope.course.MultiDatesAndTimes[0].StartTime;
            $scope.course.courseTimeEnd = $scope.course.MultiDatesAndTimes[$scope.course.NumberOfCourseDates -1].EndTime;
        }

        $scope.getSessionObject = function (sessionTitle) {
            var trSess = null;
            if ($scope.course.courseTrainingSessions === undefined || $scope.course.courseTrainingSessions === null) {
                $scope.courseService.getTrainingSessions();
            }
            angular.forEach($scope.course.courseTrainingSessions, function (trainingSession, key) {
                if (trainingSession.SessionTitle === sessionTitle) {
                    trSess = trainingSession;
                    return true;
                }
            });
            return trSess;
        }

        $scope.SessionChanged = function () {
            if ($scope.course.selectedTrainingSession !== null && $scope.course.selectedTrainingSession !== undefined) {
                $scope.course.courseTimeStart = $scope.course.selectedTrainingSession.SessionStartTime;
                $scope.course.courseTimeEnd = $scope.course.selectedTrainingSession.SessionEndTime;
            }

        }

        $scope.MultiDateSessionChanged = function (index) {
            if ($scope.course.MultiDatesAndTimes[index].Session !== null && $scope.course.MultiDatesAndTimes[index].Session !== '') {
                $scope.course.MultiDatesAndTimes[index].StartTime = $scope.course.MultiDatesAndTimes[index].Session.SessionStartTime;
                $scope.course.MultiDatesAndTimes[index].EndTime = $scope.course.MultiDatesAndTimes[index].Session.SessionEndTime;
            }
        }

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.formatDate = function (date) {

            return DateFactory.formatDateddMONyyyy(date);
        }


        //Start Get Course Options
        $scope.getCourseOptions = function () {

            $scope.course.userId = activeUserProfile.UserId;
            $scope.course.organisationId = activeUserProfile.selectedOrganisation.Id
            $scope.course.courseId = 0;


            $http({
                url: apiServer + "/course",
                method: "GET",
                params: {
                    userId: $scope.course.userId,
                    courseId: $scope.course.courseId,
                    organisationId: $scope.course.organisationId,
                    //cloneId: 0263687
                    cloneId: 0
                },
            })
            .then(function (data) {
                $scope.course.categoryId = data.categoryId;
                $scope.course.courseTypeId = data.courseTypeId;
                $scope.course.languageId = data.languageId;
                $scope.course.venueId = data.venueId;
                $scope.course.courseHasInterpreter = data.courseHasInterpreter;
                $scope.course.courseUpdateDorsAttendance = data.courseUpdateDorsAttendance;
                $scope.course.courseAttendanceByTrainer = data.courseAttendanceByTrainer;
                $scope.course.courseManualCarsOnly = data.courseManualCarsOnly;
                $scope.course.courseRestrictOnlineBookingManualOnly = data.courseRestrictOnlineBookingManualOnly;
                $scope.course.multiday = data.courseMultiDay;

                if (typeof (data.courseDateStart) === 'undefined' || data.courseDateStart === null)
                    $scope.course.courseDateStart = null;
                else $scope.course.courseDateStart = data.courseDateStart.substring(0, 10);

                if (typeof (data.courseDateEnd) === 'undefined' || data.courseDateEnd === null)
                    $scope.course.courseDateEnd = null;
                else $scope.course.courseDateEnd = data.courseDateEnd.substring(0, 10);

                //$scope.course.courseDateStart = data.courseDateStart.substring(0,10);
                //$scope.course.courseDateEnd = data.courseDateEnd.substring(0, 10);

                $scope.course.courseTimeStart = data.courseTimeStart;
                $scope.course.courseTimeEnd = data.courseTimeEnd;
                $scope.course.trainersRequired = data.trainersRequired;
            }, function (response) {
                $scope.validationMessage = $scope.defaultErrorMessage;
                if (response.data) {
                    if (response.data.ExceptionMessage) {
                        $scope.validationMessage = response.data.ExceptionMessage;
                    }
                    else if (response.data.Message) {
                        $scope.validationMessage = response.data.Message;
                    }
                    else {
                        $scope.validationMessage = $scope.defaultErrorMessage;
                    }
                }
                else {
                    $scope.validationMessage = $scope.defaultErrorMessage;
                }
            });


            /**
            * Get the Venues associated with the organisation
            */
            $scope.courseService.getRelatedVenues($scope.course.organisationId)
                .then(function (data) {
                    $scope.course.courseVenueOptions = data;
                }, function (data) {
                    console.log("Can't get related venues");
                });

            /**
            * Get the Course Types associated with the organisation
            */

            $scope.courseService.getRelatedCourseTypes($scope.course.organisationId)
                    .then(function (data) {
                        $scope.course.courseTypeOptions = data;
                        $scope.course.courseTypeId = $scope.course.courseTypeOptions[0].Id;
                    }, function (data) {
                        console.log("Can't get related course types");
                    });


            /**
                * Get the Course Categories associated with the organisation
                */

            $scope.courseService.getRelatedCourseCategories($scope.course.organisationId, $scope.course.userId)
                .then(function (data) {
                    $scope.course.courseCategoryOptions = data;
                    //$scope.course.selectedCourseCategory = $scope.course.courseCategoryOptions[0];
                }, function (data) {
                    console.log("Can't get related course categories");
                });

            /**
            * Get the Course Types associated with the organisation
            */

            $scope.courseService.getRelatedOrganisationLanguages($scope.course.organisationId)
                .then(function (data) {
                    $scope.course.courseLanguageOptions = data;
                }, function (data) {
                    console.log("Can't get related language options");
                });

            /**
            * Get the System Configuration associated with the organisation
            */
            $scope.courseService.getOrganisationSystemConfiguration($scope.course.organisationId)
            .then(
                function (data) {

                    if (data) {
                        $scope.orgSystemConfig.DORSFeatureEnabled = data.DORSFeatureEnabled;
                        $scope.orgSystemConfig.ShowCourseLanguage = data.ShowCourseLanguage;
                        $scope.orgSystemConfig.MultiDayCoursesAllowed = data.MultiDayCoursesAllowed;
                    }

                },
                function (data) {
                    $scope.orgSystemConfig.ShowLanguage = false;
                    console.log("Can't get organisation system configuration");
                    console.log(reponse);
                }
            );


            /**
            * Get the Training Sessions
            */

            $scope.courseService.getTrainingSessions()
                .then(function (data) {
                    $scope.course.courseTrainingSessions = data;
                    //$scope.course.selectedTrainingSession = $scope.course.courseTrainingSessions[0];
                    $scope.course.selectedTrainingSession = null;
                }, function (data) {
                    console.log("Can't get the training sessions");
                }
            );
        }
        //End Get Course Options

        /**
            * Set the manual car course restriction
            * Go to the OrganisationSelfConfiguration table
            * To check whether or not the manual course restriction is set
            */
        OrganisationSelfConfigurationService.GetByOrganisation(
            activeUserProfile.selectedOrganisation.Id
        )
        .then(
            function (response) {
                if (response.data === null) {
                    $scope.orgSystemConfig.manualCarCourseRestriction = false;
            }
            else {
                $scope.orgSystemConfig.ShowTrainerCosts = response.data.ShowTrainerCosts;
                $scope.orgSystemConfig.manualCarCourseRestriction = response.data.ShowManulCarCourseRestriction;
         }
            },
            function (reason) {
                //@TODO: Check to see if this should be set to false if org isnt in the table
                $scope.orgSystemConfig.manualCarCourseRestriction = false;
                console.log(reason);
        }
        )

        $scope.onlyNumbers = function (text) {
            var numbers = true;
            numbers = !isNaN(parseFloat(text)) && isFinite(text);
            return numbers;
        }

        $scope.addCourse = function (closeDialog) {

            if ($scope.course) {

                $scope.course.operation = "ADD";
                
                if ($scope.course.selectedCourseCategory) {
                    $scope.course.categoryId = $scope.course.selectedCourseCategory.Id;
                }

                if (!$scope.course.courseTypeId > 0) {
                    $scope.validationMessage = "Please select a course type.";
                    return false;
                }

                if(!$scope.onlyNumbers($scope.course.coursePlaces)) {
                    $scope.validationMessage = "Please only use numbers in the Places field.";
                    return false;
                }

                if ($scope.course.selectedTrainingSession) {
                    $scope.course.sessionNumber = $scope.course.selectedTrainingSession.SessionNumber;
                }
                else {
                    $scope.course.sessionNumber = null;
                }
                
                if ($scope.course.multiday === false || !angular.isDefined($scope.course.multiday)) {
                    if (new Date() > new Date($scope.course.courseDateStart)) {
                        $scope.validationMessage = 'Please select a course start date in the future.';
                        return false;
                    }
                    else {
                        // Single Session, Set the CourseDateEnd to the same as the CourseDateStart
                        $scope.course.courseDateEnd = $scope.course.courseDateStart;
                    }
                }

                if ($scope.course.multiday === true) {
                    if (isNaN($scope.course.NumberOfCourseDates) || $scope.course.NumberOfCourseDates < 2) {
                        $scope.validationMessage = 'The number of Course Dates must be numeric and must be a greater than one.';
                        return false;
                    }
                    // Now Validate Each Date and Session and Times

                    var validDateCheck = true;
                    var validDateCheckMessage = '';
                    var collectionNumber = 0;
                    angular.forEach($scope.course.MultiDatesAndTimes, function (dateSessionTime, key) {
                        collectionNumber = dateSessionTime.Indx +1;
                        if (validDateCheck === true && collectionNumber <= $scope.course.NumberOfCourseDates) {
                            //NB When Checking for Invalid Dates mus use "== 'Invalid Date'" ... i.e. Two Equals
                            if (new Date(dateSessionTime.StartDate) === 'Invalid Date') {
                                validDateCheck = false;
                                validDateCheckMessage = 'The ' + $scope.NthNumber(collectionNumber) + ' Date is Invalid. Please correct.';
                                return false;
                            }
                            if (dateSessionTime.Session === '' || dateSessionTime.Session === null) {
                                validDateCheck = false;
                                validDateCheckMessage = 'The ' + $scope.NthNumber(collectionNumber) + ' Session is Invalid. Please correct.';
                                return false;
                            }
                            if (new Date('01/01/01 ' + dateSessionTime.StartTime) === 'Invalid Date' || dateSessionTime.StartTime === '') {
                                validDateCheck = false;
                                validDateCheckMessage = 'The ' + $scope.NthNumber(collectionNumber) + ' Start Time is Invalid. Please correct.';
                                return false;
                            }
                            if (new Date('01/01/01 ' + dateSessionTime.EndTime) === 'Invalid Date' || dateSessionTime.EndTime === '') {
                                validDateCheck = false;
                                validDateCheckMessage = 'The ' + $scope.NthNumber(collectionNumber) + ' End Time is Invalid. Please correct.';
                                return false;
                            }
                            if (new Date('01/01/01 ' + dateSessionTime.StartTime) >= new Date('01/01/01 ' +dateSessionTime.EndTime)) {
                                validDateCheck = false;
                                validDateCheckMessage = 'The ' + $scope.NthNumber(collectionNumber) + ' Start Time must be before End Time. Please correct.';
                                return false;
                            }
                        }
                    });
                    if (validDateCheck === false) {
                        $scope.validationMessage = validDateCheckMessage;
                        return false;
                    }

                }

                $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

                $http.post(apiServer + '/course', $scope.course)
                .then(function (response, status, headers, config) {

                    $scope.showSuccessFader = true;

                    if ($scope.isDorsCourseChecked() && $scope.course.notifyDORS === true) {
                        var courseId = response.data.Id;
                        DorsService.addCourse(courseId)
                            .then(
                                function successCallback(response) {
                                    $scope.validationMessage = "Course added successfully.";
                                    if (closeDialog === true) {
                                        $('button.close').trigger('click');
                                }
                        },
                                function errorCallback(response) {
                                    $scope.validationMessage = response.data.ExceptionMessage;
                        }
                            );
                    }
                    else {
                        $scope.validationMessage = "Course added successfully.";
                        if (closeDialog === true) {
                            $('button.close').trigger('click');
                        }
                    }
                },
                function (response, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.showErrorFader = true;
                    if (response.data) {
                        if (response.data.ExceptionMessage) {
                            $scope.validationMessage = response.data.ExceptionMessage;
                        }
                        else if (response.data.Message) {
                            $scope.validationMessage = response.data.Message;
                        }
                        else {
                            $scope.validationMessage = $scope.defaultErrorMessage;
                    }
                    }
                    else {
                        $scope.validationMessage = $scope.defaultErrorMessage;
                    }
                }
                );
            } else {
                $scope.validationMessage = $scope.defaultErrorMessage;
                $scope.validationMessageAdditionalInformation = 'Error In: "$scope.addCourse". Invalid "$scope.course".';
            }
        }
        
        $scope.isMultiDayCoursesAllowed = function () {

            if ($scope.orgSystemConfig.MultiDayCoursesAllowed) {
                if ($scope.orgSystemConfig.MultiDayCoursesAllowed === true) {
                    return true;
                }
                else {
                    return false;
                }
            } else {
                return false;
            }
        }


        $scope.isDorsFeatureEnabled = function () {

            if ($scope.orgSystemConfig.DORSFeatureEnabled) {
                if ($scope.orgSystemConfig.DORSFeatureEnabled === true) {
                    return true;
                } else {
                return false;
                }
            } else {
                return false;
            }
        }

        $scope.isDorsCourseChecked = function () {

            if ($scope.orgSystemConfig.DORSFeatureEnabled) {
                if ($scope.orgSystemConfig.DORSFeatureEnabled === true
                    && $scope.course.courseDorsCourse === true) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        /**
            * Show the additional info for the course type
            */
        $scope.courseTypeSelected = function (theCourseType) {

            if ($.isEmptyObject(theCourseType))
            {
                return false;
            }

            /**
             * Set the venue Id on the scope
             */
            $scope.course.courseTypeId = theCourseType.Id;

            /**
             * Check to see if the additional info is empty
             * If it isn't then set property on scope
             */
            if (theCourseType.AdditionalInformation !== null) {
                $scope.showCourseTypeAdditionalInformation = true;
                $scope.courseTypeInfo = theCourseType.AdditionalInformation;
            }
             else {
                 $scope.showCourseTypeAdditionalInformation = false;
            }

            CourseTypeService.getCourseType(theCourseType.Id)
                .then(function (data) {

                    console.log(data.DORSOnly);
                    var courseType = data;
                    if(courseType.DORSOnly !== null && courseType.DORSOnly === true) {
                        $scope.course.courseDorsCourse = true;
                        $scope.disableDORSCheckbox = true;
                        $scope.showDORSCheckbox = true;
                    }
                    else {
                        $scope.course.courseDorsCourse = false;
                        $scope.showDORSCheckbox = false;
                        $scope.disableDORSCheckbox = true;
                    }

                    // 
                    if (courseType.MaxTheoryTrainers === 0) {
                        $scope.course.PracticalCourse = true;
                        $scope.course.TheoryCourse = false;
                        $scope.theoryDisabled = true;
                        $scope.practicalDisabled = true;
                    }
                    else if (courseType.MaxPracticalTrainers === 0) {
                        $scope.course.PracticalCourse = false;
                        $scope.course.TheoryCourse = true;
                        $scope.theoryDisabled = true;
                        $scope.practicalDisabled = true;
                    }

                    if (courseType.MinTheoryTrainers > 0) {
                        $scope.course.TheoryCourse = true;
                        $scope.theoryDisabled = true;
                    }

                    if (courseType.MinPracticalTrainers > 0) {
                        $scope.course.PracticalCourse = true;
                        $scope.practicalDisabled = true;
                    }

                    if (courseType.MaxPlaces > 0) {
                        $scope.course.coursePlaces = courseType.MaxPlaces;
                        $scope.MaxPlaces = courseType.MaxPlaces;
                    }

                    /**
                     * 
                     */
                    CourseService.getCourseReference($scope.course.organisationId, courseType.Code)
                        .then(function (data) {
                            $scope.course.courseReference = data;
                        }, function () {
                        });
                }, function(data, status) {
                })
        }

        /**
            * Show additional info for venue
            */
        $scope.selectCourseVenue = function (theVenue) {

            if ($.isEmptyObject(theVenue)) {
                return false;
            }

            /**
             * Set the venue Id on the scope
             */
            $scope.course.venueId = theVenue.Id;

            /**
             * Check to see if the additional info is empty
             * If it isn't then set property on scope
             */
            if  (theVenue.AdditionalInformation !== "") {
                $scope.showVenueAdditionalInformation = true;
                $scope.venueInfo = theVenue.AdditionalInformation;
             } else {
                 $scope.showVenueAdditionalInformation = false;
            }
        };

        $scope.notOverMaxPlaces = function (currentPlaces) {
            if (currentPlaces > $scope.MaxPlaces) {
                $scope.course.coursePlaces = $scope.MaxPlaces;
                $scope.validationMessage = "This course type has a maximum of " +$scope.MaxPlaces + " places.";
            }
            else {
                $scope.validationMessage = "";
            }
        }

        $scope.getCourseOptions();
    }
})();