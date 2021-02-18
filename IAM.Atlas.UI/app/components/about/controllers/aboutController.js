(function () {
    'use strict';

    angular
       .module('app')
       .controller('AboutCtrl', AboutCtrl);

    AboutCtrl.$inject = ['$scope', '$location', '$window', '$http', '$compile', 'ModalService', 'SystemControlService']

    function AboutCtrl($scope, $location, $window, $http, $compile, ModalService, SystemControlService) {

        $scope.$root.title = 'IAM.Atlas | About';
        $scope.modalService = ModalService;
        
        SetupClickEvents($scope, $compile);

        $scope.DisplayFeedback = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Page Feedback",
                cssClass: "feedback",
                filePath: "/app/components/feedback/view.html",
                controllerName: "FeedBackCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });

        }

        $scope.DisplayHelp = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Help + Support",
                cssClass: "help",
                filePath: "/app/components/help/view.html",
                controllerName: "HelpCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });

        }


        function SetupClickEvents($scope, $compile) {
            $scope.ShowAboutItem = function (title, url, controller) {
                //debugger;
                BootstrapDialog.show({
                    scope: $scope,
                    title: title,
                    closable: true,
                    closeByBackdrop: false,
                    closeByKeyboard: true,
                    draggable: true,
                    cssClass: "AtlasModal",
                    message: function (dialog) {
                        var pageToLoad = dialog.getData('pageToLoad');
                        return $compile('<div ng-app="app" ng-controller="' + controller + '" ng-include="\'' + pageToLoad + '.html\'"></div>')($scope);
                    },
                    data: {
                        'pageToLoad': url
                    }
                });
            }
        }

        $scope.getSystemControlSettings = function () {

                SystemControlService.Get()
                    .then(
                        function (response) {
                            console.log("Success");
                            console.log(response.data);
                            $scope.systemControl = response.data;

                            $scope.systemControl.ApplicationVersionPart4 = $scope.systemControl.ApplicationVersionPart4.toFixed(2);
                            $scope.systemControl.DatabaseVersionPart4 = $scope.systemControl.DatabaseVersionPart4.toFixed(2);

                        },
                        function (response) {
                            console.log("Error");
                            console.log(response);
                        }
                    );

            
        }

        $scope.getBrowserSettings = function () {

            SystemControlService.GetBrowserAndOS()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.systemInfo = response.data;

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );


        }

        $scope.getSystemControlSettings();
        $scope.getBrowserSettings();
    
    }

})();
