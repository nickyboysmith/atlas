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
                'mp.datePicker',
                'app.services',
                'noCAPTCHA',
                'ngAnimate',
                'autocomplete',
                'checklist-model',
                'ngDraggable',
                'ui.bootstrap',
                'ui',
                'ngIdle',
                'AmbaSortableList',
                "template/typeahead/typeahead-match.html",
                "template/typeahead/typeahead-popup.html",
                "chart.js"
            ])

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
            console.log(profile);
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
            .state('home', {
                url: '/admin',
                templateUrl: '/app/components/home/View.html',
                controller: 'HomeCtrl',
                ncyBreadcrumb: {
                    label: 'Home'
                }
            })
            .state('signout', {
                url: '/admin/signout',
                templateUrl: '/app/components/login/signOutOrganisationView.html',
                controller: 'SignOutCtrl'
            })
            .state('about', {
                url: '/admin/about',
                templateUrl: '/app/components/about/view.html',
                controller: 'AboutCtrl',
                ncyBreadcrumb: {
                    label: 'About'
                }
            })
            .state('login', {
                url: '/login',
                layout: 'basic',
                templateUrl: '/app/components/login/view.html',
                controller: 'LoginCtrl'
            })
            //.state('Client', {
            //    url: '/client',
            //    templateUrl: '/app/components/client/clientView',
            //    controller: 'ClientCtrl',
            //    ncyBreadcrumb: {
            //        label: 'Clients'
            //    }
            //})
            .state('Report', {
                url: '/admin/report',
                templateUrl: '/app/components/report/viewer.html',
                controller: 'ReportCtrl',
                ncyBreadcrumb: {
                    label: 'Reports'
                }
            })
            .state('Course', {
                url: '/admin',
                templateUrl: '/app/components/course/Search.html',
                controller: 'CourseCtrl',
                ncyBreadcrumb: {
                    label: 'Courses'
                }
            })
            .state('users', {
                url: '/admin/users',
                templateUrl: '/app/components/users/userListView.html',
                controller: 'UsersCtrl'
            })
            .state('feedback', {
                url: '/admin/feedback',
                templateUrl: '/app/components/feedback/view.html',
                controller: 'FeedBackCtrl'
            })
            .state('changepassword', {
                url: '/admin/changepassword',
                templateUrl: '/app/components/changePassword/Update.html',
                controller: 'ChangePasswordCtrl',
                ncyBreadcrumb: {
                    label: 'Change Password'
                }
            })
            .state('changepasswordrequest', {
                url: '/admin/changepasswordrequest',
                templateUrl: '/app/components/changePassword/request.html',
                controller: 'ChangePasswordRequestCtrl',
                ncyBreadcrumb: {
                    label: 'Change Password Request'
                }
            })
            .state('messages', {
                url: '/admin/messages',
                templateUrl: '/app/components/notifications/view.html',
                controller: 'NotificationCtrl',
                ncyBreadcrumb: {
                    label: 'System Messages'
                }
            })
            .state('sendMessage', {
                url: '/admin/messaging',
                templateUrl: '/app/components/messaging/send.html',
                controller: 'MessagingCtrl',
                ncyBreadcrumb: {
                    label: 'Send Message'
                }
            })
            .state('clients', {
                url: '/admin',
                templateUrl: '/app/components/client/search.html',
                controller: 'ClientsCtrl',
                ncyBreadcrumb: {
                    label: 'Clients'
                }
            })
            //.state('addClient', {
            //    url: '/admin/addclient',
            //    templateUrl: '/app/components/client/add.html',
            //    controller: 'addClientCtrl'
            //})
            .state('clientDetails', {
                url: '/admin/clientdetails?clientid&nextid&previd&nextname&prevname',
                templateUrl: '/app/components/client/details.html',
                controller: 'clientDetailsCtrl'
            })
            .state('addClientNote', {
                url: '/admin/addclientnote?clientid',
                templateUrl: '/app/components/client/addNote.html',
                controller: 'addClientNoteCtrl'
            })
            .state('addClientPayment', {
                url: '/admin/addclientpayment?clientid',
                templateUrl: '/app/components/client/addPayment.html',
                controller: 'addClientPaymentCtrl'
             })
            .state('c', {       // temporary client list
                url: '/admin/c',
                templateUrl: '/app/components/client/C_List.html',
                controller: 'ClientsCtrl'
            })
            /** 
             * ConfigureOrganisation
             */
            .state('configureOrganisation', {
                url: '/admin/configure-organisation',
                templateUrl: '/app/components/organisation/Update.html',
                controller: 'ConfigureOrganisationCtrl'
            })
            /**
             * Manage the payment type
             */
            .state('Manage Payment Types', {
                url: "/admin/manage-payment-types",
                templateUrl: "/app/components/payment/manage.html",
                controller: "ManagePaymentCtrl"
            })

            /*
            *PaymentProvider
            */
            .state('paymentProvider', {
                url: '/admin/paymentprovider',
                templateUrl: '/app/components/paymentProvider/Update.html',
                controller: 'PaymentProviderCtrl'
            })

            /*
            *VenueCostTypes
            */
            .state('venueCostType', {
                url: '/admin/venuecosttype',
                templateUrl: '/app/components/venueCostType/Update.html',
                controller: 'VenueCostTypeCtrl'
            })

            /*
            * Course Category
            */
            .state('courseTypeCategories', {
                url: '/admin/coursetypecategories',
                templateUrl: '/app/components/coursetypecategories/Update.html',
                controller: 'CourseTypeCategoryCtrl'
            })

            /*
            * Venue
            */
            .state('venue', {
                url: '/admin/venue',
                templateUrl: '/app/components/venue/Update.html',
                controller: 'venueCtrl'
            })

            ///*
            //* Add Course
            //*/
            .state('editCourse', {
                url: '/admin/editcourse',
                templateUrl: '/app/components/course/edit.html',
                controller: 'editCourseCtrl'
            })
            /**
             * Change the colour
             * Only temporary 
             */
            .state('changeTemplate', {
                url: '/admin/change-template',
                templateUrl: '/app/shared/core/changeTemplate.html',
                controller: 'ChangeTemplateCtrl'
            })

             /**
             * Manage the area
             */
            .state('Manage Areas', {
                url: "/admin/area",
                templateUrl: "/app/components/area/manage.html",
                controller: "ManageAreaCtrl"
            })

            /**
             * Manage the courseType
             */
            .state('Manage CourseTypes', {
                url: "/admin/coursetype",
                templateUrl: "/app/components/coursetype/manage.html",
                controller: "ManageCourseTypesCtrl"
            })

            /**
             * Manage the public holiday
             */
            //.state('Manage Public Holidays', {
            //    url: "/admin/publicholiday",
            //    templateUrl: "/app/components/publicholiday/manage.html",
            //    controller: "PublicHolidayCtrl"
            //})

            /**
             * Add the public holiday
             */
            //.state('Add Public Holidays', {
            //    url: "/admin/publicholiday",
            //    templateUrl: "/app/components/publicholiday/add.html",
            //    controller: "AddPublicHolidayCtrl"
            //})

            .state('otherwise', {
                url: '*path',
                templateUrl: '/app/shared/error/view',
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




    .run(['$rootScope', '$interval', 'activeUserProfile', 'SignOutFactory', 'Idle', function ($rootScope, $interval, activeUserProfile, SignOutFactory, Idle) {

        /*
         * Start the detection and response to idling users
         */
        Idle.watch();

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
         * If session storage has expired
         */
        if (activeUserProfile === null) {
            SignOutFactory.admin();
        }

        /**
         * Set the admin username
         */
        $rootScope.adminUserName = activeUserProfile.Name;

        /**
         * Set the display Name
         */
        var organisationDisplay = activeUserProfile.selectedOrganisation.Display;
        if (organisationDisplay === undefined || organisationDisplay.length === 0) {
            $rootScope.profileDisplayName = activeUserProfile.selectedOrganisation.Name;
        } else {
            $rootScope.profileDisplayName = activeUserProfile.selectedOrganisation.Display[0].Name;
        }

        /**
         * Set the referring Authority
         */
        var referringAuthority = activeUserProfile.ReferringAuthorityName;
        if (referringAuthority.length === 0 || referringAuthority === undefined) {
            $rootScope.referringAuthorityName = "";
        } else {
            $rootScope.referringAuthorityName = referringAuthority[0].Name;
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

        $httpProvider.interceptors.push('OverlayFactory');
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