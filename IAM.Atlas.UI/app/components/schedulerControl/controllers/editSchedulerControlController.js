(function () {

    'use strict';
    
    angular
        .module('app.controllers')
        .controller('SchedulerControlCtrl', SchedulerControlCtrl);

    SchedulerControlCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "SchedulerControlService"];

    function SchedulerControlCtrl($scope, $location, $window, $http, UserService, activeUserProfile, SchedulerControlService) {

        $scope.schedulerControlService = SchedulerControlService;
        
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.schedulerControl = {};
        
        //$scope.isAdmin = false;

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );



        //Get ScheduerControl Settings
        $scope.getSchedulerControl = function () {

            $scope.schedulerControlService.Get()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.schedulerControl = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Save ScheduerControl Settings
        $scope.save = function (UpdatedColumn, value) {

         
            //if ($scope.isAdmin == true) {

                $scope.updateObject = {
                    FieldToUpdate: UpdatedColumn,
                    Value: value,
                    UserId: $scope.userId
                };


            $scope.schedulerControlService.Save($scope.updateObject)
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
            //}
            //else
            //{
            //    $scope.validationMessage = "User is not an Admin";
            //}
        }


        $scope.selectAll = function () {
            // Loop through all the entities and set their isChecked property
            for (var i = 0; i < model.entities.length; i++) {
                model.entities[i].isChecked = model.allItemsSelected;
            }
        };


        $scope.getSchedulerControl();

    }

})();