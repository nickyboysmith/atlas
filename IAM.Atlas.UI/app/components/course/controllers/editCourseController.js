(function () {
    'use strict';

    angular
        .module('app')
        .controller('editCourseCtrl', ['$scope', '$timeout', '$location', '$window', '$http', '$filter', 'CourseService', 'UserService', 'DorsService', 'CourseTrainerFactory', 'activeUserProfile', 'DateFactory', 'CourseTrainerService', 'ModalService', editCourseCtrl]);

    function editCourseCtrl($scope, $timeout, $location, $window, $http, $filter, CourseService, UserService, DorsService, CourseTrainerFactory, activeUserProfile, DateFactory, CourseTrainerService, ModalService) {

        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;
        $scope.displayCalendar = false;
        $scope.displayCalendar2 = false;
        $scope.displayCalendar3 = false;
        $scope.course = {};
        $scope.currentCourse = {};
        $scope.client = {};
        $scope.courseService = CourseService;
        $scope.userService = UserService;
        $scope.documentOrigin = "course";

        $scope.orgSystemConfig = new Object();
       
        $scope.showingCourseClients = false;    // are we showing the course client tab?
        $scope.showingCourseHistory = false;    // are we showing the course history tab?

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        
        $scope.disableCancelButton = true;
        $scope.showCancelButton = false;
        $scope.cancelButtonTitle = "Click to Cancel this Course";
        
        $scope.course.NumberOfCourseDates = 2; //Default Number of Dates
        $scope.MinNumberOfCourseDates = 2; //Default Number of Dates
        $scope.MaxNumberOfCourseDates = 10; //Default Number of Dates

        $scope.course.MultiDatesAndTimes = [];
        for (var i = 0; i < $scope.MaxNumberOfCourseDates; i++) {
            var EmptyDateAndTime = { Indx: i, StartDate: '', EndDate: '', Session: '', StartTime: '', EndTime: '', DisplayCalendar: false };
            $scope.course.MultiDatesAndTimes.push(EmptyDateAndTime);
        }



        $scope.isAdmin = (activeUserProfile.IsSystemAdmin || activeUserProfile.IsOrganisationAdmin);
        $scope.IsSystemAdmin = activeUserProfile.IsSystemAdmin;
        $scope.IsOrganisationAdmin = activeUserProfile.IsOrganisationAdmin;

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
                if ($scope.displayCalendar) {
                    $scope.displayCalendar2 = false;
                    $scope.displayCalendar3 = false;
                }
            } else {
                $scope.moveCalendarToPosition(calendarIndex);
                $scope.course.MultiDatesAndTimes[calendarIndex].DisplayCalendar = !$scope.course.MultiDatesAndTimes[calendarIndex].DisplayCalendar;
            }
        }

        $scope.toggleCalendar2 = function () {
            $scope.displayCalendar2 = !$scope.displayCalendar2;
            if ($scope.displayCalendar2) {
                $scope.displayCalendar = false;
                $scope.displayCalendar3 = false;
            }
        }

        $scope.toggleCalendar3 = function () {
            $scope.displayCalendar3 = !$scope.displayCalendar3;
            if ($scope.displayCalendar3) {
                $scope.displayCalendar2 = false;
                $scope.displayCalendar1 = false;
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
            $(".Calendar" + calendarIndex).position({ my: "left top", at: "left bottom", of: ".StartDate" + calendarIndex});
        }

        /**
        * Method to open the add course note modal
        */
        $scope.addCourseNoteModal = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Add course note",
                    cssClass: "courseNoteModal",
                    filePath: "/app/components/course/addNote.html",
                    controllerName: "addCourseNoteCtrl"
            });
        };

        $scope.CheckDateEntries = function () {
            var previousDate = '~';
            var firstDate = '';
            var lastDate = '';
            for (var i = 0; i < $scope.MaxNumberOfCourseDates; i++) {
                //{ Indx: i, StartDate: '', EndDate: '', Session: '', StartTime: '', EndTime: '', DisplayCalendar: false };
                if (previousDate === '' && $scope.course.MultiDatesAndTimes[i].StartDate !== '' && i > 0) {
                    //In Case there is a Gap
                    previousDate = $scope.course.MultiDatesAndTimes[i].StartDate;
                    $scope.course.MultiDatesAndTimes[i - 1].StartDate = $scope.course.MultiDatesAndTimes[i].StartDate;
                }
                if (i > 0 && $scope.course.MultiDatesAndTimes[i].StartDate !== '') {
                    if (Date.parse($scope.course.MultiDatesAndTimes[i].StartDate) <= Date.parse($scope.course.MultiDatesAndTimes[i - 1].StartDate)) {
                        var stDate = Date.parse($scope.course.MultiDatesAndTimes[i - 1].StartDate);
                        $scope.course.MultiDatesAndTimes[i].StartDate = (new Date(stDate + 24 * 60 * 60 * 1000)).toString();
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
            $scope.course.courseTimeEnd = $scope.course.MultiDatesAndTimes[$scope.course.NumberOfCourseDates - 1].EndTime;
        }
        
        $scope.populateTrainingSessions = function () {
            if ($scope.course.courseTrainingSessions == undefined || $scope.course.courseTrainingSessions == null) {
                $scope.courseService.getTrainingSessions()
                .then(function (data) {
                    $scope.course.courseTrainingSessions = data;
                    //$scope.course.selectedTrainingSession = $scope.course.courseTrainingSessions[0];

                }, function (data) {
                    $scope.course.courseTrainingSessions = [];
                    console.log("Can't get the training sessions");
                });

            }
        }

        $scope.getSessionObject = function (sessionTitleOrNumber) {
            var trSess = null;
            if ($scope.course.courseTrainingSessions === undefined || $scope.course.courseTrainingSessions === null) {
                $scope.populateTrainingSessions();
            }
            angular.forEach($scope.course.courseTrainingSessions, function (trainingSession, key) {
                if (trainingSession.SessionTitle == sessionTitleOrNumber || trainingSession.SessionNumber == sessionTitleOrNumber) {
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


        $scope.getCourseOptions = function () {

            $scope.course.userId = $scope.$parent.userId;
            $scope.course.courseId = $scope.$parent.courseId;
            $scope.course.organisationId = $scope.$parent.organisationId;

            $scope.courseDataPromise = $http({
                url: apiServer + "/course",
                method: "GET",
                params: {
                    userId: $scope.course.userId,
                    courseId: $scope.course.courseId,
                    organisationId: $scope.course.organisationId,
                cloneId: 0
                },
            })
            .then(function (response) {

                var data = response.data;

                $scope.course.isAdmin = false;

                $scope.populateTrainingSessions();

                $scope.userService.checkSystemAdminUser($scope.course.userId)
                    .then(function (response) {
                        $scope.course.isAdmin = JSON.parse(response);

                        $scope.userService.checkOrganisationAdminUser($scope.course.userId, $scope.course.organisationId)
                        .then(function (response) {
                            $scope.course.isOrganisationAdmin = JSON.parse(response);
                        }, function (data) {
                            $scope.validationMessage = "An error occurred, please contact support.";
                    });

                    $scope.showCancelButton = ($scope.course.isAdmin || $scope.course.isOrganisationAdmin) && !$scope.course.courseCancelled;
                });

                $scope.course = angular.extend($scope.course, response.data);
                $scope.course.courseDateStart = $filter('date') ($scope.parseDate(data.courseDateStart), 'dd-MMM-yyyy');
                $scope.course.courseDateEnd = $filter('date') ($scope.parseDate(data.courseDateEnd), 'dd-MMM-yyyy');
                //$scope.course.courseDateStart = DateFactory.formatDateddMONyyyy($scope.parseDate(data.courseDateStart));
                //$scope.course.courseDateEnd = DateFactory.formatDateddMONyyyy($scope.parseDate(data.courseDateEnd));
                $scope.course.lastBookingDate = $filter('date')(data.lastBookingDate, "dd-MMM-yyyy");
                $scope.course.available = data.courseAvailable;

                $scope.course.categoryId = data.categoryId;

                $scope.course.isCourseLocked = data.isCourseLocked;
                $scope.course.isCourseProfileLocked = data.isCourseProfileLocked;
                $scope.course.multiday = data.courseMultiDay;

                //$scope.course.courseId = data.Id;
                //$scope.course.categoryId = data.categoryId;
                //$scope.course.courseTypeId = data.courseTypeId;
                //$scope.course.languageId = data.languageId;
                //$scope.course.venueId = data.venueId;
                //$scope.course.coursePlaces = data.coursePlaces;
                //$scope.course.courseReserved = data.courseReserved;
                //$scope.course.courseUpdateDorsAttendance = data.courseUpdateDorsAttendance;
                //$scope.course.courseAttendanceByTrainer = data.courseAttendanceByTrainer;
                //$scope.course.courseManualCarsOnly = data.courseManualCarsOnly;
                //$scope.course.courseRestrictOnlineBookingManualOnly = data.courseRestrictOnlineBookingManualOnly;
                //$scope.course.courseMultiDay = data.courseMultiDay;
                //$scope.course.courseDateStart = data.courseDateStart.substring(0, 10);
                //$scope.course.courseDateEnd = data.courseDateEnd.substring(0, 10);
                //$scope.course.courseTimeStart = data.courseTimeStart;
                //$scope.course.courseTimeEnd = data.courseTimeEnd;
                //$scope.course.trainersRequired = data.trainersRequired;
                //$scope.course.courseAvailable = data.courseAvailable;
                //$scope.course.courseReference = data.courseReference;
                //$scope.course.courseTrainers = data.courseTrainers;
                //$scope.course.courseNotes = data.courseNotes;

                $scope.notes = $scope.noteText();
                $scope.documents = $filter('filter') ($scope.course.documents, {
                    MarkedForDeletion: false
                });

                $scope.course.TheoryCourse = data.TheoryCourse;
                $scope.course.PracticalCourse = data.PracticalCourse;
                $scope.course.dorsCourse = data.courseDorsCourse;


                if ($scope.course.courseCancelled) {
                    $scope.cancelledMessage = "Course Cancelled";
                }

                /**
                * Get the Course Categories associated with the organisation
                */
                //$scope.courseService.getRelatedCourseCategories($scope.course.organisationId, $scope.course.userId)
                //    .then(function (data) {
                //        $scope.course.courseCategoryOptions = data;

                //        var findCategoryInObject = CourseTrainerFactory.find($scope.course.courseCategoryOptions, $scope.course.categoryId);
                //        $scope.course.selectedCourseCategory = $scope.course.courseCategoryOptions[findCategoryInObject];
                //    }, function (data) {
                //        $scope.course.courseCategoryOptions = [];
                //        console.log("Can't get related course categories");
                //    });
                $scope.courseService.getCourseTypeCourseTypeCategories($scope.course.courseTypeId, $scope.course.userId)
                    .then(function (data) {
                        $scope.course.courseCategoryOptions = data;

                        var findCategoryInObject = CourseTrainerFactory.find($scope.course.courseCategoryOptions, $scope.course.categoryId);
                        $scope.course.selectedCourseCategory = $scope.course.courseCategoryOptions[findCategoryInObject];
                    }, function (data) {
                        $scope.course.courseCategoryOptions =[];
                        console.log("Can't get related course categories");
                    });


                /**
                * Get the Course Types associated with the organisation
                */
                $scope.courseService.getRelatedOrganisationLanguages($scope.course.organisationId)
                        .then(function (data) {
                            $scope.course.courseLanguageOptions = data;
                        }, function (data) {
                            $scope.course.courseLanguageOptions =[];
                            console.log("Can't get related language options");
                });

                /**
                * Get the Training Sessions
                */
                $scope.populateTrainingSessions();

                var multiDatesIndex = 0;
                angular.forEach(data.courseDates, function (courseDate, key) {
                    /*
                                                            Id = cd.Id,
                                                            CourseId = cd.CourseId,
                                                            DateStart = cd.DateStart,
                                                            DateEnd = cd.DateEnd,
                                                            Available = cd.Available,
                                                            AttendanceUpdated = cd.AttendanceUpdated,
                                                            AttendanceVerified = cd.AttendanceVerified,
                                                            AssociatedSessionNumber = cd.AssociatedSessionNumber*/
                    //var EmptyDateAndTime = { Indx: i, StartDate: '', EndDate: '', Session: '', StartTime: '', EndTime: '', DisplayCalendar: false };
                    $scope.course.MultiDatesAndTimes[multiDatesIndex].Indx = multiDatesIndex;
                    $scope.course.MultiDatesAndTimes[multiDatesIndex].StartDate = $scope.formatDate(Date.parse(courseDate.DateStart));
                    $scope.course.MultiDatesAndTimes[multiDatesIndex].EndDate = $scope.formatDate(Date.parse(courseDate.DateEnd));
                    $scope.course.MultiDatesAndTimes[multiDatesIndex].StartTime = $scope.formatTime(Date.parse(courseDate.DateStart));
                    $scope.course.MultiDatesAndTimes[multiDatesIndex].EndTime = $scope.formatTime(Date.parse(courseDate.DateEnd));
                    $scope.course.MultiDatesAndTimes[multiDatesIndex].Session = $scope.getSessionObject(courseDate.AssociatedSessionNumber);
                    multiDatesIndex = multiDatesIndex +1;
                });
                $scope.course.NumberOfCourseDates = multiDatesIndex;

            }, function (data) {
                $scope.validationMessage = "An error occurred, please contact support.";
            });


            $scope.courseDataPromise.then(function () {

                /**
                * Get the Venues associated with the organisation
                */
                $scope.courseService.getRelatedVenuesCheckDors($scope.course.organisationId, $scope.course.dorsCourse)
                .then(function (data) {
                    $scope.course.courseVenueOptions = data;
                }, function (data) {
                    $scope.course.courseVenueOptions =[];
                    console.log("Can't get related venues");
                });


                /**
                * Get the Course Types associated with the organisation
                */
                $scope.courseService.getRelatedCourseTypes($scope.course.organisationId)
                .then(function (data) {
                    $scope.course.courseTypeOptions = data;
                }, function (data) {
                    $scope.course.courseTypeOptions =[];
                    console.log("Can't get related course types");
                });

                $scope.courseService.getClients($scope.course.courseId, $scope.course.organisationId)
                .then(function (data) {
                    $scope.course.clients = data;
                    if ($scope.course.clients.length === 0) {
                        $scope.disableCancelButton = false;
                    } else {
                        $scope.cancelButtonTitle = "You cannot cancel this Course while there are Clients on the Course. Remove the Clients first.";
                    }
                }, function (data) {
                    $scope.course.clients =[];
                    console.log("Can't get allocated clients");
                });
        
                /**
                * Get the System Configuration associated with the organisation
                */
                $scope.courseService.getOrganisationSystemConfiguration($scope.course.organisationId)
                .then(function (data) {

                        //$scope.settings = response.data;
                        if (data) {
                            $scope.orgSystemConfig.DORSFeatureEnabled = data.DORSFeatureEnabled;
                            $scope.orgSystemConfig.ShowCourseLanguage = data.ShowCourseLanguage;
                            $scope.orgSystemConfig.MultiDayCoursesAllowed = data.MultiDayCoursesAllowed;
                            $scope.orgSystemConfig.SMSEnabled = data.SMSEnabled;

                    }
                },
                    function (data) {
                        $scope.orgSystemConfig.ShowCourseLanguage = false;
                        console.log("Can't get organisation system configuration");
                        console.log(data);
                });

                /**
                * Get the Self Configuration associated with the organisation
                */
                $scope.courseService.getOrganisationSelfConfiguration($scope.course.organisationId)
                .then(function (data) {
                    if (data) {
                        $scope.orgSystemConfig.ShowManulCarCourseRestriction = data.ShowManulCarCourseRestriction;
                        $scope.orgSystemConfig.ShowTrainerCosts = data.ShowTrainerCosts;
                    }
                }, function (response) {
                    console.log("Can't get organisation self configuration");
                    console.log(response);
                });
            });

        } //$scope.getCourseOptions = function () {



        $scope.trainerText = function () {
            var text = '';
            $scope.course.courseTrainersAndInterpreters = $filter('orderBy') ($scope.course.courseTrainersAndInterpreters, 'Name');
            angular.forEach($scope.course.courseTrainersAndInterpreters, function (value, key) {
                if (text.length === 0) {
                    text = value.Name
                } else {
                        text = text + '\n' +value.Name
                }
            });

            return text;
        }


        $scope.noteText = function () {
            var text = '';
            if (!($scope.course === undefined || $scope.course.courseNotes === undefined || $scope.course.courseNotes === null)) {
                for (var i = 0; i < $scope.course.courseNotes.length; i++) {
                    var currentNote = $scope.course.courseNotes[i];
                    text = text + '\n' +$scope.formatDate(currentNote.Date) + ':-' + currentNote.Type + '(' + currentNote.User + '):' + '\n' +currentNote.Text + '\n......'
        };
            }

            return text;
        }

        $scope.documentTitleList = function () {
            var text = '';
            if (!($scope.course === undefined || $scope.course.documents === undefined || $scope.course.documents === null)) {
                for (var i = 0; i < $scope.course.documents.length; i++) {
                    var currentDocument = $scope.course.documents[i];
                    text = text + '\n' + currentDocument.Title + '\n......'
                };
            }
            return text;
        }


        $scope.parseDate = function (dateString) {
            return DateFactory.parseDateSlashes(dateString);
        }

        $scope.formatDate = function (date) {
            return $filter('date') (date, 'dd-MMM-yyyy')
        }

        $scope.formatTime = function (date) {
            return $filter('date')(date, 'hh:mm')
        }

        $scope.saveCourse = function (saveAndClose) {

            if ($scope.course.multiday && Date.parse($scope.course.courseDateEnd) <= Date.parse($scope.course.courseDateStart)) {
                $scope.validationMessage = "Multi Day Course is selected. End date must exceed start date."
            }
            else {
                $scope.course.operation = "SAVE";

                //This data will be passed in dynamically in another user story
                //$scope.course.userId = 1;
                //$scope.course.organisationId = 25;
                $http.defaults.headers.post["Content-Type"]= "application/x-www-form-urlencoded";

                if ($scope.course.selectedCourseCategory) {

                        console.log($scope.course.categoryId);
                        console.log($scope.course.selectedCourseCategory.Id);

                        $scope.course.categoryId = $scope.course.selectedCourseCategory.Id;
                }
                else {
                        $scope.validationMessage = "";      // course category isn't required anymore
                    }

                //if (new Date() > new Date($scope.course.courseDateStart) && $scope.course.courseId != 0) {
                //    alert('Please select a future course start date!');
                //    return false;
                //}
                console.log($scope.course);
                $http.post(apiServer + '/course', $scope.course)
                .then(function (response, status, headers, config) {

                        $scope.showSuccessFader = true;
                        var data = response.data;

                        if (data.actionMessage === "courseSaved" || data.actionMessage === "courseAdded") {
                            if ($scope.isDorsCourseChecked()) {
                                var courseId = data.Id;
                                CourseService.getDORSCourse(courseId)
                                    .then(
                                        function successCallback(response) {
                                            var dorsCourse = response.data;
                                            if (dorsCourse) {
                                                if (dorsCourse.DORSCourseIdentifier && dorsCourse.DORSCourseIdentifier > 0) {
                                                    // course is in DORS already perform an update course.
                                                    DorsService.updateCourse(courseId)
                                                        .then(
                                                            function successCallback(response) {
                                                                if (response.data) {
                                                                    $scope.successMessage = "The Course saved successfully.";
                                                                    $scope.validationMessage = "";
                                                                }
                                                                else {
                                                                    $scope.successMessage = "The Course wasn't updated in DORS, please try again later.";
                                                                    $scope.validationMessage = "";
                                                            }
                                                    },
                                                            function errorCallback(response) {
                                                                $scope.successMessage = "";
                                                                $scope.validationMessage = "An error occurred, please contact support.";
                                                    }
                                                        );
                                                }
                                                else {
                                                    // course isn't in DORS yet, perform a course add.
                                                    DorsService.addCourse(courseId)
                                                        .then(
                                                            function successCallback(response) {
                                                                $scope.successMessage = "The Course saved successfully.";
                                                                $scope.validationMessage = "";
                                                    },
                                                            function errorCallback(response) {
                                                                $scope.successMessage = "";
                                                                $scope.validationMessage = "An error occurred, please contact support.";
                                                    }
                                                        );
                                            }
                                        }
                                },
                                        function errorCallback(response) {
                                            $scope.successMessage = "";
                                            $scope.validationMessage = "An error occurred, please contact support.";
                                }
                                    );
                            }
                            else {
                                $scope.successMessage = "The Course saved successfully.";
                                $scope.validationMessage = "";
                            }
                        }
                        else {
                            $scope.successMessage = "";
                            $scope.validationMessage = "An error occurred, please contact support.";
                        }

                        if (saveAndClose == true) {
                            $('button.close').trigger('click');
                        }
                    }, function (data, status, headers, config) {

                        $scope.showErrorFader = true;

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred, please contact support.";
                });
            }
        }

        $scope.addToMenuFavourite = function () {

            var menuFavourouriteParams = {
                    UserId: $scope.$parent.userId,
                Title: "add course",
                    Link: "app/components/course/view.html",
                Parameters: "viewCourseCtrl",
                Modal: "True"
            };

            $scope.$emit('savemenufavourite', menuFavourouriteParams);
        }

        $scope.refreshNotes = function () {
            $scope.courseService.getCourseNotes($scope.course.courseId)
                .then(function (data, status, headers, config) {
                    $scope.course.courseNotes = data;
                    $scope.notes = $scope.noteText();
                });
        }


        /* functions for showing/hiding panels and tabs */
        $scope.showCourseClients = function () {
            if ($scope.showingCourseClients) {
                $scope.hideClientsContent();
            }
            else {
                $scope.hideHistoryContent();
                $scope.showClientsContent();
            }
        }

        $scope.showCourseHistory = function () {
            if ($scope.showingCourseHistory) {
                $scope.hideHistoryContent();
            }
        else {
            $scope.hideClientsContent();
            $scope.showHistoryContent();
            }
        }

        $scope.showCourseDetails = function () {
            $scope.hideClientsContent();
            $scope.hideHistoryContent();

            $scope.hideDetailsTab();
        }

        $scope.showHistoryContent = function () {
            $("#courseHistoryPanel").animate({'left': 0}, 300);
            $scope.showingCourseHistory = true;

            $scope.hideHistoryTab();
            $scope.showDetailsTab();
        }

        $scope.showClientsContent = function () {
            $("#courseClientPanel").animate({'left': 0}, 300);
            $scope.showingCourseClients = true;
            $scope.showDetailsTab();
            $scope.hideClientsTab();
        }

        $scope.hideHistoryContent = function () {
            $("#courseHistoryPanel").animate({'left': 940}, 300);
            $scope.showingCourseHistory = false;
            $scope.showHistoryTab();
        }

        $scope.hideClientsContent = function () {
            $("#courseClientPanel").animate({'left': 940}, 300);
            $scope.showingCourseClients = false;
            $scope.showClientsTab();
        }

        /* tabs show hide functions */
        $scope.showDetailsTab = function () {
            $("#courseDetailsTab").show();
        }

        $scope.showHistoryTab = function () {
            $("#courseHistoryTab").show();
        }

        $scope.showClientsTab = function () {
            $("#courseClientsTab").show();
        }

        $scope.hideDetailsTab = function () {
            $("#courseDetailsTab").hide();
        }

        $scope.hideHistoryTab = function () {
            $("#courseHistoryTab").hide();
        }

        $scope.hideClientsTab = function () {
            $("#courseClientsTab").hide();
        }

        $scope.isDorsFeatureEnabled = function () {

            if ($scope.orgSystemConfig.DORSFeatureEnabled) {
                if ($scope.orgSystemConfig.DORSFeatureEnabled === true) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
        }

        $scope.isDorsCourseChecked = function () {

            if ($scope.orgSystemConfig.DORSFeatureEnabled) {
                if ($scope.orgSystemConfig.DORSFeatureEnabled === true
                    && $scope.course.courseDorsCourse === true) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
        }

        $scope.getCoursePlacesDetail = function () {
            CourseService.getCoursePlacesDetail($scope.course.courseId)
                .then(function (response) {
                    $scope.course.coursePlaceDetails = response.data;
                }, function () {
        })
        }

        $scope.isDorsEditable = function () {
            if ($scope.orgSystemConfig.DORSFeatureEnabled) {
                if ($scope.orgSystemConfig.DORSFeatureEnabled === true
                    && $scope.course.courseDorsCourse === true
                    ) {
                    return true;
                }
                else {
                    return false;
                }
            } else {
                return false;
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

        $scope.addDocumentModal = function (courseId) {
            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Add Course Document",
                    cssClass: "courseDocumentModal",
                    filePath: "/app/components/course/addDocument.html",
                    controllerName: "addCourseDocumentCtrl"
            });
        }

        $scope.selectDocument = function (document) {
            $scope.selectedDocument = document;
        };

        $scope.refreshDocuments = function () {
            return CourseService.getCourseDocuments($scope.course.courseId)
                    .then(
                        function successCallback(data) {
                            $scope.documents = data;
                        }
                    );
        }

        $scope.refreshClients = function (courseId) {

            return CourseService.getClients(courseId, $scope.course.organisationId)
                    .then(
                        function successCallback(data) {
                            $scope.course.clients = data;
        }
                    );
        }

        $scope.addClient = function (courseId) {
            $scope.addClientToCourseId = courseId;
            $scope.addedByUserId = activeUserProfile.UserId;
            $scope.courseTypeId = $scope.course.courseTypeId;

            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Add Client to Course",
                    cssClass: "addClientToCourseModal",
                    filePath: "/app/components/client/add.html",
                controllerName: "addClientCtrl",
            });
        }

        $scope.cancelCourse = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Cancel Course",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                    filePath: "/app/components/course/cancel.html",
                    controllerName: "cancelCourseCtrl",
                    cssClass: "cancelCourseModal",
                    buttons: {
                        label: 'Close',
                            cssClass: 'closeModalButton',
                            action : function (dialogItself) {
                                dialogItself.close();
                            }
                    }
            });
        }

        $scope.editCourseBooking = function (course, client) {
            $scope.client.Id = client.ClientId;
            $scope.client.DisplayName = client.ClientName;
            $scope.client.Title = client.ClientTitle;

            $scope.currentCourse.Id = course.Id;
            $scope.currentCourse.Reference = course.courseReference;
            $scope.currentCourse.CourseDate = course.courseDateStart;
            $scope.currentCourse.IsDORSCourse = course.courseDorsCourse;


            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Edit Course Booking",
                    cssClass: "editCourseBookingModal",
                    filePath: "/app/components/client/editCourseBooking.html",
                    controllerName: "EditCourseBookingCtrl",
                        buttons: {
                        label: 'Close',
                            cssClass: 'closeModalButton',
                            action : function (dialogItself) {
                                dialogItself.close();
                            }
                        }
            });
        }

        /**
            * Download an existing document
            */
        $scope.openDownloadDocumentModal = function () {

            $scope.downloadDocumentObject = { };
            $scope.downloadDocumentObject.Id = $scope.selectedDocument.Id;
            $scope.downloadDocumentObject.typeLabel = "Course";
            $scope.downloadDocumentObject.typeDescription = $scope.course.courseType.Title + " - REF: " +$scope.course.courseReference + " (Id: " +$scope.course.Id + ")";
            $scope.downloadDocumentObject.typeName = $scope.selectedDocument.Type;
            $scope.downloadDocumentObject.documentSaveName = $scope.selectedDocument.Title;
            $scope.downloadDocumentObject.owningEntityId = $scope.course.Id;
            $scope.downloadDocumentObject.owningEntityPath = "course";

            $scope.modalService.displayModal({

                scope: $scope,
                    title: "Download Course Document",
                    cssClass: "downloadDocumentModal",
                    filePath: "/app/components/documents/download.html",
                    controllerName: "DocumentDownloadCtrl"
            });

        };

        /**
        * Open the clone course modal
        * Send [required]parameters in to make the modal work
        * required params
        */
        $scope.openCloneCourse = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Clone Course",
                    cssClass: "cloneCourseModal",
                    filePath: "/app/components/course/cloneCourse.html",
                    controllerName: "CloneCourseCtrl",
                    buttons: {
                    label: 'Close',
                        cssClass: 'closeModalButton',
                        action : function (dialogItself) {
                            dialogItself.close();
                        }
                    }
            });
        };

        $scope.updateCourseAssociatedSession = function (session) {
            var courseAssociatedSession = findBySessionNumber($scope.course.courseTrainingSessions, $scope.course.sessionNumber);
            $scope.course.courseAssociatedSession = courseAssociatedSession;
        };


        function findBySessionNumber(source, sessionNumber) {
            for (var i = 0; i < source.length; i++) {
                if (source[i].SessionNumber === sessionNumber) {
                    return source[i].SessionTitle;
                }
            }
            throw "Couldn't find object with session number: " +sessionNumber;
        }

        $scope.openDocInfoModal = function () {

            ModalService.displayModal({
                scope: $scope,
                    title: "Document Information",
                    cssClass: "addCourseTrainerModal",
                    filePath: "/app/components/documentInformation/manage.html",
                    controllerName: "DocumentInformationCtrl",
                    buttons: {
                    label: 'Close',
                        cssClass: 'closeModalButton',
                        action : function (dialogItself) {
                            dialogItself.close();
                        }
                    }
            });

        }

        $scope.emailClients = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Email All Clients On Course",
                    cssClass: "EmailAllClientsModal",
                    filePath: "/app/components/course/emailAllClients.html",
                    controllerName: "EmailAllClientsCtrl",
                        buttons: {
                            label: 'Close',
                            cssClass: 'closeModalButton',
                            action : function (dialogItself) {
                                dialogItself.close();
                            }
                        }
            });
        }

        $scope.emailTrainers = function () {
            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Email All Trainers Assigned to a Course",
                    cssClass: "EmailAllTrainersModal",
                    filePath: "/app/components/course/emailAllTrainers.html",
                    controllerName: "EmailAllTrainersCtrl",
                    buttons: {
                    label: 'Close',
                        cssClass: 'closeModalButton',
                        action : function (dialogItself) {
                            dialogItself.close();
                        }
                    }
            });
        }

        $scope.showSMSAllClientModal = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Send All Client SMS",
                    cssClass: "sendClientSMSModal",
                    filePath: "/app/components/SMS/allClient.html",
                    controllerName: "AllClientSMSCtrl"
        });
        }

        $scope.showSMSAllTrainerModal = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                    title: "Send All Trainer SMS",
                    cssClass: "sendClientSMSModal",
                    filePath: "/app/components/SMS/allTrainer.html",
                    controllerName: "AllTrainerSMSCtrl"
        });
        }

        $scope.getSessionLabel = function (sessionId) {
            var sessionLabel = "";
            if ($scope.course.courseTrainingSessions) {
                var courseSessionList = $filter('filter') ($scope.course.courseTrainingSessions, { SessionNumber: sessionId });
                if (courseSessionList.length > 0) {
                        sessionLabel = courseSessionList[0].SessionTitle;
                }
            }
            return sessionLabel;
        }

        $scope.isCourseLockedOrProfileLocked = function () {

            var isCourseLocked = $scope.course.isCourseLocked;
            var isCourseProfileLocked = $scope.course.isCourseProfileLocked;

            if (isCourseLocked || isCourseProfileLocked) {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.isCourseLocked = function () {

            var isCourseLocked = $scope.course.isCourseLocked;

            if (isCourseLocked) {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.isCourseDateInPast = function () {

            /*
                If the selected date is in the past disable the remove button 
            */

            if(angular.isDefined($scope.course.courseDateStart)) {
                var today = $filter('date') (new Date(), 'yyyyMMdd');

                var courseStartDate = DateFactory.formatDatedddmmyyyy($scope.course.courseDateStart);

                if (Number(courseStartDate) < Number(today)) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
        }

        $scope.populateTrainingSessions();

        $scope.getCourseOptions();

        $scope.getCoursePlacesDetail();
    }
})();

  
