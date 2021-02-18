(function () {
    'use strict';

    angular
        .module('app')
        .controller('addTrainerNoteCtrl', ['$scope', '$timeout', '$location', '$window', '$http', addTrainerNoteCtrl]);


    function addTrainerNoteCtrl($scope, $timeout, $location, $window, $http) {


        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;
        $scope.noteSaved = false;
        $scope.trainerNote = new Object();
        $scope.noteTypes = new Object();
        $scope.trainerNote.TrainerId = $scope.$parent.trainerId;
        
        $scope.trainerNote.UserId = 1;

        $scope.setFadeMessage = function (message, image, delay) {
            $scope.fadeMessage = message;
            $scope.fadeImage = image;
            $scope.showFadeSaveMessage = true;
            $timeout(function () { $scope.showFadeSaveMessage = false; }, delay);
        }


        $scope.saveNote = function () {
            $http.post(apiServer + '/trainernote/', $scope.trainerNote)
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    //$('.savesuccess').fadeIn("slow").delay(1500).fadeOut("slow")
                    $scope.showSuccessFader = true;

                    $scope.getNotes();

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

        $scope.loadTrainerDetails = function (trainerId) {

            $http.get(apiServer + '/trainer/' + trainerId)
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available
                    $scope.trainer = data;
                    $scope.validationMessage = "Success.";
                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.loadNoteTypes = function () {
            $http.get(apiServer + '/TrainerNote/GetTypes')
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    $scope.noteTypes = data;
                    $scope.trainerNote.NoteTypeId = $scope.noteTypes[0].Id;
                    $scope.validationMessage = "Success.";
                }, function(data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }
        //$scope.loadTrainerDetails($scope.trainer.trainerId);
        $scope.loadNoteTypes();

    }



})();