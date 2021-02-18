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
                'ngAnimate',
                'checklist-model',
                'ngDraggable',
                'ui.bootstrap',
                "template/typeahead/typeahead-match.html",
                "template/typeahead/typeahead-popup.html"
            ])
    // Gets executed during the provider registrations and configuration phase. Only providers and constants can be
    // injected here. This is to prevent accidental instantiation of services before they have been fully configured.
    .config(['$stateProvider', '$locationProvider', function ($stateProvider, $locationProvider) {

        // UI States, URL Routing & Mapping. For more info see: https://github.com/angular-ui/ui-router
        // ------------------------------------------------------------------------------------------------------------

        $stateProvider
            .state('loginBlocked', {
                url: '/admin/login/unavailable',
                templateUrl: '/app/components/login/blockedView.html',
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

            .state('loginScreen', {
                url: '/admin/login',
                templateUrl: '/app/components/login/organisationView.html',
                controller: 'LoginOrganisationCtrl',
                resolve: {
                    blockIPCheck: function (SystemService, $window) {
                        SystemService.checkBlockedUserIP()
                        .then(function (response) {
                            if (response.data) {
                                $window.location.href = "/admin/login/unavailable";
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
            });

        $locationProvider.html5Mode({
            enabled: true,
            requireBase: false
        });

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