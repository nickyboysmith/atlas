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
                'ncy-angular-breadcrumb',
                'smart-table',
                'autocomplete',
                'mp.datePicker',
                'app.services',
                'noCAPTCHA',
                'ngAnimate',
                'ngDraggable',
                'autocomplete',
                'ui.bootstrap',
                'ngIdle'
            ])
        //.module('app',
        //    [
        //        'ui.router',
        //        'app.filters',
        //        'app.directives',
        //        'app.controllers',
        //        'ncy-angular-breadcrumb',
        //        'smart-table',
        //        'mp.datePicker',
        //        'app.services',
        //        'noCAPTCHA',
        //        'ngAnimate',
        //        'autocomplete',
        //        'checklist-model',
        //        'ngDraggable',
        //        'ui.bootstrap',
        //        'ui',
        //        'ngIdle',
        //        'AmbaSortableList',
        //        "template/typeahead/typeahead-match.html",
        //        "template/typeahead/typeahead-popup.html",
        //        "chart.js"
        //    ])

    //Configure angular-breadcrumb
        .config(function ($breadcrumbProvider) {
            $breadcrumbProvider.setOptions({ prefixStateName: 'home', template: 'bootstrap2' });
            }
        )
        .config(['noCAPTCHAProvider', function (noCaptchaProvider) {
            noCaptchaProvider.setSiteKey('6LcIRgkTAAAAAAFMHXIluIPtd4hCJm5KxGqRVaRq');
            noCaptchaProvider.setTheme('dark');
        }])
        .config(function ($provide) {
            var profile = JSON.parse(sessionStorage.getItem("userDetails"));
            $provide.constant("activeUserProfile", profile);
        })
        //Configure idle Provider
        .config(['KeepaliveProvider', 'IdleProvider', function (KeepaliveProvider, IdleProvider) {
            IdleProvider.idle(300);
            IdleProvider.timeout(30);
            //KeepaliveProvider.interval(10);
        }])

    // Gets executed during the provider registrations and configuration phase. Only providers and constants can be
    // injected here. This is to prevent accidental instantiation of services before they have been fully configured.
    .config(['$stateProvider', '$locationProvider', function ($stateProvider, $locationProvider) {

        // UI States, URL Routing & Mapping. For more info see: https://github.com/angular-ui/ui-router
        // ------------------------------------------------------------------------------------------------------------

        //For more advanced bread-crumb configuration and examples please refer to https://github.com/ncuillery/angular-breadcrumb/blob/gh-pages/sample/app.js and for styling: https://github.com/ncuillery/angular-breadcrumb/wiki/Templating

        $stateProvider
            .state('Trainer Home', {
                url: "/trainer",
                templateUrl: "/app/components/trainer/home/view.html"
                // , controller: "TrainerHomeCtrl"
            })
            .state('Trainer Signout', {
                url: "/trainer/signout",
                templateUrl: "/app/components/login/signOutTrainerView.html"
                , controller: "SignOutCtrl"
            })
            .state('Trainer About', {
                url: "/trainer/",
                templateUrl: "/app/components/trainer/about/view.html"
                , controller: "TrainerAboutCtrl"
            })
            .state('Trainer Availability', {
                url: "/trainer/",
                templateUrl: "/app/components/trainer/availability/calendar.html"
                , controller: "TrainerAvailabilityCalendarCtrl"
            })

            .state('TrainerBookings', {
                url: "/trainer/",
                templateUrl: "/app/components/trainer/bookings/view.html"
                , controller: "TrainerBookingsCtrl"
            })

            .state('TrainerAttendance', {
                url: "/trainer/",
                templateUrl: "/app/components/trainer/attendance/view.html"
                , controller: "TrainerAttendanceCtrl"
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


    }])

    .run(['$rootScope', '$interval', 'activeUserProfile', 'Idle', function ($rootScope, $interval, activeUserProfile, Idle) {


        /*
         * Start the detection and response to idling users
         */
        Idle.watch();

        /**
         * 
         */
        $rootScope.baseColour = "{'background':'hotPink'}";


        $rootScope.trainerName = activeUserProfile.Name;

        /*
         * Used on Base View
         */
        $rootScope.showPersonalMenu = false;
        $rootScope.showPasswordChange = false;

        /**
         * Rootscope
         */
        $rootScope.trainerProfilePicture = "/app_assets/images/profile-picture-large.png";


         /**
         * Set the display name and company logo
         */
       
        var organisationDisplay = activeUserProfile.selectedOrganisation.Display;
        if (organisationDisplay === undefined || organisationDisplay.length === 0) {
            $rootScope.profileDisplayName = activeUserProfile.selectedOrganisation.Name;
            $rootScope.showCompanyLogo = false;
            //$rootScope.companyLogo = "images/trainer_logo.png"; // set to some default
        } else {
            $rootScope.showCompanyLogo = activeUserProfile.selectedOrganisation.Display[0].ShowLogo;
            $rootScope.profileDisplayName = activeUserProfile.selectedOrganisation.Display[0].Name;
            $rootScope.companyLogo = activeUserProfile.selectedOrganisation.Display[0].Logo;
        }

        /**
         * Added a method that updates the time in the new layout every second.
         */
        $rootScope.AssignedDate = Date;
        $interval(function () {
                // nothing is required here, interval triggers digest automatically
        }, 1000);
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