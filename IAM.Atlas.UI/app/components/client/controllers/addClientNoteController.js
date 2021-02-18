(function () {
    'use strict';

    angular
        .module('app')
        .controller('addClientNoteCtrl', ['$scope', '$timeout', '$location', '$window', '$http', 'activeUserProfile', addClientNoteCtrl]);


    function addClientNoteCtrl($scope, $timeout, $location, $window, $http, activeUserProfile) {

        $scope.noteSaved = false;
        $scope.clientNote = new Object();
        $scope.noteTypes = new Object();
        $scope.clientNote.ClientId = $scope.clientId;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        if($scope.clientNote.ClientId === undefined)
        {
            $scope.clientNote.ClientId = $location.search().clientid;
        }
        $scope.clientNote.UserId = activeUserProfile.UserId;

        $scope.setFadeMessage = function (message, image, delay) {
            $scope.fadeMessage = message;
            $scope.fadeImage = image;
            $scope.showFadeSaveMessage = true;
            $timeout(function () { $scope.showFadeSaveMessage = false; }, delay);
        }


        $scope.saveNote = function ()
        {
            $http.post(apiServer + '/clientnote/', $scope.clientNote)
                .then(function (data, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available
                   
                    if ($scope.loadNotes) $scope.loadNotes();

                    if ($scope.refreshNotes) {
                        $scope.refreshNotes($scope.clientId);
                    }

                    if ($scope.setFlagToRefreshClientHistory) {
                        $scope.setFlagToRefreshClientHistory();
                    }

                    //$('.savesuccess').fadeIn("slow").delay(1500).fadeOut("slow")
                    $scope.showSuccessFader = true;

                    $scope.validationMessage = "Success.";
                    $scope.noteSaved = true;
                }, function (data, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    
                    //$('.savesuccess').fadeIn("slow").delay(1500).fadeOut("slow")
                    $scope.showSuccessFader = true;

                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.loadClientDetails = function (clientId) {

           


            $http.get(apiServer + '/client/' + clientId)
                .then(function (response, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available
                    $scope.client = response.data;
                    $scope.validationMessage = "Success.";
                }, function (response, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }

        $scope.loadNoteTypes = function () {
            $http.get(apiServer + '/ClientNote/GetTypes')
                .then(function (response, status, headers, config) {
                    // this callback will be called asynchronously
                    // when the response is available

                    $scope.noteTypes = response.data;
                    $scope.clientNote.NoteTypeId = $scope.noteTypes[0].Id;
                    $scope.validationMessage = "Success.";

                }, function (response, status, headers, config) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.validationMessage = "An error occurred please try again.";
                });
        }
        $scope.loadClientDetails($scope.clientNote.ClientId);
        $scope.loadNoteTypes();

    }



})();