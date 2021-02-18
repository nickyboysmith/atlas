(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('InterpreterLanguageCtrl', InterpreterLanguageCtrl);

    InterpreterLanguageCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'InterpreterLanguageService'];

    function InterpreterLanguageCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, InterpreterLanguageService) {

       
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.selectedLanguage = {
            selectedLanguageId: ""
        };

        $scope.interpreterLanguages = {};
        $scope.interpreterNames = {};
       
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

        $scope.setSelectedInterpreter = function (interpreterId) {

            $scope.selectValidationMessage = "";
            $scope.selectedInterpreter = interpreterId;
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        //Get Interpreter Languages
        $scope.getInterpreterLanguagesByOrganisation = function (organisationId) {

            $scope.organisationId = organisationId;

            InterpreterLanguageService.getLanguagesByOrganisation(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.interpreterLanguages = response.data;

                        $scope.ALLItem = {
                            LanguageId: null,
                            LanguageName: "ALL"
                        };

                        $scope.interpreterLanguages.unshift($scope.ALLItem);

                        //$scope.interpreterLanguages.push($scope.ALLItem);

                        $scope.selectedLanguage.selectedLanguageId = $scope.interpreterLanguages[0].LanguageId;
                        $scope.getInterpreterNamesByOrganisationLanguage($scope.selectedLanguage.selectedLanguageId);
                      
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }


        //Get Interpreter Names and Languages
        $scope.getInterpreterNamesByOrganisationLanguage = function (LanguageId) {

            
            $scope.selectValidationMessage = "";

            $scope.selectedLanguage.selectedLanguageId = LanguageId;
           
            InterpreterLanguageService.getInterpreterNamesByOrganisationLanguage($scope.organisationId, LanguageId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.interpreterNames = response.data;

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        /**
         * Open the add interpreter modal
         */
        $scope.openAddInterpreterModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add Interpreter",
                closable: true,
                filePath: "/app/components/interpreterLanguage/add.html",
                controllerName: "AddInterpreterLanguageCtrl",
                cssClass: "AddInterpreterLanguageModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        /**
         * Open the edit interpreter modal
         */
        $scope.openEditInterpreterModal = function () {



            if ($scope.selectedInterpreter) {

                ModalService.displayModal({
                    scope: $scope,
                    title: "Interpreter Details",
                    closable: true,
                    filePath: "/app/components/interpreterLanguage/update.html",
                    controllerName: "EditInterpreterLanguageCtrl",
                    cssClass: "EditInterpreterLanguageModal",
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

                $scope.selectValidationMessage = "Please select an Interpreter to Edit."


            }
        };

        $scope.getOrganisations($scope.userId);
        $scope.getInterpreterLanguagesByOrganisation($scope.organisationId);
    }

})();