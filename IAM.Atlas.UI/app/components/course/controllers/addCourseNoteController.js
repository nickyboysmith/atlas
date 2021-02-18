(function () {
    'use strict';

    angular
        .module('app')
        .controller('addCourseNoteCtrl', addCourseNoteCtrl);

    addCourseNoteCtrl.$inject = ['$scope', '$location', '$window', '$http', 'activeUserProfile']

    function addCourseNoteCtrl($scope, $location, $window, $http, activeUserProfile) {

        $scope.noteSaved = false;
        $scope.courseNote = {};
        $scope.noteTypes = {};
        $scope.courseNote.OrganisationOnly = false;
        $scope.trainerSite = false;

        /**
         * Check to see if the courseId does not exist 
         * On the parent
         */
        if ($scope.$parent.courseId === undefined) {
            $scope.courseNote.CourseId = $scope.course.courseId;
        }

        /**
         * If the course Id exists on the parent
         */
        if ($scope.$parent.courseId !== undefined) {
            $scope.courseNote.CourseId = $scope.$parent.courseId;
        }

        if ($scope.$parent.trainerSite) {
            if ($scope.$parent.trainerSite == true) {
                $scope.trainerSite = true;
            }
        }

        /**
         * Set the user Id on the activeProfileUser object
         */
        $scope.courseNote.UserId = activeUserProfile.UserId;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;


        $scope.saveNote = function () {
            $http.post(apiServer + '/coursenote/', $scope.courseNote)
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    //$('.savesuccess').fadeIn("slow").delay(1500).fadeOut("slow")
                    $scope.showSuccessFader = true; 

                    

                    /**
                     * Check to see if the courseId does not exist 
                     * On the parent, refresh the notes
                     * NOTE: Where is this method { $scope.refreshNotes }
                     */
                    if ($scope.refreshNotes) {
                        $scope.refreshNotes();
                    }

                    /**
                     * If the courseId exists
                     * Refreesh notes for the selected course
                     * On the parent scope
                     */
                    if ($scope.$parent.courseId !== undefined) {
                        if ($scope.refreshCourseNotes) {
                            $scope.refreshCourseNotes($scope.$parent.courseId);
                        }
                    }

                    $scope.validationMessage = "Success.";
                    $scope.noteSaved = true;
                }, function (data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.

                    //$('.savesuccess').fadeIn("slow").delay(1500).fadeOut("slow")
                    $scope.showErrorFader = true;

                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.loadCourseDetails = function (courseId) {

            $http.get(apiServer + '/course/' + courseId)
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available
                    $scope.course = data;
                    $scope.validationMessage = "Success.";
                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.loadNoteTypes = function () {
            $http.get(apiServer + '/CourseNote/GetTypes')
                .then(function (response, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    $scope.noteTypes = response.data;
                    $scope.courseNote.NoteTypeId = $scope.noteTypes[0].Id;
                    // $scope.validationMessage = "Success.";

                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }
        //$scope.loadCourseDetails($scope.course.courseId);
        

        $scope.loadNoteTypes();

    }



})();