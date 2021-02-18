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
                'checklist-model',
                'app.services',
                'ui.bootstrap'
            ])
            .config(function ($provide) {
                $provide.constant("activeUserProfile", {});
            })
    // Gets executed during the provider registrations and configuration phase. Only providers and constants can be
    // injected here. This is to prevent accidental instantiation of services before they have been fully configured.
    .config(['$stateProvider', '$locationProvider', function ($stateProvider, $locationProvider) {

        // UI States, URL Routing & Mapping. For more info see: https://github.com/angular-ui/ui-router
        // ------------------------------------------------------------------------------------------------------------
        $stateProvider
            //.state('Client Email Confirmation', {
            //    url: '/ClientEmailConfirm?Reference',
            //    templateUrl: '/app/components/login/clientView.html',
            //    controller: 'LoginOrganisationCtrl',
            //    resolve: {
            //        emailConfirmationCheck: function (EmailConfirmationService, $window) {
            //            EmailConfirmationService.updateEmailConfirmation()
            //            .then(function (response) {
            //                if (response.data) {
            //                    $window.location.href = "/login";
            //                }
            //            })
            //        },
            //        organisationRoute: function () {
            //            return {};
            //        }
            //    }
            //})
            .state('Client Not Found', {
                url: "/login/organisationcontacts",
                templateUrl: "/app/components/login/organisationcontacts.html",
                controller: 'OrganisationContactsCtrl'
            })
            .state('Client Register', {
                url: "/login/clientregister",
                templateUrl: "/app/components/login/clientRegister.html",
                controller: 'ClientRegisterCtrl'
            })
            .state('ClientConfirmRegistration', {
                url: '/login/confirmRegistration',
                templateUrl: '/app/components/login/clientConfirmRegistration.html',
                controller: 'ClientConfirmRegistrationCtrl',
                resolve: {
                    checkDirectAccess: function (LoginFactory, $document, $window) {
                        LoginFactory.preventDirectAccess($document, $window,
                            [
                                "clientregister",
                                "clientSpecialRequirements"
                            ]
                        );
                    }
                }
            })
            .state('ClientRegistrationSpecialRequirements', {
                url: "/login/clientSpecialRequirements",
                templateUrl: "/app/components/login/clientSpecialRequirements.html",
                controller: 'ClientSpecialRequirementsCtrl',
                resolve: {
                    checkDirectAccess: function (LoginFactory, $document, $window) {
                        LoginFactory.preventDirectAccess($document, $window,
                            [
                                "confirmRegistration",
                                "clientCourseSelection"
                            ]
                        );
                    }
                }
            })
            .state('ClientCourseSelection', {
                url: "/login/clientCourseSelection",
                templateUrl: "/app/components/login/clientCourseSelection.html",
                controller: 'ClientCourseSelectionCtrl',
                resolve: {
                    checkDirectAccess: function (LoginFactory, $document, $window) {
                        LoginFactory.preventDirectAccess($document, $window,
                            [
                                "clientSpecialRequirements",
                                "clientCourseConfirmation"
                            ]
                        );
                    }
                }
            })
            .state('ClientCourseConfirmation', {
                url: "/login/clientCourseConfirmation",
                templateUrl: "/app/components/login/clientCourseConfirmation.html",
                controller: 'ClientCourseConfirmationCtrl',
                resolve: {
                    checkDirectAccess: function (LoginFactory, $document, $window) {
                        LoginFactory.preventDirectAccess($document, $window,
                            [
                                "clientCourseSelection"
                            ]
                        );
                    }
                }
                
            })
            .state('ClientCoursePayment', {
                url: "/login/clientCoursePayment",
                templateUrl: "/app/components/login/clientCoursePayment.html",
                controller: 'ClientCoursePaymentCtrl'
            })
            .state('ClientCoursePaymentVerification', {
                url: "/login/clientCoursePaymentVerification",
                templateUrl: "/app/components/login/clientCoursePaymentVerification.html",
                controller: 'ClientCoursePaymentVerificationCtrl'
            })
            .state('Client Organisation Selection', {
                url: "/login/organisationselection",
                templateUrl: "/app/components/login/organisationSelection.html",
                controller: 'OrganisationSelectionCtrl'
            })
            .state('Client Unavailable', {
                url: "/login/unavailable",
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
            .state('Client Home', {
                url: "/login",
                templateUrl: "/app/components/login/clientView.html",
                controller: 'LoginOrganisationCtrl',
                resolve: {
                    blockIPCheck: function (SystemService, $window) {
                        SystemService.checkBlockedUserIP()
                        .then(function (response) {
                            if (response.data) {
                                $window.location.href = "/login/unavailable";
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
            })
            .state('Client Email Confirmation', {
                url: '/ClientEmailConfirm?Reference',
                templateUrl: '/app/components/login/clientView.html',
                controller: 'LoginOrganisationCtrl',
                resolve: {
                    emailConfirmationCheck: function ($stateParams, EmailConfirmationService, $window) {
                        EmailConfirmationService.updateEmailConfirmation($stateParams.Reference)
                        .then(function (response) {
                            if (response.data) {
                                $window.location.href = "/login";
                            }
                        })
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
            })
            .state('Organisation Client Home', {
                url: "/:organisationName",
                templateUrl: "/app/components/login/clientView.html",
                controller: 'LoginOrganisationCtrl',
                resolve: {
                    systemStatus: function (SystemService) {
                        return SystemService.checkSystemStatus();
                        //SystemService.checkSystemStatus()
                        //        .then(
                        //            function (response) {
                        //                return response.data;
                        //            },
                        //            function (response) {
                        //                return false;
                        //            }
                        //        );
                    },
                    organisationRoute: function ($stateParams, OrganisationContactService) {
                        sessionStorage.organisationName = "";
                        if ($stateParams.organisationName != "") {
                            
                            //If not general client/admin login, check for possible organisation specific requirements
                            var organisationSettings = {};
                            return OrganisationContactService.getOrganisationContent($stateParams.organisationName)
                            .then(
                                    function (response) {
                                        sessionStorage.organisationName = $stateParams.organisationName;
                                     return response.data;
                                    }
                                    ,
                                    function (response) {
                                        return {};
                                    }
                            );                               
                        }
                    }
    }

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