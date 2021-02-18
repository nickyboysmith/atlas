(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('HelpCtrl', HelpCtrl);

    HelpCtrl.$inject = ['$scope', '$location', '$window', '$http', '$compile', 'SystemService', 'ModalService'];

      

    function HelpCtrl($scope, $location, $window, $http, $compile, SystemService, ModalService) {
        
        $scope.$root.title = 'IAM.Atlas | Help';


        /* AddDORSConnectionCtrl - any valid controller for now */
        $scope.displayUnavailable = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Unavailable Feature",
                cssClass: "featureUnavailableModal",
                filePath: "/app/shared/core/featureUnavailable.html",
                controllerName: "AddDORSConnectionCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }

            });
        };

        $scope.displayUnavailable()


    }

})();