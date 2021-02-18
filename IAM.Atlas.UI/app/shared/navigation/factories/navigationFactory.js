(function () {

    'use strict';

    angular
        .module("app")
        .factory("NavigationFactory", NavigationFactory);

    NavigationFactory.$inject = [];

    function NavigationFactory() {

        /**
         * Transform into a format
         * To display as report items
         */
        this.transformReportMenuItems = function (menuItems) {

            var reportsInCategories = [];

            /**
             * Loop through the reports
             */
            angular.forEach(menuItems, function (value, index) {

                /**
                 * Loop through the report categories
                 * 
                 */
                angular.forEach(value.ReportCategory, function (category, key) {

                    if (reportsInCategories[category.ReportCategoryId] === undefined) {
                        reportsInCategories[category.ReportCategoryId] = {
                            display: category.Title,
                            path: "#",
                            altText: category.Title,
                            disabled: true,
                            itemClass: "",
                            children: []
                        };
                    }

                    /**
                     * Put item in the correct category
                     */
                    reportsInCategories[category.ReportCategoryId]["children"].push({
                        display: value.Title,
                        controller: 'NotificationCtrl',
                        reportId: value.ReportId,
                        path: '/app/components/notifications/view', // @todo change to correct path
                        iconClass: 'message',
                        altText: value.Description,
                        modal: 'true',
                        enabled: 'true'
                    });

                });

            });

            return reportsInCategories;

        };

        /**
         * 
         */
        this.personalMenuItemsUpper = function () {
            return [
                {
                    name: "Upper",
                    menu: [
                        {
                            display: 'Sign Out'
                            , controller: ''
                            , path: '/admin/signout'
                            , iconClass: 'signout'
                            , altText: 'Sign Out'
                            , modal: 'false'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }
                        ,
                        {
                            display: 'Active Users'
                            , controller: 'ActiveSystemUsersCtrl'
                            , path: '/app/components/users/activeUsers'
                            , iconClass: 'users'
                            , altText: 'Active Users'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }

                    ]
                }
            ];
        };

        this.personalMenuItemsMiddle = function () {
            return [
                {
                    name: "Middle",
                    menu: [
                        {
                            display: 'System Messages'
                            , controller: 'NotificationCtrl'
                            , path: '/app/components/notifications/view'
                            , iconClass: 'message'
                            , altText: 'System Messages'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }
                        //, {
                        //    display: 'Settings'
                        //    , controller: ''
                        //    , path: '/?????'
                        //    , iconClass: 'settings'
                        //    , altText: 'User Settings'
                        //    , modal: 'true'
                        //    , enabled: 'false'
                        //    , userAccess: 'true'
                        //    , systemsAdminAccess: 'true'
                        //    , organisationAdminAccess: 'true'
                        //    , section: 'A'
                        //}
                        //, {
                        //    display: 'Colour Scheme'
                        //    , controller: 'ChangeTemplateCtrl'
                        //    , path: '/app/shared/core/changeTemplate'
                        //    , iconClass: 'settings'
                        //    , altText: 'Colour Scheme'
                        //    , modal: 'true'
                        //    , enabled: 'true'
                        //    , userAccess: 'true'
                        //    , systemsAdminAccess: 'true'
                        //    , organisationAdminAccess: 'true'
                        //    , section: 'A'
                        //}
                        , {
                            display: 'Change Password'
                            , controller: 'ChangePasswordCtrl'
                            , path: '/app/components/changePassword/Update'
                            , iconClass: 'password'
                            , altText: 'Change Password'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }
                        , {
                            display: 'Add Me to Atlas Support'
                            , controller: ''
                            , path: ''
                            , iconClass: 'dbAdd'
                            , altText: 'Add Me to the Atlas Systems Administrators Support'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'false'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'false'
                            , systemsAdminSupportAccess: 'true'
                            , section: 'B'
                        }
                        , {
                            display: 'Remove Me from Atlas Support'
                            , controller: ''
                            , path: ''
                            , iconClass: 'dbRemove'
                            , altText: 'Remove Me from the Atlas Systems Administrators Support List'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'false'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'false'
                            , systemsAdminSupportAccess: 'false'
                            , section: 'B'
                        }
                        , {
                            display: 'Atlas System Support List'
                            , controller: 'SystemAdminSupportUsersCtrl'
                            , path: '/app/components/users/systemadminsupportusers'
                            , iconClass: 'dbView'
                            , altText: 'View the Atlas Systems Administrators Support List'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'false'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'false'
                            , section: 'C'
                        }
                        , {
                            display: 'Support List'
                            , controller: 'SystemSupportUsersCtrl'
                            , path: '/app/components/users/systemsupportusers'
                            , iconClass: 'dbView'
                            , altText: 'View the Administrators Support List'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'false'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'C'
                        }
                    ]
                }
            ];
        };

        this.personalMenuItemsLower = function () {
            return [
                //{
                //    name: "Upper",
                //    menu: [
                //        {
                //            display: 'Sign Out'
                //            , controller: ''
                //            , path: '/admin/signout'
                //            , iconClass: 'signout'
                //            , altText: 'Sign Out'
                //            , modal: 'false'
                //            , enabled: 'true'
                //        }
                //    ]
                //}
                //,
                //{
                //    name: "Middle",
                //    menu: [
                //        {
                //            display: 'System Messages'
                //            , controller: 'NotificationCtrl'
                //            , path: '/app/components/notifications/view'
                //            , iconClass: 'message'
                //            , altText: 'System Messages'
                //            , modal: 'true'
                //            , enabled: 'true'
                //        }
                //        , {
                //            display: 'Settings'
                //            , controller: ''
                //            , path: '/?????'
                //            , iconClass: 'settings'
                //            , altText: 'User Settings'
                //            , modal: 'true'
                //            , enabled: 'false'
                //        }
                //        , {
                //            display: 'Colour Scheme'
                //            , controller: 'ChangeTemplateCtrl'
                //            , path: '/app/shared/core/changeTemplate'
                //            , iconClass: 'settings'
                //            , altText: 'Colour Scheme'
                //            , modal: 'true'
                //            , enabled: 'true'
                //        }
                //        , {
                //            display: 'Change Password'
                //            , controller: 'ChangePasswordCtrl'
                //            , path: '/app/components/changePassword/Update'
                //            , iconClass: 'password'
                //            , altText: 'Change Password'
                //            , modal: 'true'
                //            , enabled: 'true'
                //        }
                //    ]
                //}
                //,
                {
                    name: "Lower",
                    menu: [
                        {
                            display: 'Page Feedback'
                            , controller: 'FeedBackCtrl'
                            , path: '/app/components/feedback/view'
                            , iconClass: 'feedback'
                            , altText: 'Page Feedback'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }
                        , {
                            display: 'Help + Support'
                            , controller: 'HelpCtrl'
                            , path: '/app/components/help/view'
                            , iconClass: 'help'
                            , altText: 'Help + Support'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }
                        , {
                            display: 'About'
                            , controller: 'AboutCtrl'
                            , path: '/app/components/about/view'
                            , iconClass: 'about'
                            , altText: 'Application Information'
                            , modal: 'true'
                            , enabled: 'true'
                            , userAccess: 'true'
                            , systemsAdminAccess: 'true'
                            , organisationAdminAccess: 'true'
                            , section: 'A'
                        }
                    ]
                }
            ];
        };


        return {
            reportMenuTransform: this.transformReportMenuItems,
            getPersonalMenuItemsUpper: this.personalMenuItemsUpper,
            getPersonalMenuItemsMiddle: this.personalMenuItemsMiddle,
            getPersonalMenuItemsLower: this.personalMenuItemsLower
        };

    }


})();