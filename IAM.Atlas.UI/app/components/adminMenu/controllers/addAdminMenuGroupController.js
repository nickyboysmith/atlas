(function () {
    'use strict';





    
    angular
       .module('app')
       .controller('addAdminMenuGroupCtrl', addAdminMenuGroupCtrl);

    addAdminMenuGroupCtrl.$inject = ['$scope', '$location', '$window', '$http', 'AdministrationMenuService', 'ModalService', ]


    function addAdminMenuGroupCtrl($scope, $location, $window, $http, AdministrationMenuService,  ModalService) {

        $scope.administrationMenuService = AdministrationMenuService;


        $scope.menuGroup = {};

        $scope.saveAdminMenuGroup = function () {

            $scope.administrationMenuService.saveAdminMenuGroup($scope.menuGroup)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);

                        $scope.refreshAdminMenuGroup();
                        ModalService.closeCurrentModal("addAdminMenuGroupModal");
                        //$scope.successMessage = "Save Sucessful";
                        //$scope.validationMessage = "";
                    },
                    function (response) {
                        console.log("Error");
                        console.log(reponse);
                        //$scope.successMessage = "";
                        //$scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }
    }
})();