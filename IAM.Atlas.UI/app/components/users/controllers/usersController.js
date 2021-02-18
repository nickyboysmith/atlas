(function () {
    'use strict';

    angular
        .module('app')
        .controller('UsersCtrl', UsersCtrl);

    UsersCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'ModalService', 'activeUserProfile'];

    function UsersCtrl($scope, $location, $window, $http, UserService, ModalService, activeUserProfile) {

        /*
        * Variables below to be retrieved fom the passed-in scope
        */
        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;
            }
        }
        $scope.userId = activeUserProfile.UserId;

        var once = false;
        $scope.organisations = {};
        $scope.users;
        $scope.selectedUser;
        $scope.itemsPerPage = 5;
        $scope.isAdmin = false;        
        $scope.administrators = true;
        $scope.trainers = true;
        $scope.systemAdministrators = false;
        $scope.clients = false;
        $scope.systemUsers = true;
        $scope.disabled = false;
        $scope.searched = false;

        $scope.userService = UserService;
        $scope.isAdmin = $scope.userService.checkSystemAdminUser($scope.userId);

        $scope.getUsers = function (orgID) {

            $scope.searched = true;

            if (orgID > 0) {
                $scope.organisationId = orgID;
            }

            $scope.processing = true;
            //Show the whirlygig
            $scope.showSearchSign();
            $scope.userService.getFilteredUsers(
                        $scope.organisationId,
                        $scope.userId,
                        $scope.administrators,
                        $scope.trainers,
                        $scope.systemAdministrators,
                        $scope.clients,
                        $scope.systemUsers,
                        $scope.disabled
                        )
                        .then(
                            function (data) {
                                $scope.users = data;
                                $scope.usersTemplate = [].concat($scope.users);
                                //Hide the whirlygig
                                $scope.hideSearchSign();
                            },
                            function (data) {
                                errorMessage = 'Error retrieving user list';
                                successMessage = '';
                            });
        } // close

        //Show the loading gif and hide the results markup
        $scope.showSearchSign = function () {
            $("#userResultsRow").hide();
            $("#usersLoadingRow").fadeIn();
            
        }

        $scope.hideSearchSign = function () {
            $("#usersLoadingRow").hide();
            $("#userResultsRow").fadeIn();
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
                    $scope.getUsers();
                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        } // Close
        
        $scope.refreshUsers = function () {
            $scope.getUsers();
        }; //Close

        $scope.selectUser = function (UserID) {
            $scope.selectedUser = UserID;
        }; //Close

        $scope.showUser = function (UserID) {
            $scope.selectedUser = UserID;
            $scope.updateUsers($scope.selectedUser);
        }; //Close

        $scope.createUser = function () {
            $scope.updateUsers(0);
        }; //Close

        $scope.editUser = function () {

            if ($scope.selectedUser > 0) {
                $scope.selectedUserId = $scope.selectedUser;
                ModalService.displayModal({
                    scope: $scope,
                    title: "Edit User",
                    cssClass: "editUserModal",
                    filePath: "/app/components/users/edit.html",
                    controllerName: "EditUserCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });
            }
            else {
                alert('Please select a User before editing, click "Add New" to add a new User.');
            }
        }; //Close

        $scope.updateUsers = function (UserID) {

            if(UserID > 0)
            {
                $scope.selectedUserId = UserID;
                ModalService.displayModal({
                    scope: $scope,
                    title: "View User",
                    cssClass: "viewUserModal",
                    filePath: "/app/components/users/view.html",
                    controllerName: "ViewUserCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });
            }
            else
            {
                $scope.selectedUserId = -1;
                ModalService.displayModal({
                    scope: $scope,
                    title: "Add User",
                    cssClass: "addUserModal",
                    filePath: "/app/components/users/add.html",
                    controllerName: "AddUserCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });
            }
            //Open the User edit modal, passing in the User id

        }

        $scope.requestPasswordChange = function (user) {
            ChangePasswordRequestService.sendPasswordChangeToWebAPI(user)
                    .then(
                            function (data) {
                                $scope.successMessage = data;
                            }
                            ,
                            function (data) {
                                $scope.errorMessage = "An error occured. Please contact your administrator.";
                            }
                     );
        }

        $scope.getOrganisations($scope.userId);
    }
})();