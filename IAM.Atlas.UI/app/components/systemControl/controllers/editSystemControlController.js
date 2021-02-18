(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('SystemControlCtrl', SystemControlCtrl);

    SystemControlCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "DorsConnectionDetailsService", "PaymentProviderService", "SystemControlService"];

    function SystemControlCtrl($scope, $location, $window, $http, UserService, activeUserProfile, DorsConnectionDetailsService, PaymentProviderService, SystemControlService) {

        $scope.systemControlService = SystemControlService;
        $scope.dorsConnectionDetailsService = DorsConnectionDetailsService;
        $scope.paymentProviderService = PaymentProviderService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.systemControl = {};
        $scope.defaultDORSConnections = {};
        $scope.defaultPaymentProviders = {};

        $scope.selectedDefaultDORSConnection = "";
        $scope.selectedDefaultPaymentProvider = "";

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        //Get SystemControl Settings
        $scope.getSystemControl = function () {

            $scope.systemControlService.Get()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.systemControl = response.data;


                        if (response.data.DefaultDORSConnectionId)
                        { $scope.selectedDefaultDORSConnection = response.data.DefaultDORSConnectionId; }
                        else
                        {
                            $scope.selectedDefaultDORSConnection = "";
                        }

                        

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Get Default DORS Connections and Organisation Name
        $scope.getDefaultDORSConnections = function () {

            $scope.dorsConnectionDetailsService.getDORSConnectionsOrganisationName()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.defaultDORSConnections = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        $scope.selectDefaultDORSConnection = function (selectedDefaultDORSConnection) {
            $scope.selectedDefaultDORSConnection = selectedDefaultDORSConnection;
        }

        //Get Default Payment Providers
        $scope.getDefaultPaymentProviders = function () {

            $scope.paymentProviderService.getPaymentProviders()
                .then(
                    function (data) {
                        console.log("Success");
                        console.log(data);
                        $scope.defaultPaymentProviders = data;

                        angular.forEach($scope.defaultPaymentProviders, function (value, key) {
                            if (value.Disabled == true)
                                $scope.defaultPaymentProviders[key].Name += " (Currently Disabled)"

                            if (value.SystemDefault == true)
                                $scope.selectedDefaultPaymentProvider = value.Id;
                        });

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        $scope.selectDefaultPaymentProvider = function (selectedDefaultPaymentProvider) {
            $scope.selectedDefaultPaymentProvider = selectedDefaultPaymentProvider;
        }


        //Save SystemControl Settings
        $scope.save = function () {

            if ($scope.isAdmin == true) {

                if ($scope.validateForm()) {
                
                    $scope.systemControl.DefaultDORSConnectionId = $scope.selectedDefaultDORSConnection;
                    $scope.systemControl.DefaultPaymentProviderId = $scope.selectedDefaultPaymentProvider;

                     $scope.systemControlService.Save($scope.systemControl)
                         .then(
                             function (response) {
                                 console.log("Success");
                                 console.log(response.data);
                                 $scope.successMessage = "Save Successful";
                                 $scope.validationMessage = "";
                             },
                             function (response) {
                                 console.log("Error");
                                 console.log(response);
                                 $scope.successMessage = "";
                                 $scope.validationMessage = "An error occurred please try again.";
                             }
                         );
                 }

            }
            else {
                    $scope.validationMessage = "User is not an Admin";
            }
        }

        $scope.isValidEmail = function (emailaddess) {

            //ref
            //http://stackoverflow.com/questions/46155/validate-email-address-in-javascript

            var emailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

            var validEmail = emailFormat.test(emailaddess);

            return validEmail;
        }

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (!$scope.isValidEmail($scope.systemControl.AtlasSystemFromEmail)) {
                $scope.validationMessage = "Invalid Atlas System Email Address";}

            if (!$scope.isValidEmail($scope.systemControl.FeedbackEmail)) {
                $scope.validationMessage = "Invalid Feedback Email Address";}
           
            var MinEmailsAtOnce = 10;
            var MaxEmailsAtOnce = 1000;
            var MinEmailsPerDay = 100;
            var MaxEmailsPerDay = 10000;

            var AtOnce = parseInt($scope.systemControl.MaxNumberEmailsToProcessAtOnce);
            var PerDay = parseInt($scope.systemControl.MaxNumberEmailsToProcessPerDay);
            
            if (!(AtOnce >= MinEmailsAtOnce && AtOnce <= MaxEmailsAtOnce)) {
                $scope.validationMessage = "Maximum Emails to Process at Once should be between " + MinEmailsAtOnce + " and " +  MaxEmailsAtOnce;}

            if (!(PerDay >= MinEmailsPerDay && PerDay <= MaxEmailsPerDay)) {
                $scope.validationMessage = "Maximum Emails to Process per Day should be between " + MinEmailsPerDay + " and " +  MaxEmailsPerDay;}
          
            if ($scope.selectedDefaultPaymentProvider == "") {
                $scope.validationMessage = "Please select a Default Payment Provider";
            }

            var MaxRotationHours = 168;
            var MinRotationHours = 0;
            var RotationHours = parseInt($scope.systemControl.HoursBetweenDORSConnectionRotation);

            if (!(RotationHours >= MinRotationHours && RotationHours <= MaxRotationHours)) {
                $scope.validationMessage = "Maximum DORS Default Connecton Rotation in Hours should be between  " + MinRotationHours + " and " + MaxRotationHours;
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }


        $scope.getDefaultDORSConnections();
        $scope.getDefaultPaymentProviders();
        $scope.getSystemControl();

    }

})();