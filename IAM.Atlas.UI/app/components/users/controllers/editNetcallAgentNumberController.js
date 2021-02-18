(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('EditNetcallAgentNumberCtrl', EditNetcallAgentNumberCtrl);

    EditNetcallAgentNumberCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService'];

    function EditNetcallAgentNumberCtrl($scope, $location, $window, $http,  UserService) {

        // are we displaying from the edit or Add New
        if (angular.isUndefined($scope.$parent.fromAddNetcallAgent)) {

            $scope.netcallAgent = {
                Id: $scope.$parent.selectedAgent.Id,
                UserId: $scope.$parent.selectedAgent.UserId,
                DefaultCallingNumber: $scope.$parent.selectedAgent.DefaultCallingNumber,
                Disabled: $scope.$parent.selectedAgent.Disabled,
                UpdateByUserId: $scope.$parent.userId
            };
        }
        else {
            // from add
            $scope.netcallAgent = {
                Id: $scope.$parent.netcallAgent.Id,
                UserId: $scope.$parent.netcallAgent.UserId,
                DefaultCallingNumber: null,
                Disabled: false,
                UpdateByUserId: $scope.$parent.userId
            };
        }
        

        //Save Calling Number
        $scope.saveCallingNumber = function () {

            $scope.userService.saveNetcallAgentCallingNumber($scope.netcallAgent)
                .then(
                    function (data) {
                        console.log("Success");
                        console.log(data);

                        $scope.successMessage = "Save Successful";
                        $scope.validationMessage = "";

                        // refresh the Netcall Agents 
                        $scope.$parent.getNetcallAgentsByOrganisation($scope.$parent.organisationId);

                    },
                    function (data) {
                        console.log("Error");
                        console.log(data);

                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }
    }

})();