'use strict';

// Google Analytics Collection APIs Reference:
// https://developers.google.com/analytics/devguides/collection/analyticsjs/

angular.module('app.controllers', [])


    // NavbarCtrl
    .controller('NavbarCtrl', ['$scope', '$location', '$window', function ($scope, $location, $window) {
        //$scope.$root.title = 'IAM.Atlas for Visual Studio';
        //$scope.$on('$viewContentLoaded', function () {
        //    $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        //});

        $scope.menuEntries = [
            { display: "Home", path: "/", iconClass: "home_icon", altText: "The home page" },
            { display: "Contacts", path: "/scriptlog/scriptlogdemo", iconClass: "contacts_icon", altText: "View Contacts" },
            { display: "Clients", path: "/about", iconClass: "clients_icon", altText: "View Clients" },
            { display: "Reports", path: "/menu1", iconClass: "reports_icon", altText: "View Reports" },
            { display: "Administration", path: "/menu2", iconClass: "admin_icon", altText: "View administration" }
        ];



    }])

    // Path: /
    .controller('HomeCtrl', ['$scope', '$location', '$window', function ($scope, $location, $window) {
        $scope.$root.title = 'IAM.Atlas for Visual Studio';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });
    }])

    // Path: /about
    .controller('AboutCtrl', ['$scope', '$location', '$window', function ($scope, $location, $window) {
        $scope.$root.title = 'IAM.Atlas | About';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });
    }])

    // Path: /login
    .controller('LoginCtrl', ['$scope', '$location', '$window', function ($scope, $location, $window) {
        $scope.$root.title = 'IAM.Atlas | Sign In';
        // TODO: Authorize a user
        $scope.login = function () {
            $location.path('/');
            return false;
        };
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });


        $scope.logMeIn = function (user) {
            $http.post('api/accounts/signin', user)
        .then(function (data, status, headers, config) {
            user.authenticated = true;
            $rootScope.user = user;
            $location.path('/');
        }, function (data, status, headers, config) {
            user.authenticated = false;
            $rootScope.user = {};
        });
        }
    }])

    // Path: /ScriptLog/ScriptLogDemo
    .controller('ScriptLogCtrl', ['$scope', '$location', '$window', '$http', function ($scope, $location, $window, $http) {
        $scope.$root.title = 'IAM.Atlas | Script Log';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });



        //$scope.getList = function () {
        //    //$scope.isProcessing = true;
        //    //debugger;
        //    //$http.get('api/ScriptLog/Get')
        //    ////$http.get('api/ScriptLog')
        //    //    .then(function (data, status, headers, config) {
        //    //        $scope.isProcessing = false;
        //    //        $scope.ScriptLog = data;
        //    //    })
        //    ////.error(function (data, status, headers, config) {
        //    ////    $scope.message = data.error_description.replace(/["']{1}/gi, "");
        //    ////    $scope.showMessage = true;
        //    ////});
        //    ////.error(function (error) { debugger; })
        //    ////.finally(function () { debugger; })
        //    ////;
        //    //;
        //    $scope.showMessage = true;
        //    //$scope.message = $location.path();

        //}

        //$scope.getList();

        $scope.getList = function () {
            $scope.isProcessing = true;
            //debugger;
            $http.get('/api/ScriptLog/Get')
                .then(function (data, status, headers, config) {
                    $scope.isProcessing = false;
                    $scope.ScriptLog = data;
                })
            //.error(function (data, status, headers, config) {
            //    $scope.message = data.error_description.replace(/["']{1}/gi, "");
            //    $scope.showMessage = true;
            //});
            //.error(function (error) { debugger; })
            //.finally(function () { debugger; })
            //;
            ;

            $scope.message = "Hi There";

        }

        //$scope.getList();

    }])

    .controller('UsersCtrl', ['$scope', '$location', '$window', '$http', function ($scope, $location, $window, $http) {
        var once = false;
        $scope.itemsPerPage = 2;

        $scope.getUsers = function () {
            $scope.processing = true;
            $http.get('http://localhost:63103/api/user')
                .then(function (data, status, headers, config) {
                    $scope.users = data;
                    if (!once) {
                        // give "smart-table" a table data template that won't change so it can maintain the structure while refreshing the data with an ajax call
                        // passed in to the table tag via the attribute "st-safe-src"
                        $scope.usersTemplate = [].concat($scope.users);
                        once = true;
                    }
                }, function(data, status, headers, config) {
                    alert('Error retrieving user list');
                });
        }
        $scope.getUsers();

        $scope.showUser = function (user) {
            return !user.Disabled || $scope.showDisabled;
        }

        //alert('Show User 1: ' + $scope.showUser($scope.users[0]));
    }])

    .controller('WebAPITestCtrl', ['$scope', '$location', '$window', '$http', function ($scope, $location, $window, $http) {
        $scope.getValues = function () {
            $scope.processing = true;
            $http.get('http://localhost:63103/api/values')
                .then(function (data, status, headers, config) {
                    alert('hooray');
                    $scope.values = data;
                }, function(data, status, headers, config) {
                    alert('error : (');
                });

        }
    }])

    // Path: /error/404
    .controller('Error404Ctrl', ['$scope', '$location', '$window', function ($scope, $location, $window) {
        $scope.$root.title = 'Error 404: Page Not Found';
        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });
    }]);