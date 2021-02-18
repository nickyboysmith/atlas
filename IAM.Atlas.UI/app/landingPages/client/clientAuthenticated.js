(function () {

'use strict';

// Declares how the application should be bootstrapped. See: http://docs.angularjs.org/guide/module
    angular
        .module('app',
            [
                'ui.router',
                'app.filters',
                'app.directives',
                'app.controllers',
                'app.services',
                'noCAPTCHA',
                'ngAnimate',
                'mp.datePicker',
                'checklist-model',
                'ngDraggable',
                'ui.bootstrap',
                "template/typeahead/typeahead-match.html",
                "template/typeahead/typeahead-popup.html"
            ])

    //Configure angular-breadcrumb
        .config(['noCAPTCHAProvider', function (noCaptchaProvider) {
            noCaptchaProvider.setSiteKey('6LcIRgkTAAAAAAFMHXIluIPtd4hCJm5KxGqRVaRq');
            noCaptchaProvider.setTheme('dark');
        }])
        .config(function ($provide) {
            var profile = JSON.parse(sessionStorage.getItem("userDetails"));
            $provide.constant("activeUserProfile", profile);
            console.log(profile);
        })
    // Gets executed during the provider registrations and configuration phase. Only providers and constants can be
    // injected here. This is to prevent accidental instantiation of services before they have been fully configured.
    .config(['$stateProvider', '$locationProvider', function ($stateProvider, $locationProvider) {

        // UI States, URL Routing & Mapping. For more info see: https://github.com/angular-ui/ui-router
        // ------------------------------------------------------------------------------------------------------------

        //For more advanced bread-crumb configuration and examples please refer to https://github.com/ncuillery/angular-breadcrumb/blob/gh-pages/sample/app.js and for styling: https://github.com/ncuillery/angular-breadcrumb/wiki/Templating

        $stateProvider
            .state('Client Signout', {
                url: "/signout",
                templateUrl: "/app/components/login/signOutClientView.html",
                controller: "SignOutCtrl"
            })
            .state('Client Home', {
                url: '/',
                templateUrl: '/app/components/home/client.html'
                // controller: 'HomeCtrl'
            })
            .state('Client Payment', {
                url: '/',
                templateUrl: '/app/components/clientSite/payment.html',
                controller: 'clientSitePaymentCtrl'
            })
            .state('Organisation Client Home', {
                url: "/:organisationName",
                templateUrl: "/app/components/login/clientView.html",
                controller: 'LoginOrganisationCtrl'
            })
            .state('Course Bookings', {
                url: '/',
                templateUrl: '/app/components/client/clientCourseBookings.html',
                controller: 'ClientCourseBookingsCtrl'
            })
            .state('otherwise', {
                url: '*path',
                templateUrl: '/app/shared/error/view.html',
                controller: 'ErrorCtrl'
            });

        $locationProvider.html5Mode({
            enabled: true,
            requireBase: false
        });
    }])
    // Gets executed after the injector is created and are used to kick start the application. Only instances and constants
    // can be injected here. This is to prevent further system configuration during application run time.
    .run(['$templateCache', '$rootScope', '$state', '$stateParams', function ($templateCache, $rootScope, $state, $stateParams) {

        // <ui-view> contains a pre-rendered template for the current view
        // caching it will prevent a round-trip to a server at the first page load
        var view = angular.element('#ui-view');
        //$templateCache.put(view.data('tmpl-url'), view.html());
        //$templateCache.removeAll();

        // Allows to retrieve UI Router state information from inside templates
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;

        $rootScope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState) {

            // Sets the layout name, which can be used to display different layouts (header, footer etc.)
            // based on which page the user is located
            $rootScope.layout = toState.layout;

            // store the previous state so we can return to it after closing a modal
            $state.previous = fromState;

            if (toState.name === 'Modal.FeedBackForm') {
                toState.views["@"].templateUrl = fromState.templateUrl;
            }
        });

    }])

    .run(['$rootScope', '$interval', 'activeUserProfile', function ($rootScope, $interval, activeUserProfile) {
        // add root variables and functions here
    }])
    /**
      * Convert object to JSON
      */
    .config(['$httpProvider', function ($httpProvider) {


        $httpProvider.interceptors.push('UnAuthorizedAccessFactory');

        $httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded;charset=utf-8";

        var token = sessionStorage.getItem("authToken");
        $httpProvider.defaults.headers.common["X-Auth-Token"] = token;

        /**
         * The workhorse; converts an object to x-www-form-urlencoded serialization.
         * @param {Object} obj
         * @return {String}
         */
        var param = function (obj) {
            var query = '', name, value, fullSubName, subName, subValue, innerObj, i;

            for (name in obj) {
                value = obj[name];

                if (value instanceof Array) {
                    for (i = 0; i < value.length; ++i) {
                        subValue = value[i];
                        fullSubName = name + '[' + i + ']';
                        innerObj = {};
                        innerObj[fullSubName] = subValue;
                        query += param(innerObj) + '&';
                    }
                }
                else if (value instanceof Object) {
                    for (subName in value) {
                        subValue = value[subName];
                        fullSubName = name + '[' + subName + ']';
                        innerObj = {};
                        innerObj[fullSubName] = subValue;
                        query += param(innerObj) + '&';
                    }
                }
                else if (value !== undefined && value !== null)
                    query += encodeURIComponent(name) + '=' + encodeURIComponent(value) + '&';
            }

            return query.length ? query.substr(0, query.length - 1) : query;
        };

        // Override $http service's default transformRequest
        $httpProvider.defaults.transformRequest = [function (data) {
            return angular.isObject(data) && String(data) !== '[object File]' ? param(data) : data;
        }];

        // $httpProvider.defaults.useXDomain = true;
        delete $httpProvider.defaults.headers.common['X-Requested-With'];


    }
    ]);


        /**
         * Add the app controller module
         */
        angular.module('app.controllers', []);

})();