(function () {

    'use strict';
    
    angular
        .module('app.controllers')
        .controller('MessagingCtrl', MessagingCtrl);

    MessagingCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "ModalService", "MessagingService"];

    function MessagingCtrl($scope, $location, $window, $http, UserService, activeUserProfile, ModalService, MessagingService) {

        $scope.messagingService = MessagingService;

        $scope.userId = activeUserProfile.UserId;
        $scope.selectedUserId;
        $scope.userService = UserService;

        $scope.userLevel = [{
            name: 'All',
            checked: false,
            column:'All'
        }, {
            name: 'Trainers Only',
            checked: false,
            column: 'IsTrainer'
        }, {
            name: 'All Colleagues',
            checked: false,
            column: 'IsOrgUser'
        }, {
            name: 'Support Staff',
            checked: false,
            column: 'IsSupportStaff'
        }, {
            name: 'Administrators',
            checked: false,
            column: 'IsSystemAdministrator'
        }, {
            name: 'Individual',
            checked: false,
            column: 'Individual'
        }]


        $scope.messageCategories = {};
        $scope.userNames = {};
        $scope.messageWrapper = {};
        

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

       
        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
            
        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;
                
            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (data) {
                    $scope.isAdmin = data;
                });
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                    //$scope.getUsers();
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        } 


        $scope.getMessageCategories = function () {

            $scope.messagingService.getMessageCategories()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.messageCategories = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        $scope.getUserDetail = function (OrganisationId) {

            $scope.messagingService.getUserDetails(OrganisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.userNames = response.data;
                        $scope.selectedUserName = "";
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        $scope.send = function () {

            if ($scope.validateForm()) {

                $scope.messageWrapper.OrganisationId = $scope.organisationId;
                $scope.messageWrapper.CategoryId = $scope.categoryId;
                $scope.messageWrapper.UserId = $scope.selectedUserId
                $scope.messageWrapper.CreatedByUserId = $scope.userId

                var checkeditem = $scope.checkSelection()

                $scope.messageWrapper.UserLevel = $scope.userLevel[checkeditem].column;

                $scope.messagingService.send($scope.messageWrapper)
                        .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);

                                $scope.successMessage = "Message sent.";
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


        $scope.selectMessageCategory = function (CategoryId) {
            $scope.categoryId = CategoryId;
        }

        $scope.selectedItem = function (selectedUser) {
            $scope.selectedUserId = selectedUser.UserId;
        }

        $scope.getUserDetailByOrganisation = function (OrganisationId) {

            
            $scope.searchContent = '';
            $scope.organisationId = OrganisationId
            $scope.getSearchableItems($scope.searchContent);
            
        }

        //TODO Clear out the selected on change to organisation
        $scope.$watch('organisationId', function (newValue, oldValue) {
            $scope.selected = "";
        })

        $scope.updateSelection = function (position, entities) {
            angular.forEach(entities, function (level, index) {
                if (position != index)
                    level.checked = false;
            });
        }

        $scope.checkSelection = function (position, entities) {
            var checkeditem = -1;
            angular.forEach($scope.userLevel, function (level, index) {
                if (level.checked == true)
                    checkeditem = index;


            });
            return checkeditem;
        }

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            if (angular.isUndefined($scope.messageWrapper.Message)) {
                $scope.validationMessage = "Message needs to be at least 6 characters long. ";
            }
            else if ($scope.messageWrapper.Message.length < 6) {
                $scope.validationMessage = "Message needs to be at least 6 characters long. ";
            }

            if ($scope.categoryId == "" || (angular.isUndefined($scope.categoryId))) {
                $scope.validationMessage = $scope.validationMessage + "Please select a message Category. ";
            }
           
            if ($scope.userLevel[5].checked && (angular.isUndefined($scope.selectedUserId))) {
                $scope.validationMessage = $scope.validationMessage + "Please select an Individual User recipient. ";
            }

            if ($scope.checkSelection() == -1) {
                $scope.validationMessage = $scope.validationMessage + "Please select the level of User to send.";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getSearchableItems = function (searchContent) {

            $scope.searchContent = searchContent;

            return $scope.messagingService.getUserDetails($scope.organisationId, $scope.searchContent);
        };

        $scope.getOrganisations($scope.userId);
        $scope.getMessageCategories();
        
    }

})();