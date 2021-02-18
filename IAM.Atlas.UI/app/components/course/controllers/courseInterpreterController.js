(function () {

    'use strict';

    angular
        .module('app')
        .controller("CourseInterpreterCtrl", CourseInterpreterCtrl);

    CourseInterpreterCtrl.$inject = ["$scope", "ModalService"];

    function CourseInterpreterCtrl($scope, ModalService) {



        /**
         * Display the add course modal
         */
        $scope.addCourseInterpreter = function (courseData) {

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
                title: "Add Course Interpreter",
                cssClass: "addCourseInterpreterModal",
                filePath: "/app/components/course/addCourseInterpreter.html",
                controllerName: "AddCourseInterpreterCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };


        $scope.removeCourseInterpreter = function () {
            console.log("Fiired Modal for remove course Interpreter.");
        };






    }

})();

