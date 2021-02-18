(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ChangePasswordCtrl', ChangePasswordCtrl);

    ChangePasswordCtrl.$inject = ['PasswordValidationService', 'OrganisationListService', 'PasswordChangeService', '$scope', '$location', '$window', /*'noCAPTCHA',*/ 'activeUserProfile', '$http'];

    function ChangePasswordCtrl(PasswordValidationService, OrganisationListService, PasswordChangeService, $scope, $location, $window, /*noCAPTCHA,*/ activeUserProfile, $http) {

        //$scope.captchaControl = {};
        //$scope.resetCaptcha = function(){
        //    if(captchaControl.reset){
        //        captchaControl.reset();
        //    }
        //};
        $scope.passwordChangeService = PasswordChangeService;
        $scope.hideChangeButton = false;

        $scope.$root.title = 'IAM.Atlas | Change Password';

        /**
            * Set the base variables
            * So when the change password controller is la
            */
        $scope.validatedClass = "";
        $scope.validatedText = "";
        $scope.passwordMatchMessage = "";

        /**
         * Set organisation object
         */
        $scope.organisation = {};
        $scope.userId = activeUserProfile.UserId;

        if ($scope.userId > 0) {
            PasswordChangeService.getUserPasswordDetails($http, $scope.userId).then
            (
                function (response) {
                    $scope.organisation.loginID = response.data.LoginId;
                }
                ,
                function () {
                    console.log('Getting the user details failed.');
                }
            );
        }


        /**
         * Change the User's password process here
         */
        $scope.processChangePassword = function () {
            //$scope.organisation.gRecaptchaResponse = $('#reCaptchaResponse').attr('value')

            PasswordChangeService.processChange($scope.organisation, $scope.validatedClass, $http)
            .then
                (
                   function successCallback(response) {
                       var changePassword = response.data;
                       if (changePassword == 'success') {
                           $scope.passwordMatchMessage = "Password Change Successful";
                           $scope.hideChangeButton = true;
                       } else {
                           $scope.passwordMatchMessage = "Password Change Failed";
                       }
                   }
                   ,
                   function errorCallback() {
                       $scope.passwordMatchMessage = "Password Change Failed";
                   })
        };

        /**
         * Keyup event for the password validation
         */
        $scope.validatePasswordStrength = function ($event) {
            $scope.password = $event.target.value;

            /**
             * Called the PasswordValidationService
             * /app/components/changePassword/services/passwordValidationService
             */
            var passwordValidation = PasswordValidationService.passwordValidator($scope.password);
            $scope.validatedClass = passwordValidation.validatedClass;
            $scope.validatedText = passwordValidation.text;
        };

        /**
         * Key up method for the 
         */
        $scope.passwordsMatch = function ($event) {

            $scope.passwordMatchMessage = "";

            if ($scope.organisation.confirmPassword != undefined && $scope.organisation.newPassword !== $scope.organisation.confirmPassword && $scope.organisation.confirmPassword.length > 0) {
                $scope.passwordMatchMessage = "Passwords don't match";
            }
        };

    }

})();


