(function () {
    'use strict';

    angular
        .module('app')
        .controller('ClientsCtrl', ['$scope', '$location', '$window', '$http', '$compile', ClientsCtrl]);


    function ClientsCtrl($scope, $location, $window, $http, $compile) {

        var once = false;
        $scope.itemsPerPage = 10;

        $scope.getClients = function () {
            $scope.processing = true;
            $http.get(apiServer + '/client')
                .then(function (response, status, headers, config) {
                    $scope.clients = response.data;
                    if (!once) {
                        // give "smart-table" a table data template that won't change so it can maintain the structure while refreshing the data with an ajax call
                        // passed in to the table tag via the attribute "st-safe-src"
                        $scope.clientsTemplate = [].concat($scope.clients);
                        once = true;
                    }
                }, function(response, status, headers, config) {
                    alert('Error retrieving client list');
                });
        }
        $scope.getClients();

        $scope.ShowMenuItem = function (title, url, controller, enabled, modal) {
            if (enabled == 'true') {
                if (modal == 'true') {
                    BootstrapDialog.show({
                        scope: $scope,
                        title: title,
                        closable: true,
                        closeByBackdrop: false,
                        closeByKeyboard: false,
                        draggable: true,
                        cssClass: "AtlasModal",
                        message: function (dialog) {
                            var pageToLoad = dialog.getData('pageToLoad');
                            return $compile('<div ng-app="app" ng-controller="' + controller + '" ng-include="\'' + pageToLoad + '\'"></div>')($scope);
                        },
                        data: {
                            'pageToLoad': url,
                        }
                    });
                } else {
                    $location.url(url);
                }
            }
        }

        $scope.showDetails = function (clientId) {
            // open client details Modal
            $scope.clientId = clientId;
            $scope.ShowMenuItem('Client Details', '/app/components/client/cd_view.html', 'clientDetailsCtrl', 'true', 'true');
        }

        $scope.addClientModal = function() {
            $scope.ShowMenuItem('Add client', '/app/components/client/add.html', 'addClientCtrl', 'true', 'true');
        }
    }
})();