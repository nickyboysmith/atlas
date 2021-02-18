(function () {
    'use strict';


    angular
       .module('app')
       .controller('AdminMenuCtrl', AdminMenuCtrl);

    AdminMenuCtrl.$inject = ['$scope', '$timeout', '$location', '$window', '$http', 'AdministrationMenuService', 'UserService', 'ModalService', 'activeUserProfile']


    function AdminMenuCtrl($scope, $timeout, $location, $window, $http, AdministrationMenuService, UserService, ModalService, activeUserProfile) {

        $scope.administrationMenuService = AdministrationMenuService;
    
        $scope.menuGroups = {};
        $scope.menuItems = {};
        $scope.menuItemDetails = {};
        $scope.selectedMenuGroup = "-1";
        $scope.selectedMenuItem = null;
       
        $scope.getAdminMenuGroups = function () {

            $scope.userId = activeUserProfile.UserId;

            $scope.administrationMenuService.getAdminMenuGroups($scope.userId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response);
                        $scope.menuGroups = response;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(reponse);
                    }
                );

        }
        
        $scope.selectAdminMenuItems = function (selectedMenuGroup) {

            $scope.selectedMenuGroup = selectedMenuGroup;
            
            // reset Selected Menu Item
            $scope.selectedMenuItem = null;

            // reset Menu Item Details
            $scope.menuItemDetails = {};
           
            $scope.administrationMenuService.getAdminMenuItems($scope.selectedMenuGroup)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response);
                        $scope.menuItems = response;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        
        $scope.selectAdminMenuItemDetails = function (selectedMenuItem) {

            $scope.selectedMenuItem = selectedMenuItem;

            $scope.administrationMenuService.getAdminMenuItemDetails($scope.selectedMenuItem)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response);
                        $scope.menuItemDetails = response[0];
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }


        $scope.saveAdminMenuDetails = function () {
           
            // add selectedMenuGroup and selectedMenuItem 
            $scope.menuItemDetails.selectedMenuGroup = $scope.selectedMenuGroup;
            $scope.menuItemDetails.selectedMenuItem = $scope.selectedMenuItem;


            $scope.administrationMenuService.saveAdminMenuItemDetails($scope.menuItemDetails)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response);
                        $scope.refreshMenuItems(response);
                        $scope.successMessage = "Save Sucessful";
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

        $scope.refreshMenuItems = function (selectedMenuItem) {

                // Set the Selected Menu Item
                $scope.selectedMenuItem = selectedMenuItem;
                $scope.menuItemDetails.Id = selectedMenuItem;

                $scope.administrationMenuService.getAdminMenuItems($scope.selectedMenuGroup)
                    .then(
                    function (response) {
                        console.log("Success");
                        console.log(response);
                        $scope.menuItems = response;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
            }

        /**
         * Open the add menu group modal
         */
        $scope.openAddMenuGroupModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Menu Group",
                closable: true,
                filePath: "/app/components/adminMenu/addAdminMenuGroup.html",
                controllerName: "addAdminMenuGroupCtrl",
                cssClass: "addAdminMenuGroupModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };


        $scope.refreshAdminMenuGroup = function () {
            $scope.administrationMenuService.getAdminMenuGroups($scope.userId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.menuGroups = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        $scope.addAdminMenuDetails = function () {

            // reset Menu Item Details
            $scope.menuItemDetails = {};
            
        }

        $scope.getAdminMenuGroups();
    }
})();


