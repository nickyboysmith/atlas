(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('LoginCtrl',  LoginCtrl);


    LoginCtrl.$inject = ['$scope', '$location', '$window', '$http', "AtlasCookieFactory"];

    function LoginCtrl($scope, $location, $window, $http, AtlasCookieFactory) {

        // Using a shared Cookie factory across the Application
        // Library in /app/shared/core/factories/atlasCookieFactory

        //function setCookie(cname, cvalue, exdays) {
        //    var d = new Date();
        //    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        //    var expires = "expires=" + d.toUTCString();
        //    document.cookie = cname + "=" + cvalue + "; " + expires;
        //}

        //function getCookie(cname) {
        //    var name = cname + "=";
        //    var ca = document.cookie.split(';');
        //    for (var i = 0; i < ca.length; i++) {
        //        var c = ca[i];
        //        while (c.charAt(0) == ' ') c = c.substring(1);
        //        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
        //    }
        //    return "";
        //}

        //function checkCookie() {
        //    var user = getCookie("username");
        //    if (user != "") {
        //        return user;
        //    } else {
        //        return "";
        //    }
        //}

        $scope.$root.title = 'Atlas | Sign In';

        $scope.cookieFactory = AtlasCookieFactory;

        $scope.user = {};
        
        //$scope.user.userName = $cookieStore.get('userlogin');

        /**
         * To get cookie
         */
        $scope.user.userName = $scope.cookieFactory.getCookie("username");

        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });

        $scope.logMeIn = function () {

        //If the 'Remember Me' function is enabled, store the login name in a cookie
        if ($scope.user.remember)
        {
            $scope.cookieFactory.createCookie("username", $scope.user.userName, {expires: 30});

            //$cookies.userName = 'AtlasLogin'; 
            //$scope.platformCookie = $cookies.userName; 
            //$cookieStore.put('userlogin', $scope.user.userName);     
        }

        //$scope.user.currentBrowser = $window.navigator.userAgent;
        //$scope.user.currentOS = $window.navigator.platform;
        $scope.user.currentBrowser = SystemService.CurrentBrowser();
        $scope.user.currentOS = SystemService.CurrentOperatingSystem();

        $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

        $http.post(apiServer + '/signin', $scope.user)
        .then(function (data, status, headers, config) {
            if (data.indexOf("login_locked") !== -1){
                alert("Your login credentials have been locked due to repeated failed attempts to access your account, Please contact an Administrator for assistance.");
                $location.path('/login');
            }
            if (data.indexOf("login_denied") !== -1) {
                alert("Login failed. Please check your login and password before trying again.");
                $location.path('/login');
            }
            if (data.indexOf("login_accepted") !== -1) {
                $scope.user.authenticated = true;
                $location.path('/');
            }

        }, function (data, status, headers, config) {
            alert("Something unexpected happened! Please contact your administrator to let them know.");
            $scope.user = {};
            $location.path('/login');
        });
        }
    }
})();

