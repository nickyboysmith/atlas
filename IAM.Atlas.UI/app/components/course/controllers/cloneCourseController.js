(function () {

    'use strict';

    angular
        .module("app")
        .controller("CloneCourseCtrl", CloneCourseCtrl);

    CloneCourseCtrl.$inject = ["$scope", "activeUserProfile", "CourseTrainerFactory", "DateFactory", "ModalService", "CourseService", "OrganisationSelfConfigurationService"];

    function CloneCourseCtrl($scope, activeUserProfile, CourseTrainerFactory, DateFactory, ModalService, CourseService, OrganisationSelfConfigurationService) {

        /**
         * Initialize and set to false
         */
        $scope.showWeeklyMonthlyCourses = false;

        /**
         * Initialize and set to false
         */
        $scope.showStartDate = false;

        /**
         * Initialize and set to false
         */
        $scope.showEndDate = false;

        /**
         * Initialize and set to course ref on parent scope
         */
        $scope.courseReference = $scope.$parent.course.courseReference;

        /**
         * Find the position of the index in the array for the course type id
         */
        $scope.selectedCourseTypeArrayPosition = CourseTrainerFactory.find(
            $scope.$parent.course.courseTypeOptions,
            $scope.$parent.course.courseTypeId
        );

        /**
         * Then call the array with the found index
         */
        $scope.courseType = $scope.$parent.course.courseTypeOptions[$scope.selectedCourseTypeArrayPosition];

        /**
         * Find the position of the index in the array for the course category id
         */
        $scope.selectedCourseCategoryArrayPosition = CourseTrainerFactory.find(
            $scope.$parent.course.courseCategoryOptions,
            $scope.$parent.course.categoryId
        );

        /**
         * Then call the array with the found index
         */
        $scope.courseTypeCategory = $scope.$parent.course.courseCategoryOptions[$scope.selectedCourseCategoryArrayPosition];

        /**
         * Get Start date #& end date
         */
        $scope.originalCourseStartDate = $scope.$parent.course.courseDateStart;
        $scope.originalCourseEndDate = $scope.$parent.course.courseDateEnd;

        /**
         * Set the reference template
         */
        $scope.setReferenceTemplate = function (courseReferenceGeneratorId) {
            $scope.cloneSettings.referenceTemplate = courseReferenceGeneratorId;
        };

        /**
         * Get the organisation self conffiguration data
         * Specifically to get the Courdse ref gen Id
         * To auto select on load
         */
        OrganisationSelfConfigurationService.GetByOrganisation(
            activeUserProfile.selectedOrganisation.Id
        )
        .then(
            function (response) {
                if (response.data !== null) {
                    $scope.setReferenceTemplate(response.data.CourseReferenceGeneratorId);
                }
            },
            function (reason) {
                console.log(reason);
            }
        );

        /**
         * Initialize the course reference template array
         */
        $scope.courseReferenceTemplates = [];

        /**
         * Call the course reference service
         */
        CourseService.referenceGenerator()
        .then(
            function (response) {
                $scope.courseReferenceTemplates = response.data;
            },
            function (reason) {
                console.log(reason);
            }
        );

        /**
         * Get the first monday 
         * For a month from today
         * Return in the datepicker format 
         */
        $scope.getFirstMondayNextMonth = function () {
            // Get todays date
            var theDate = new Date();
            theDate.setDate(1);
            theDate.setMonth(theDate.getMonth() + 1);
            // Get the first Monday in the month
            while (theDate.getDay() !== 1) {
                theDate.setDate(theDate.getDate() + 1);
            }
            return $scope.formatDate(theDate);
        };

        /**
         * 
         */
        $scope.formatDate = function (date) {
            return DateFactory.formatDateddMONyyyy(DateFactory.parseDate(date));
        }

       

        /**]
         * Check to see what value is before passsed to the web api
         */
        $scope.courseTypeCategoryCheck = ($scope.courseTypeCategory) ? $scope.courseTypeCategory.Id : "";

        /**
         * Build clone object settings
         */
        $scope.cloneSettings = {
            userId: activeUserProfile.UserId,
            organisationId: activeUserProfile.selectedOrganisation.Id,
            courseId: $scope.$parent.course.courseId,
            courseTypeId: $scope.$parent.course.courseType.Id,
            courseTypeCategoryId: $scope.courseTypeCategoryCheck,
            maximumCourses: 1,
            startDate: $scope.getFirstMondayNextMonth(),
            endDate: $scope.getFirstMondayNextMonth(),
            sameReference: false,
            sameTrainers: false,
            weeklyCourses: false,
            monthlyCourses: false
        };

        /**
         * Show the relevant date picker
         * Hide it if it's already shown
         */
        $scope.showDatePicker = function (type) {
            if ($scope[type]) {
                $scope[type] = false;
                return false;
            }
            $scope[type] = true;
        };

        /**
         * Checks the course amount
         * Then shows based on whether the amount is 1 or greater
         */
        $scope.updateMaximumCourses = function (courseAmount) {
            $scope.showWeeklyMonthlyCourses = false;
            if (courseAmount > 1) {
                $scope.showWeeklyMonthlyCourses = true;
            }
        };

        /**
         * If the check box is clicked then 
         * show and clear input boxes based on selection
         */
        $scope.updateCourseRepeatSelection = function (type) {
            if (type === "weeklyCourses") {
                $scope.cloneSettings.monthlyCourses = false;
                $scope.cloneSettings.weeklyCourses = true;
                $scope.cloneSettings.createCourseEveryMonth = "";
                $scope.cloneSettings.createCourseEveryWeek = "";

            } else if (type === "monthlyCourses") {
                $scope.cloneSettings.weeklyCourses = false;
                $scope.cloneSettings.monthlyCourses = true;
                $scope.cloneSettings.createCourseEveryWeek = "";
                $scope.cloneSettings.createCourseEveryMonth = "";

            }
        };

        /**
         * if input box is filled then clear checkboxes
         * and clear the other input field
         */
        $scope.updateCourseAmountSelection = function (type, amount) {
            if (amount > 1) {
                $scope.cloneSettings.monthlyCourses = false;
                $scope.cloneSettings.weeklyCourses = false;
                if (type === "weeklyCourses") {
                    $scope.cloneSettings.createCourseEveryMonth = "";
                } else if (type === "monthlyCourses") {
                    $scope.cloneSettings.createCourseEveryWeek = "";
                }
            }
        };

        /**
         * 
         */
        $scope.selectCourseReferenceGenerator = function (template) {
            if (template === null) {
                return false;
            }
            $scope.cloneSettings["referenceTemplate"] = template;
        };

        /**
         * Open course confirmation Modal
         */
        $scope.courseConfirmation = function () {

            $scope.successMessage = "";
            $scope.errorMessage = "";

            ModalService.displayModal({
                scope: $scope,
                title: "Clone Course Confirmation",
                cssClass: "cloneCourseConfirmationModal",
                filePath: "/app/components/course/cloneCourseConfirmation.html",
                controllerName: "CloneCourseConfirmationCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };



    }

})();