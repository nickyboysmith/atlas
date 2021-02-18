(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('AddLanguageCtrl', AddLanguageCtrl);

    AddLanguageCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ModalService', 'InterpreterLanguageService'];

    function AddLanguageCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ModalService, InterpreterLanguageService) {


        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.languages = {};

        //Set Selected Languages
        $scope.setSelectedLanguages = function (Language) {

            Language.isSelected ? Language.isSelected = false : Language.isSelected = true;

        }

        $scope.getLanguages = function () {
            InterpreterLanguageService.getLanguages()
                    .then(
                        function (response) {
                            $scope.languages = response.data;
                        },
                        function (response) {
                        }
                    );
        };

        //Add Selected Languages 
        $scope.addSelectedLanguages = function () {

            var language = {
                selectedLanguages: []
            };

            //Filter out Selected Emails for removal
            var selectedLanguages = $filter("filter")($scope.languages, {
                isSelected: true
            }, true);

            // Add to integer Array
            selectedLanguages.forEach(function (arrayItem) {
                //var x = arrayItem.Id
                language.selectedLanguages.push(arrayItem);
            });

            $scope.interpreter.Languages = language.selectedLanguages;

            //$scope.interpreter.Languages.Language = language.selectedLanguages;

            // close the window
            $scope.closeModal();

        }

        $scope.closeModal = function () {
            $('button.close').last().trigger('click');
        }


        $scope.HasSelectedLanguages = function () {

            if ($scope.languages.length > 0) {
                return false;
            }
            else {
                return true;
            }
        }

        $scope.getLanguages();

    }

})();