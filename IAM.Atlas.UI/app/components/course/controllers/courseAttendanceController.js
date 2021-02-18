(function () {

    'use strict'; 

    angular
        .module("app")
        .controller("CourseAttendanceCtrl", CourseAttendanceCtrl);

    CourseAttendanceCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "UserService", "CourseAttendanceService", "CourseAttendanceFactory", "DateFactory",  "ModalService"];

    function CourseAttendanceCtrl($scope, $filter, activeUserProfile, UserService, CourseAttendanceService, CourseAttendanceFactory, DateFactory, ModalService) {

        /**
         * Check if user is a system admin
         */
        $scope.isSystemAdmin = activeUserProfile.IsSystemAdmin;

        /**
         * Set the selected organisation
         */
        $scope.selectedOrganisation;

        /**
         * Set the selected courseTytpe
         */
        $scope.selectedCourseType;

        /**
         * Set the selected course type category
         */
        $scope.selectedCourseTypeCategory;

        /**
         * Organisation List
         */
        $scope.listOfOrganisations = [];

        /**
         * Search course attendance
         */
        $scope.searchObject = {};

        /**
         * Hold the array of course types
         */
        $scope.courseTypes = [];

        /**
         * Hold the array of course type categories
         */
        $scope.courseTypeCategories = [];

        /**
         * Hold array of courses
         */
        $scope.courses = [];
        $scope.courseCollection = [];

        /**
         * Start date
         */
        $scope.startDate;
        $scope.startDate = DateFactory.formatDateddMONyyyy(new Date());
        $scope.showStartDatePicker = false;

        /**
         * End date
         */
        $scope.endDate = DateFactory.formatDateddMONyyyy(new Date());
        $scope.showEndDatePicker = false;

        /**
         * course attendance empty message
         */
        $scope.courseAttendanceEmpty = "Please select a course to verify course attendance!";

        /**
         * Fill the selected course details
         */
        $scope.selectedCourse = {};

        /**
         * Hold array of ccourse clients
         */
        $scope.courseClients = [];
        $scope.courseClientCollection = [];

        /**
         * Hold array of course trainers
         */
        $scope.courseClientTrainers = [];

        /**
         * Trainer drop down selection variables
         */
        $scope.trainerAttendanceSelectionOne;
        $scope.trainerAttendanceSelectionTwo;

        /**
         * Trainer Selection Details
         */
        $scope.trainerSelectionDetailsOne = {};
        $scope.trainerSelectionDetailsTwo = {};

        /**
         * trainer attendances course clients
         */
        $scope.trainerOneAttendances = [];
        $scope.trainerOneAttendanceCollection = [];

        $scope.trainerTwoAttendances = [];
        $scope.trainerTwoAttendanceCollection = [];

        /**
         * Fill object to
         * Show the attendance check button
         * & class and text based on if the user is verified
         */
        $scope.attendanceCheckObject = {};


        /**
         * Get list of organisations
         */
        $scope.getOrganisations = function () {
            UserService.getOrganisationIds(activeUserProfile.UserId)
            .then(
                function (response) {
                    var amountOfOrganisations = response.length;
                    if (amountOfOrganisations === 1) {
                        $scope.selectedOrganisation = response[0].id
                        if (activeUserProfile.selectedOrganisation.Id > 0) {
                            $scope.selectedOrganisation = activeUserProfile.selectedOrganisation.Id
                            $scope.getCourseTypes($scope.selectedOrganisation);
                        }
                    } else {
                        $scope.listOfOrganisations = response;
                    }
                },
                function (reason) {
                }
            );
        };
        
        /**
         * Get list of Course Types
         */
        $scope.getCourseTypes = function (organisationId) {
            CourseAttendanceService.getCourseTypes(organisationId)
            .then(
                function (data) {
                    $scope.courseTypes = data;
                },
                function (response) {
                }
            );
        };

        /*
         * Call the function
         */
        $scope.getOrganisations();

        /**
         * loadCourseClients
         * @param {course} course : The Course Parameter
         */
        $scope.loadCourseClients = function (course, courseClientsOnly) {

            if (courseClientsOnly === undefined) { courseClientsOnly = false;}
            /**
             * Hide course client container
             * & the course attendance empty message
             */
            $("#theCourseAttendanceClients").hide();
            $("#courseNotSelected").hide();

            // Start spinner
            $("#courseAttendanceSpinner").show();

            /**
             * Fill the course details
             */
            $scope.selectedCourse = course;

            /**
             * Get course clients 
             */
            CourseAttendanceService.getCourseClients({
                organisationId: $scope.selectedOrganisation,
                courseId: course.CourseId
            })
            .then(
                function (response) {
                    var result = response.data[0];
                    $scope.courseClients = result.Course;
                    if (courseClientsOnly === false) {
                        $scope.courseClientTrainers = result.CourseTrainer;
                        $scope.convertAttendanceCheck($scope.courseClients[0].AttendanceCheckVerified);
                    }
                    $("#courseAttendanceSpinner").hide();
                    $("#theCourseAttendanceClients").show();
                },
                function (reason) {
                    $scope.courseAttendanceEmpty = reason.data;
                    $("#courseAttendanceSpinner").hide();
                    $("#courseNotSelected").show();
                }
            );

        };

        /**
         * Add the key to the search object 
         * Then get the details based on the search parameters
         */
        $scope.buildSearchObject = function (key, value) {
            /**
             * Hide table and error
             */
            $("#courseSelectionHolder").hide();
            $("#courseError").hide();

            // start spinner
            $("#courseSpinner").show();

            /**
             * If multiple orgs
             * Set the org on the scope
             */
            if (key === "organisationId") {
                $scope.selectedOrganisation = value;
                $scope.getCourseTypes($scope.selectedOrganisation);
            }

            $scope.searchObject[key] = value;
            $scope.getCourseDetail($scope.searchObject);
        };

        /**
         * Get the data then 
         */
        $scope.getCourseDetail = function (searchObject) {
            CourseAttendanceService.getCourseDetail(searchObject)
            .then(
                function (response) {

                    /**
                     * Check to see if there are any results
                     */
                    if (response.data.length === 0) {
                        /**
                         * Stop the spinner spinning
                         */
                        $("#courseSpinner").hide();

                        /**
                         * Show the error div
                         */
                        $("#courseError").show();
                    } else {
                        var transformedData = CourseAttendanceFactory.transform(response.data);

                        $scope.courses = transformedData.courses;
                        if ($scope.courses.length > 0)
                        {
                            $scope.loadCourseClients($scope.courses[0], false)
                        }


                        //$scope.courseTypes = transformedData.courseTypes;
                        $scope.courseTypeCategories = transformedData.categories;

                        /**
                         * Stop the spinner spinning
                         */
                        $("#courseSpinner").hide();

                        /**
                         * Show the table
                         */
                        $("#courseSelectionHolder").show();
                    }
                },
                function (reason) {
                    console.log(reason.data);
                    /**
                     * Stop the spinner spinning
                     */
                    $("#courseSpinner").hide();

                    /**
                      * Show the error div
                      */
                    $("#courseError").show();
                }
            );
        };

        /**
         * update an object message
         * To show if the course attendance is verified or not
         */
        $scope.convertAttendanceCheck = function (attendanceCheckVerified) {
            var attendanceObject = {
                theClass: "verified",
                text: "Attendance verified",
                isVerified: true
            };

            /**
             * If the attendance check is not true
             */
            if (attendanceCheckVerified !== true) {
                attendanceObject = {
                    theClass: "not-verified",
                    text: "Attendance not verified",
                    isVerified: false
                };
            }

            $scope.attendanceCheckObject = attendanceObject;

        };


        /**
         * Load the trainer attendance list 
         */
        $scope.loadTheTrainerAttendance = function (param, trainer, attemptNumber) {

            var decisionMaker = {
                one: {
                    "assignTrainerId": "trainerAttendanceSelectionOne",
                    "errorContainer": "#trainerAttendanceOneMessage",
                    "errorMessageVariable": "trainerAttendanceOneMessage",
                    "spinner": "#trainerAttendanceOneSpinner",
                    "table": "#trainerAttendanceOneTable",
                    "attendanceList": "trainerOneAttendances",
                    "details": "trainerSelectionDetailsOne",
                    "displayDetailsDiv": "#showTrainerOneDetails"
                },
                two: {
                    "assignTrainerId": "trainerAttendanceSelectionTwo",
                    "errorContainer": "#trainerAttendanceTwoMessage",
                    "errorMessageVariable": "trainerAttendanceTwoMessage",
                    "spinner": "#trainerAttendanceTwoSpinner",
                    "table": "#trainerAttendanceTwoTable",
                    "attendanceList": "trainerTwoAttendances",
                    "details": "trainerSelectionDetailsTwo",
                    "displayDetailsDiv": "#showTrainerTwoDetails"
                }
            };

            /* reset error message */
            $scope[decisionMaker[param]["errorMessageVariable"]] = "";

            if (trainer === (undefined || "" || null)) {
                /**
                 * Assign the selected trainer ID
                 */
                $scope[decisionMaker[param]["assignTrainerId"]] = "";
                $scope[decisionMaker[param]["details"]] = {};
                $(decisionMaker[param]["table"]).hide();
                $(decisionMaker[param]["displayDetailsDiv"]).hide();
                return false;
            }

            /**
             * Set the trainer Id
             */
            var trainerId = trainer.TrainerId;

            /**
             * Start the spinner
             */
            $(decisionMaker[param]["spinner"]).show();

            /**
             * Assign the selected trainer ID
             */
            $scope[decisionMaker[param]["assignTrainerId"]] = trainerId;

            /**
             * Check if the trainer Id is the same as a drop down
             */
            var hasLoadedSameTrainer = $scope.checkTheTrainerDropdownSame();

            /**
             * Check to see if the trainer id on both drop downs are the same
             * If they aren't then proceed with calling the service
             */                
            if (hasLoadedSameTrainer === true) {
                $scope[decisionMaker[param]["errorMessageVariable"]] = "You can't compare attendance with the same trainer";
                $(decisionMaker[param]["table"]).hide();
                $(decisionMaker[param]["spinner"]).hide();
                $(decisionMaker[param]["errorContainer"]).show();
                $(decisionMaker[param]["displayDetailsDiv"]).hide();
            } else {
                CourseAttendanceService.getAttendance({
                    organisationId: $scope.selectedOrganisation,
                    courseId: $scope.selectedCourse.CourseId,
                    trainerId: trainerId
                })
                .then(
                    function (response) {

                        var length = response.data.length;

                        /**
                         * Check to see if any results exist
                         * If they don't output a message
                         * If they do load table
                         */
                        if (length === 0) {
                            $scope[decisionMaker[param]["errorMessageVariable"]] = "No Results found";
                            $(decisionMaker[param]["table"]).hide();
                            $(decisionMaker[param]["spinner"]).hide();
                            $(decisionMaker[param]["errorContainer"]).show();
                            $(decisionMaker[param]["displayDetailsDiv"]).hide();
                        } else {

                            /**
                             * Fill the details
                             */
                            $scope[decisionMaker[param]["details"]] = {
                                TrainerId: trainerId,
                                TrainerName: trainer.TrainerName,
                                DORSTrainerIdentifier: trainer.DORSTrainerIdentifier,
                                TrainerEmail: response.data[0].TrainerEmail
                            };

                            /**
                             * Add the array of attendees 
                             * for that trainer to the object
                             */
                            $scope[decisionMaker[param]["attendanceList"]] = response.data;

                            /**
                             * Hide spinner and error message
                             */
                            $(decisionMaker[param]["spinner"]).hide();
                            $(decisionMaker[param]["errorContainer"]).hide();

                            /**
                             * Show the table
                             */
                            $(decisionMaker[param]["table"]).show();

                            $(decisionMaker[param]["displayDetailsDiv"]).show();

                        }

                    },
                    function (reason) {
                        if (attemptNumber > 3){
                            //$scope[decisionMaker[param]["errorMessageVariable"]] = "An error has occurred: " + reason.data.ExceptionType; //@TODO LOG THIS ERROR
                            $scope[decisionMaker[param]["errorMessageVariable"]] = "An error has occurred ... Please notify Atlas Support";
                            $(decisionMaker[param]["table"]).hide();
                            $(decisionMaker[param]["spinner"]).hide();
                            $(decisionMaker[param]["errorContainer"]).show();
                        } else {
                            $scope.loadTheTrainerAttendance(param, trainer, attemptNumber + 1);
                        }
                    }
                );
            }
        };

        /**
         * Check the status of the client
         * 
         */
        //$scope.checkAttendance = function (attendance) {
        //    var status = "Absent";
        //    if (attendance === true) {
        //        status = "Present";
        //    }
        //    return status;
        //}

        /**
         * Compare both dropdown selections
         * To see if they are the same 
         */
        $scope.checkTheTrainerDropdownSame = function () {
            var isTrainerIdSame = false;
            var trainerOne = $scope.trainerAttendanceSelectionOne;
            var trainerTwo = $scope.trainerAttendanceSelectionTwo;

            if (trainerOne === trainerTwo) {
                isTrainerIdSame = true;
            }

            return isTrainerIdSame;
        };

        /**
        * 
        */
        $scope.setAttendanceCheckVerified = function (courseId) {

            /**
             * Set AttendanceCheckVerified for a course
             */
            CourseAttendanceService.setAttendanceCheckVerified(courseId, $scope.selectedOrganisation)
            .then(
                function (response) {
                    $scope.attendanceCheckObject = {
                        isVerified: true,
                        theClass: "verified",
                        text: "Attendance verified",
                    };
                },
                function (reason) {
                    $scope.courseAttendanceEmpty = "Failed to verify attendance";
                }
            );

        };

        
        $scope.toggleClientAttendance = function (ClientId) {

            /**
             * Set Client Attendance
             */
            CourseAttendanceService.setClientAttendance($scope.selectedCourse.CourseId, ClientId, activeUserProfile.UserId)
            .then(
                function (response) {

                    if (response)
                    {

                        if (angular.isUndefined($scope.trainerAttendanceSelectionOne) === false && $scope.trainerAttendanceSelectionOne !== '') {
                            // filter out the Trainer Object
                            var TrainerOne = $filter('filter')($scope.courseClientTrainers, { TrainerId: $scope.trainerAttendanceSelectionOne })
                            if (TrainerOne.length > 0)
                            {
                                $scope.loadTheTrainerAttendance('one', TrainerOne[0], 1);
                            }
                        }

                        if (angular.isUndefined($scope.trainerAttendanceSelectionTwo) === false && $scope.trainerAttendanceSelectionTwo !== '') {
                            // filter out the Trainer Object
                            var TrainerTwo = $filter('filter')($scope.courseClientTrainers, { TrainerId: $scope.trainerAttendanceSelectionTwo })
                            if (TrainerTwo.length > 0) {
                                $scope.loadTheTrainerAttendance('two', TrainerTwo[0], 1);
                            }
                        }

                        /**
                         * Get course clients 
                         */
                        $scope.loadCourseClients($scope.selectedCourse, true);
                    }

                },
                function (reason) {
                    $scope.courseAttendanceEmpty = "Failed to verify attendance";
                }
            );

        };

        $scope.setCourseAttendanceAbsentToAll = function () {

            /*
             * Course Attendance - Mark all as Absent
             */
            CourseAttendanceService.setCourseAttendanceAbsentToAll($scope.selectedCourse.CourseId, activeUserProfile.UserId)
            .then(
                function (response) {

                    if (response) {

                        if (angular.isUndefined($scope.trainerAttendanceSelectionOne) === false && $scope.trainerAttendanceSelectionOne !== '') {
                            // filter out the Trainer Object
                            var TrainerOne = $filter('filter')($scope.courseClientTrainers, { TrainerId: $scope.trainerAttendanceSelectionOne })
                            if (TrainerOne.length > 0) {
                                $scope.loadTheTrainerAttendance('one', TrainerOne[0], 1);
                            }
                        }

                        if (angular.isUndefined($scope.trainerAttendanceSelectionTwo) === false && $scope.trainerAttendanceSelectionTwo !== '') {
                            // filter out the Trainer Object
                            var TrainerTwo = $filter('filter')($scope.courseClientTrainers, { TrainerId: $scope.trainerAttendanceSelectionTwo })
                            if (TrainerTwo.length > 0) {
                                $scope.loadTheTrainerAttendance('two', TrainerTwo[0], 1);
                            }
                        }

                        /**
                         * Get course clients 
                         */
                        $scope.loadCourseClients($scope.selectedCourse, true);
                    }

                },
                function (reason) {
                    $scope.courseAttendanceEmpty = "Failed to verify attendance";
                }
            );
        };

        
        $scope.setCourseAttendancePresentToAll = function () {
                
            /*
                * Course Attendance - Mark all as Present
                */
            CourseAttendanceService.setCourseAttendancePresentToAll($scope.selectedCourse.CourseId, activeUserProfile.UserId)
            .then(
                function (response) {

                    if (response) {

                        if (angular.isUndefined($scope.trainerAttendanceSelectionOne) === false && $scope.trainerAttendanceSelectionOne !== '') {
                            // filter out the Trainer Object
                            var TrainerOne = $filter('filter')($scope.courseClientTrainers, { TrainerId: $scope.trainerAttendanceSelectionOne })
                            if (TrainerOne.length > 0) {
                                $scope.loadTheTrainerAttendance('one', TrainerOne[0], 1);
                            }
                        }

                        if (angular.isUndefined($scope.trainerAttendanceSelectionTwo) === false && $scope.trainerAttendanceSelectionTwo !== '') {
                            // filter out the Trainer Object
                            var TrainerTwo = $filter('filter')($scope.courseClientTrainers, { TrainerId: $scope.trainerAttendanceSelectionTwo })
                            if (TrainerTwo.length > 0) {
                                $scope.loadTheTrainerAttendance('two', TrainerTwo[0], 1);
                            }
                        }

                        /**
                            * Get course clients 
                            */
                        $scope.loadCourseClients($scope.selectedCourse, true);
                    }

                },
                function (reason) {
                    $scope.courseAttendanceEmpty = "Failed to verify attendance";
                }
            );

        };


        if (activeUserProfile.selectedOrganisation.Id > 0) {
            $scope.selectedOrganisation = activeUserProfile.selectedOrganisation.Id;
            $scope.searchObject['startDate'] = $scope.startDate;
            $scope.searchObject['endDate']= $scope.endDate;
            $scope.buildSearchObject('organisationId', activeUserProfile.selectedOrganisation.Id)
        }

        /**
        * Fire the Trainer Email related modal
        */
        $scope.fireModalTrainerEmail = function (trainerSelectionDetails) {

            $scope.clientEmailAddress = trainerSelectionDetails.TrainerEmail;
            $scope.clientEmailId = trainerSelectionDetails.TrainerId;
            $scope.clientEmailName = trainerSelectionDetails.TrainerName;
            $scope.recipientType = "Trainer";

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

        $scope.formatDate = function (date) {
            return DateFactory.formatDateddMONyyyy(date);
        }

    }

})();