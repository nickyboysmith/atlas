(function () {

    'use strict';

    angular
        .module('app')
        .controller("CourseTrainerCtrl", CourseTrainerCtrl);

    CourseTrainerCtrl.$inject = ["$scope", "ModalService"];

    function CourseTrainerCtrl($scope, ModalService) {



        /**
         * Display the add course modal
         */
        $scope.addCourseTrainer = function (courseData) {

            /**
             * Set the course data 
             * as a property on the scope
             */
            $scope.course = courseData;
            /**
             * Fire the modal
             * With the buttons object
             * Adds close button to the object
             */
            ModalService.displayModal({
                scope: $scope,
                title: "Add Course Trainer",
                cssClass: "addCourseTrainerModal",
                filePath: "/app/components/course/addCourseTrainer.html",
                controllerName: "AddCourseTrainerCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };


        $scope.removeCourseTrainer = function () {
            console.log("Fiired Modal for remove course trainer.");
        };






    }

})();

