(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('FeedBackCtrl', ['$scope', '$location', '$window', '$http', 'SystemService', 'ModalService', 'UserService', 'activeUserProfile', FeedBackCtrl]);

    function FeedBackCtrl($scope, $location, $window, $http, SystemService, ModalService, UserService, activeUserProfile) {
        
        $scope.feedback = new Object();
        $scope.charsRemaining = 1000;
        $scope.feedbackSent = false;
        $scope.modalService = ModalService;
        $scope.userService = UserService;
        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.submitFeedback = function ()
        {    
            validateForm();

            if ($scope.validationMessage == "")
            {
                $scope.feedback.currentUrl = $location.$$absUrl;
                $scope.feedback.pageId = $location.$$path;
                $scope.feedback.loggedInUser = '';
                if ($window.navigator) {
                    $scope.feedback.currentBrowser = $window.navigator.userAgent;
                    $scope.feedback.currentOS = $window.navigator.platform;
                }
                //$scope.feedback.currentBrowser = SystemService.CurrentBrowser();
                //$scope.feedback.currentOS = SystemService.CurrentOperatingSystem();
                $scope.feedback.currentModals = $scope.modalService.getCurrentModals();
                $scope.feedback.userId = activeUserProfile.UserId;
                $scope.feedback.isAdmin = false;
                $scope.userService.checkSystemAdminUser($scope.feedback.userId)
                .then(function (response) {
                    $scope.feedback.isAdmin = JSON.parse(response);
                });


                $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

                $http.post(apiServer + '/feedback', $scope.feedback)
                .then(function (data) {
                    // this callback will be called asynchronously
                    // when the response is available
                    if(data.data.toLowerCase().indexOf("success") == 0)
                    {
                        $scope.showSuccessFader = true;

                        $scope.feedbackSent = true;
                    }
                    else
                    {
                        
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                }, function(data) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                    $scope.showErrorFader = true;
                });
            }
        }

        $scope.charsRemainingCount = function () {
            $scope.charsRemaining = 1000 - $scope.feedback.body.length;
        }

        function validateForm() 
        {
            $scope.validationMessage = '';

            if ($scope.feedback.title == '' || $scope.feedback.title == undefined)
            {
                $scope.validationMessage = 'Please enter a title';
            }
            else if ($scope.feedback.body == '' || $scope.feedback.body == undefined) {
                $scope.validationMessage = 'Please enter a query';
            }
            else if ($scope.feedback.body.length < 11 || $scope.feedback.body.split(" ").length < 3) {
                $scope.validationMessage = 'Please enter at least 11 characters in the comments field and more than two words.';
            }
            else if($scope.feedback.body.length > 1000)
            {
                $scope.validationMessage = 'Your query is more than 1000 characters.  Please trim your query.';
            }
            else if ($scope.feedback.responseRequired && ($scope.feedback.email == "" || $scope.feedback.email == undefined)) 
            {
                $scope.validationMessage = 'Please enter your email.';
            }
        }
    }
})();

