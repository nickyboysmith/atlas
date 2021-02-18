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
                'mp.datePicker',
                'app.services'
            ])
    // Gets executed during the provider registrations and configuration phase. Only providers and constants can be
    // injected here. This is to prevent accidental instantiation of services before they have been fully configured.
    .config(['$stateProvider', '$locationProvider', function ($stateProvider, $locationProvider) {

        // UI States, URL Routing & Mapping. For more info see: https://github.com/angular-ui/ui-router
        // ------------------------------------------------------------------------------------------------------------
        $stateProvider
            .state('Trainer Unavailable', {
                url: "/trainer/login/unavailable",
                templateUrl: "/app/components/login/blockedView.html",
                controller: 'BlockedCtrl',
                resolve: {

                    systemStatus: function (SystemService) {
                        return SystemService.checkSystemStatus();
                        //SystemService.checkSystemStatus()
                        //    .then(
                        //        function (response) {
                        //            return response.data;
                        //        },
                        //        function (response) {
                        //            return false;
                        //        }
                        //    );
                    }

                }
            })
            .state('Trainer Home', {
                url: "/trainer/login",
                templateUrl: "/app/components/login/organisationView.html",
                controller: 'LoginOrganisationCtrl',
                resolve: {
                    blockIPCheck: function (SystemService, $window) {
                        SystemService.checkBlockedUserIP()
                        .then(function (response) {
                            if (response.data) {
                                $window.location.href = "/trainer/login/unavailable";
                            }
                        });
                    },
                    systemStatus: function (SystemService) {
                        return SystemService.checkSystemStatus();
                        //SystemService.checkSystemStatus()
                        //    .then(
                        //        function (response) {
                        //            return response.data;
                        //        },
                        //        function (response) {
                        //            return false;
                        //        }
                        //    );
                    },
                    organisationRoute: function () {
                        return {};
                    }
                }
                // , controller: "TrainerHomeCtrl"
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

    .run(['$rootScope', '$interval', function ($rootScope, $interval) {

        /**
         * 
         */
        $rootScope.baseColour = "{'background':'hotPink'}";

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
        $httpProvider.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded;charset=utf-8";
        // $httpProvider.defaults.headers.post['Content-Type'] = 'multipart/form-data';


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