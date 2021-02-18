(function () {
    'use strict';

    angular
        .module('app')
        .controller('AddUserCtrl', AddUserCtrl);

    AddUserCtrl.$inject = ["$scope", "$filter", "UserService", "UserFactory", "activeUserProfile", "ModalService", "ReferringAuthorityService"];

    function AddUserCtrl($scope, $filter, UserService, UserFactory, activeUserProfile, ModalService, ReferringAuthorityService) {
        
        $scope.isSystemAdmin = false;

        /**
         * 
         */
        $scope.successMessage = "";
        $scope.errorMessage = "";

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.rolesDisabled = false;

        /**
         * Initailize the scope user 
         * Empty object
         */
        $scope.user = {};

        $scope.referringAuthorities = [];

        /**
         * Set the userId on the scope from the activeUserProfile
         */
        $scope.user.Id = activeUserProfile.UserId;

        /**
         * Check to see if the use is a system admin
         */
        UserService.checkSystemAdminUser(activeUserProfile.UserId)
        .then(
            function (data) {

                /**
                 * If the user is a systems adminstrator
                 * Set the organisations on the orgList
                 */
                if (data === true) {
                    $scope.organisationList = activeUserProfile.OrganisationIds;
                    //$scope.initialRoles = [
                    //    "Organisation System User",
                    //    "Organisation Trainer",
                    //    "Organisation Administrator",
                    //    "Atlas System Admin",
                    //    "Organisation Client"
                    //];
                    $scope.initialRoles = [
                       "Organisation System User",
                       "Organisation Trainer",
                       "Organisation Administrator",
                       "Atlas System Admin"
                    ];
                    $scope.isSystemAdmin = true;

                    if (angular.isDefined($scope.$parent.organisationId)) {

                        //Filter out selected Organisation
                        var selectedOrganisation = $filter("filter")($scope.organisationList, {
                            Id: $scope.$parent.organisationId
                        }, true);
                       
                        $scope.user.organisation = selectedOrganisation[0];
                    }
                   
                    $("#organistionSelection").show();
                }

                /**
                 * If user is not a system adminstrator
                 * then set a different set of roles
                 * place the org on the user object
                 */
                if (data === false) {
                    $scope.isSystemAdmin = false;
                    $scope.user.organisation = activeUserProfile.OrganisationIds[0];
                    //$scope.initialRoles = [
                    //    "System User",
                    //    "Trainer",
                    //    "Administrator",
                    //    "Client"
                    //];
                    $scope.initialRoles = [
                        "System User",
                        "Trainer",
                        "Administrator"
                    ];
                }

                /**
                 * Set the user role
                 * As the first initial Role
                 */
                $scope.user.role = $scope.initialRoles[0];

                // are we editing a User?
                if($scope.selectedUserId > 0) {
                    UserService.get($scope.selectedUserId)
                        .then(
                            function (data) {
                                
                                var user = data;
                                $scope.user.name = user.Name;
                                $scope.user.email = user.Email;
                                $scope.user.emailConfirm = user.Email;
                                $scope.user.phone = user.Phone;
                                $scope.user.organisation = $scope.organisationId;

                                // is the user a system admin user?
                                if ($scope.isSystemAdmin == true) {
                                    if (user.SystemAdminUsers.length > 0) {
                                        $scope.user.role = "Atlas System Admin";
                                    }
                                    else if(user.Trainers.length > 0) {
                                        $scope.user.role = "Organisation Trainer";
                                    }
                                    else if (user.OrganisationAdminUsers.length > 0) {
                                        $scope.user.role = "Organisation Administrator";
                                    }
                                    //else if (user.Clients.length > 0) {
                                    //    $scope.user.role = "Organisation Client";
                                    //}
                                    else if(user.OrganisationUsers.length > 0) {
                                        $scope.user.role = "Organisation System User";
                                    }
                                }
                                else {
                                    if(user.Trainers.length > 0) {
                                        $scope.user.role = "Trainer";
                                    }
                                    else if(user.OrganisationAdminUsers.length > 0) {
                                        $scope.user.role = "Administrator";
                                    }
                                    //else if(user.Clients.length > 0) {
                                    //    $scope.user.role = "Client";
                                    //}
                                    else if(user.OrganisationUsers.length > 0) {
                                        $scope.user.role = "System User";
                                    }
                                }
                            },
                            function (data) {
                                
                            }
                        );
                }
        }, function (data) {

        });

        /**
         * Add the user
         */
        $scope.addUser = function () {

            $scope.validated = $scope.validateFormFields();
            if ($scope.validated.length > 0) {
                console.log($scope.validated);
                return false;
            }

            /**
             * Transform the role creation
             */
            $scope.user.role = UserFactory.getRole($scope.user.role);

            /* The user who is adding this user */
            $scope.user.addedByUserId = activeUserProfile.UserId;

            /**
             * Call the service to add the
             * User to the db 
             */
            UserService.add($scope.user)
                .then(function (data) {

                    /**
                     * All errors are returned as strings
                     * An object is only returned 
                     * if the add user process was successful
                     */
                    var isObject = angular.isObject(data);

                    /**
                     * If isObject is true
                     * The web api has return an object
                     * The process was successful
                     */
                    if (isObject === true) {
                        console.log("Loop through the available Options");

                        var theCssClass = "";

                        /**
                         * Empty the user object to prevent resubmissions
                         */
                        $scope.name = $scope.user.name;
                        $scope.user.name = undefined;
                        $scope.user.email = undefined;
                        $scope.user.emailConfirm = undefined;
                        $scope.user.phone = undefined;
                        $scope.user.organisation = $scope.organisationId;

                        /**
                         * If the userRole is the Trainer
                         */
                        if (data.UserRole === "trainer") {

                            theCssClass = "addTrainerFromUserModal";
                            $scope.closeTheActiveModal = theCssClass;
                            $scope.trainerId = data.Id;
                            ModalService.displayModal({
                                scope: $scope,
                                title: "Update Trainer - " + $scope.name,
                                cssClass: theCssClass,
                                filePath: "/app/components/trainer/about/view.html",
                                controllerName: "TrainerAboutCtrl",
                                buttons: {
                                    label: 'Close',
                                    cssClass: 'closeModalButton',
                                    action: function (dialogItself) {
                                        dialogItself.close();
                                    }
                                }
                            });
                        }

                        /**
                         * If the user added was the client
                         */
                        //if (data.UserRole === "client") {

                        //    theCssClass = "addClientFromUserModal";
                        //    $scope.closeTheActiveModal = theCssClass;
                        //    $scope.clientId = data.Id;
                        //    ModalService.displayModal({
                        //        scope: $scope,
                        //        title: "Update Client - " + $scope.name,
                        //        cssClass: theCssClass,
                        //        filePath: "/app/components/client/add.html",
                        //        controllerName: "addClientCtrl",
                        //        buttons: {
                        //            label: 'Close',
                        //            cssClass: 'closeModalButton',
                        //            action: function (dialogItself) {
                        //                dialogItself.close();
                        //            }
                        //        }
                        //    });
                        //}

                        /**
                         * If an organisation user, organisation system admin 
                         * or system admin was created. Display a success message on the modal.
                         */
                        if (
                            data.UserRole === "user" || 
                            data.UserRole === "administrator" ||
                            data.UserRole === "sytem_administrator"
                            )
                        {
                            console.log("Show a response message");
                        }

                        $scope.successMessage = "Your User has now been added successfully";

                        if ($scope.searched == true)
                        {
                            // refresh the search results of the parent modal.
                            if ($scope.user && $scope.user.organisation)
                            {
                                $scope.getUsers($scope.user.organisation.Id);
                            }
                        }
                    }

                    /**
                     * If isObject is true
                     * The web api has return a string
                     * Errors have been thrown
                     */
                    if (isObject === false) {

                        $scope.validationMessage = data;
                        console.log("Error message: " + data);
                    }



                }, function(data) {

                    $scope.validated = data;
                    console.log(data);
                });

        };

        /**
         * Close the current modal
         */
        $scope.cancelAddUser = function (modalClass) {
            ModalService.closeCurrentModal(modalClass);
        }

       
        $scope.validateFormFields = function () {
            var errorArray = [];

            console.log($scope.user.organisation);

            if ($scope.user.name === undefined || $scope.user.name === "") {
                errorArray.push("User name is empty");
            }

            if ($scope.user.email === undefined || $scope.user.email === "") {
                errorArray.push("Emails is empty");
            }
            
            if ($scope.user.role === undefined || $scope.user.role === "") {
                errorArray.push("Role hasn't been selected");
            }

            if ($scope.user.email !== $scope.user.emailConfirm) {
                errorArray.push("Emails don't match");
            }

            if ($scope.isReferringAuthoryUser == true && $scope.user.referringAuthorityId === "") {
                errorArray.push("Referring Authority hasn't been selected");
            }

            return errorArray;
        }

       
        $scope.setInitialRole = function (isReferringAuthorityUser) {
            if (isReferringAuthorityUser) {
                $scope.rolesDisabled = true;
                if ($scope.isSystemAdmin) {
                    $scope.user.role = "Organisation System User";
                }
                else {
                    $scope.user.role = "System User";
                }
            }
            else {
                $scope.rolesDisabled = false;
            }
        }

        $scope.getReferringAuthorities = function (organisation) {
           ReferringAuthorityService.getByOrganisation(organisation.Id)
            .then(
                function (data) {

                    $scope.referringAuthorities = data;
                    
		        },
                function (data) {

                }
            );
        }
        
    }

})();