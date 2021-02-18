(function () {
    'use strict';

    angular
        .module('app')
        .controller('NavbarCtrl', NavbarCtrl)


    NavbarCtrl.$inject = ['$scope', '$http', '$location', '$window', '$compile', '$filter', "$uibModal", "Idle", "SystemControlService", "SignOutFactory", "MenuFavouriteService", "AdministrationService", "AtlasCookieFactory", "ModalService", "SystemStateService", "activeUserProfile", "UserService", "DateFactory", "NavigationFactory", "NavigationService", "SignOutService"];

    function NavbarCtrl($scope, $http, $location, $window, $compile, $filter, $uibModal, Idle, SystemControlService, SignOutFactory, MenuFavouriteService, AdministrationService, AtlasCookieFactory, ModalService, SystemStateService, activeUserProfile, UserService, DateFactory, NavigationFactory, NavigationService, SignOutService)
    {

        $scope.modalService = ModalService;
        $scope.statuses = {};
        $scope.reportMenuItems = [];
        $scope.menuFavouriteEntries = [];

        $scope.isReferringAuthority = activeUserProfile.IsReferringAuthority;
        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;
        $scope.ActiveUserProfile = activeUserProfile;
        $scope.isAdmin = activeUserProfile.IsSystemAdmin;
        $scope.isOrganisationAdmin = activeUserProfile.IsOrganisationAdmin;
        $scope.isSystemAdminSupport = activeUserProfile.IsSystemAdminSupport;
        $scope.organisationList = activeUserProfile.OrganisationIds;
        $scope.selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
        $scope.showReportsMenu = false;
        $scope.showPaymentReconciliation = false;
        $scope.showReportsMenuChildren = '';


        $scope.chooseOrganisation = function (theSelectedOrganisation) {

            if (theSelectedOrganisation === undefined) {
                console.log("Please select an organisation");
                return false;
            }
             $scope.profile = JSON.parse(sessionStorage.getItem("userDetails"));
             $scope.profile.selectedOrganisation = {
                Id: theSelectedOrganisation.Id,
                Name: theSelectedOrganisation.Name
            };

            //Persist back to sessionStorage
             sessionStorage.setItem("userDetails", JSON.stringify($scope.profile));

            //Return to Home Screen
            $window.location.href = "/admin";
        };

        /**
         * 
         */
        $scope.$on('savemenufavourite', function (event, args) {
            $scope.mfsStatus = MenuFavouriteService.saveMenuFavourite(args);

            // TODO. return the check for previous existence in mfsStatus and do the below line based on false condition. 
            $scope.menuFavouriteEntries.push(args);

        });

        /**
         * Displays the System Feature Information as clicked from the info icon
         */
        $scope.$on('displaySystemFeatureInformation', function (event, args) {
            
            $scope.SystemFeaturePageName = args.systemFeaturePageName;
                $scope.modalService.displayModal({
                    scope: $scope,
                    title: "Feature " + args.systemFeaturePageName,
                    cssClass: "viewSystemFeatureInformationModal",
                    filePath: "/app/components/systemFeature/viewSystemFeatureInformation.html",
                    controllerName: "ViewSystemFeatureInformationCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogueItself) {
                            dialogueItself.close();
                        }
                    }
                });
           
        });


        /**
         * Handles Idle and Timeout  Section
         */
        function closeModals() {
            if ($scope.warning) {
                $scope.warning.close();
                $scope.warning = null;
            }
        }

        $scope.$on('IdleStart', function () {

            // the user appears to have gone idle
            closeModals();

            $scope.warning = $uibModal.open({
                templateUrl: '/app/shared/navigation/warning-dialog.html',
                windowClass: 'modal-danger'
            });

        });

        $scope.$on('IdleWarn', function (e, countdown) {
            // follows after the IdleStart event, but includes a countdown until the user is considered timed out
            // the countdown arg is the number of seconds remaining until then.
            // you can change the title or display a warning dialog from here.
            // you can let them resume their session by calling Idle.watch()
        });

        $scope.$on('IdleTimeout', function () {
            // the user has timed out (meaning idleDuration + timeout has passed without any activity)
            
            closeModals();
            
            var path = $location.$$absUrl;

            if (path.indexOf("/admin") > -1) {

                SignOutService.SignOut(activeUserProfile.UserId)
                    .then(function (data) {

                        SignOutFactory.admin();

                    }, function (data) {

                    });

            }
            //else if (path.indexOf("/trainer") > -1) {

            //    SignOutFactory.trainer();

            //}
            //else {

            //    SignOutFactory.client();
            //}
        });

        $scope.$on('IdleEnd', function () {
            // the user has come back from AFK and is doing stuff. if you are warning them, you can use this to hide the dialog
            closeModals();

        });

        $scope.$on('Keepalive', function () {
            // do something to keep the user's session alive
        });
        /**
        * End Handles Idle and Timeout  Section
        */




        /* This function is used to set the initial value for an admin's organisation dropdown */
        $scope.setToCurrentOrganisation = function () {
            $scope.selectedOrganisation = $filter('filter')($scope.organisationList, {Id: activeUserProfile.selectedOrganisation.Id})[0];
        }


        /**
          * Get the report menu item from the DB
          * Then manipulate data to get it in a usable format
          */
        $scope.getReportMenuItems = function () {
            var callPath = "NavigationService.reportMenuItems(activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)";
            //NavigationService.reportMenuItems(activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
            NavigationService.userReportList(activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
            .then(
                function (data) {
                    //$scope.reportMenuItems = NavigationFactory.reportMenuTransform(data);
                    $scope.reportMenuItems = data;
                    $scope.getNavigationItems();
                },
                function (response) {
                    var status = response.status;
                    var statusText = response.statusText;
                    var errMessage = "'" + callPath + "' ERROR: (" + status + ") " + statusText;
                    console.log(errMessage);
                    return false;
                }
            );
        };

        /**
         * 
         */
        $scope.getAdministrationMenu = function () {

            AdministrationService.getMenuItems(activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
            .then(
                function (response) {
                    $scope.adminMenu = response.data;
                    console.log($scope.adminMenu);
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        $scope.getPaymentReconciliationStatus = function () {

            NavigationService.getPaymentReconciliationStatus(activeUserProfile.selectedOrganisation.Id)
            .then(
                function (response) {
                    $scope.showPaymentReconciliation = response;
                },
                function (reason) {
                }
            );
        };

        

        /**
         * 
         */
        $scope.getMenuFavourites = function () {
            MenuFavouriteService.getMenuFavourite(activeUserProfile.UserId)
            .then(
                function (response) { 
                    $scope.menuFavouriteEntries = response.data;
                },
                function (reason) { 
                    console.log(reason);
                }
            );
        };

        
        $scope.getNavigationItems = function () {
            NavigationService.getMainNavigationItems(activeUserProfile.UserId)
            .then(
                function (data) {
                    $scope.menuEntries = [
                        {
                            display: "Add Client",
                            path: "",
                            state: "home",
                            iconClass: "add_client_icon",
                            altText: "Add Client",
                            modal: true,
                            enabled: true,
                            templateUrl: '/app/components/client/add',
                            controller: 'addClientCtrl',
                            cssClass: 'clientAddModal',
                            isVisible: (data.AccessToClients && $scope.isReferringAuthority === false && $scope.systemIsReadOnly === false)
                        },
                        {
                            display: "Clients",
                            state: "clients",
                            path: "/admin",
                            iconClass: "clients_icon",
                            altText: "View Clients",
                            modal: false,
                            isVisible: data.AccessToClients
                        },
                        {
                            display: "Reports",
                            state: "home",
                            path: "/admin",
                            iconClass: "reports_icon",
                            altText: "System Reports",
                            isVisible: data.AccessToReports,
                            modal: false,
                            subMenuItems: $scope.reportMenuItems
                        },
                        {
                            display: "My Reports",
                            state: "home",
                            path: "/admin",
                            iconClass: "my_reports_icon",
                            altText: "View My Reports",
                            isVisible: (data.AccessToReports && ($scope.isReferringAuthority === false || $scope.systemIsReadOnly === false)),
                            modal: false,
                            subMenuItems: []
                        },
                        {
                            display: "Courses",
                            state: "Course",
                            path: "/admin/course",
                            iconClass: "contacts_icon",
                            altText: "View Courses",
                            modal: false,
                            isVisible: data.AccessToCourses
                        },
                        {
                            display: "Messaging",
                            state: "home",
                            path: "",
                            iconClass: "send_message_icon",
                            altText: "Messaging",
                            modal: true,
                            enabled: true,
                            templateUrl: '/app/components/messaging/send',
                            controller: 'MessagingCtrl',
                            cssClass: 'messagingModal',
                            isVisible: (true && ($scope.isReferringAuthority === false || $scope.systemIsReadOnly === false))
                        }
                    ];
                },
                function (response) {
                    console.log(reason);
                }
            );
        };

        //Get idle, timeout Settings
        $scope.getSystemControlIdleTimeout = function () {

            SystemControlService.Get()
                .then(
                    function (reason) {
                        console.log("Success");
                        console.log(reason.data);
                        
                        // check for nulls
                        Idle.setIdle(reason.data.SystemInactivityTimeout - reason.data.SystemInactivityWarning);
                        Idle.setTimeout(reason.data.SystemInactivityWarning);
                        

                    },
                    function (reason) {
                        console.log(reason);
                    }
                );
        }
        
        $scope.toggleShowHideMenuChildren = function (menuParent) {

            if ($scope.showReportsMenuChildren == menuParent) {
                $scope.showReportsMenuChildren = '';
            } else {
                $scope.showReportsMenuChildren = menuParent;
            }
        }

        /**
        * Display modal or hidden menu
        */
        $scope.showModalorHiddenMenu = function (menuItem, $event) {
            if (menuItem.modal) {
                $scope.ShowMenuItem(menuItem.display, menuItem.templateUrl, menuItem.controller, menuItem.enabled, menuItem.modal, menuItem.cssClass);
            }
            else {
                $scope.showHiddenMenu(menuItem.subMenuItems, menuItem.display, $event);
            }
        };




        /**
            * Show the hidden menu
            */
        $scope.showHiddenMenu = function (subItems, title, $event) {

            if (subItems === undefined) {
                $scope.hideHiddenMenu();
                return false;
            }
            $scope.theRelatedSubMenuItems = subItems;
            $scope.theRelatedSubMenuTitle = title;
            //$scope.hideMenuMoveContainer(true, "430px");
            $scope.showReportsMenu = true;
        };

       
        /**
         * Call the get report menu items method
         * And put report items on the scope
         */
        $scope.getReportMenuItems();


        /**
         * Then get nav items
         */
        //$scope.getNavigationItems();

        /**
         *  Then get menu faves
         */
        $scope.getMenuFavourites();

        /**
         * Then get the admin menu
         */
        $scope.getAdministrationMenu();

        /**
         * Then get the idle and timeout settings
         */
        $scope.getSystemControlIdleTimeout();

        /**
         * Moved to the nav factory
         */
        $scope.personalMenusUpper = NavigationFactory.getPersonalMenuItemsUpper();

        $scope.personalMenusMiddle = NavigationFactory.getPersonalMenuItemsMiddle();

        $scope.personalMenusLower = NavigationFactory.getPersonalMenuItemsLower();

        $scope.showPersonal = function () {
            $scope.showPersonalMenu = true;
        };

        /**
         * Close the hidden menu
         */
        $scope.hideHiddenMenu = function ($event) {
            $scope.hideMenuMoveContainer(false, "135px");
            $scope.showReportsMenu = false;
        };


        /**
         * Hide the menu and animate the container
         */
        $scope.hideMenuMoveContainer = function (visibility, margin) {
            $scope.isHiddenMenuVisible = visibility;
            //$("#mainContentContainer").animate({
            //    marginLeft: margin
            //}, 500);
        };

        /**
         * Change to the modal service
         */
        $scope.ShowMenuItem = function (title, url, controller, enabled, modal, cssClass) {
            if (enabled === 'true' || enabled == true) {
                if (modal === 'true' || modal == true) {

                    $scope.modalService.displayModal({
                        scope: $scope,
                        title: title,
                        cssClass: cssClass,
                        filePath: url + ".html",
                        controllerName: controller,
                        buttons: {
                            label: 'Close',
                                cssClass: 'closeModalButton',
                                action: function (dialogItself) {
                                dialogItself.close();
                            }
                        }
                    });

                } else {
                    $location.url(url);
                }
            }
        }

        $scope.showReportParameters = function (reportID) {
            //Open the report parameters modal, passing in the report id

            $scope.report = reportID;
            $scope.selectedReport = reportID;
            $scope.isModal = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Run Report",
                cssClass: "reportParametersModal",
                filePath: "/app/components/report/reportparameters.html",
                controllerName: "reportParametersCtrl"
            });
        }


        $scope.adminTabOpen = function (tabPanelId, contentPanelId) {
            var contentPanel = $('#' + contentPanelId)
            var pos = $('#' + tabPanelId).position();
            var offSet = $('#' + tabPanelId).offset();
            contentPanel.css({
                position: "absolute",
            // top: offSet.top + "px",
                right: "30px"
            }).show('slide', { direction: 'right' });
            $('#' + tabPanelId).fadeOut();
        };
        $scope.adminDataClose = function (tabPanelId, contentPanelId) {
            var tabPanel = $('#' + tabPanelId)
            $('#' + contentPanelId).fadeOut();
            tabPanel.fadeIn();
        };

        $scope.topTabOpen = function (tabPanelId, contentPanelId) {
            var contentPanel = $('#' + contentPanelId)
            var offSet = $('#' + tabPanelId).offset();
            contentPanel.css({
                position: "absolute",
                right: offSet.right + "px",
                left: offSet.left + "px",
            // top: "30px"
            }).show('slide', { direction: 'up' });
            $('#' + tabPanelId).fadeOut();
        };
        $scope.topDataClose = function (tabPanelId, contentPanelId) {
            var tabPanel = $('#' + tabPanelId)
            $('#' + contentPanelId).fadeOut();
            tabPanel.fadeIn();
        };



        $scope.getStatusSystemLevel = function () {
            var averageState = 0;
            if ($scope.statuses.length === 0) {
                averageState = 4;
            }
            else {
                var cummulativeTotal = 0;
                for (var i = 0; i < $scope.statuses.length; i++) {
                    cummulativeTotal += $scope.statuses[i].SystemStateId;
                }
                averageState = Math.ceil(cummulativeTotal / $scope.statuses.length);
            }
            return "Level" + averageState;
        }

        $scope.FormatDate = function (date) {

            var parsedDate = DateFactory.parseDate(date);

            // first time running initialise the last system checked date
            if (!$scope.statusCheckedAtDate) {
                $scope.statusCheckedAtDate = parsedDate;
                $scope.statusCheckedAt = $scope.statusCheckedAtDate.toLocaleString();
            }

            // if this date is more recent than the latest time it was checked update the last check time.
            if (date > $scope.statusCheckedAtDate)
            {
                $scope.statusCheckedAtDate = parsedDate;
                $scope.statusCheckedAt = $scope.statusCheckedAtDate.toLocaleString();
            }

            // return the inputted date in the local string format
            return parsedDate.toLocaleString();
        }

        $scope.getStatusItemLevel = function (status) {
            return "Level" + status.SystemStateId;
        }

        $scope.getStatuses = function () {
            $scope.statuses = {};
            SystemStateService.getStatuses(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        // this callback will be called asynchronously
                        // when the response is available
                        $scope.statuses = response.data;
                    },
                    function errorCallback(response) {
                        // called asynchronously if an error occurs
                        // or server returns response with an error status.
                    }
                );
        }

        $scope.getStatuses();


        /**
         * Method that looks at the menus in the list
         * If there are children show the div
         */
        $scope.processHiddenMenuClick = function (children, $event)
        {
            var childrenArrayAmount = 0;

            /**
                * Check to see if the object exists
                */
            if (children !== undefined) {
                childrenArrayAmount = children.length;
            }

            /**
                * Check to see if the amount of children
                * If greater that 0
                * Open/Close the div
                */
            if (childrenArrayAmount > 0) {
                /**
                    * When clicking on the parent
                    * It'll show the reports in that category
                    */
                $($event.currentTarget).parent().children("ul.sub-menu-children").toggle(function () {
                    var selector = $(this);
                    var currentListItem = selector.parent()[0];
                    $(currentListItem).toggleClass("closed-drop-icon");
                });
            } else {
                // @todo process to go to link
                console.log("Go to link");
            }
        };

        /**
         * Check to see whether any other divs are open
         * If they are closes them before opening new one
         */
        $scope.closeOtherOpenDivs = function ($event) {

            var currentSelector = $($event.target);
            var adminMenuSelector = currentSelector.parent().parent();

            var childDiv = currentSelector.next();
            var isChildOpen = childDiv.is(":visible");

            /**
             * If clicking to close a div
             * Does not close other divs
             */
            if (isChildOpen !== true) {
                var openSubMenuItems = adminMenuSelector.find(".list-group-submenu:visible");
                openSubMenuItems.each(function (index, value) {
                    $(value).removeClass("in");
                });
            }

        };

        $scope.toggleAdminSupportUser = function () {

            if ($scope.isSystemAdminSupport) {

                UserService.unmakeAdminSupportUser(activeUserProfile.UserId, activeUserProfile.UserId)
                        .then(
                            function (data) {
                                if (data === false) {
                                    // maybe push message in to the notification queue to display in the system information bar
                                    //$scope.errorMessage = "Couldn't remove administrator support user, please contact support.";
                                }
                                else {
                                    $scope.isSystemAdminSupport = false;
                                    activeUserProfile.IsSystemAdminSupport = false;
                                    $scope.personalMenusMiddle;

                                }
                            },
                            function (data) {
                                // maybe push message in to the notification queue to display in the system information bar
                                //$scope.errorMessage = "An error occurred, please try again.";
                            }
                        );

            }
            else {

                UserService.makeAdminSupportUser(activeUserProfile.UserId, activeUserProfile.UserId)
                       .then(
                           function (data) {
                               if (data === false) {
                                   // maybe push message in to the notification queue to display in the system information bar
                                   //$scope.errorMessage = "Couldn't make user into a support user.  Please contact support.";
                               }
                               else {
                                   $scope.isSystemAdminSupport = true;
                                   activeUserProfile.IsSystemAdminSupport = true;
                                   $scope.personalMenusMiddle;

                               }
                           },
                           function (data) {
                               // maybe push message in to the notification queue to display in the system information bar
                               //$scope.errorMessage = "An error occurred, please try again.";
                           }
                       );
               
            }
        }

        // If browser is closed (x) update ExpiresOn in LoginSession to Now() and Delete from Local Storage
        /*
        $scope.onExit = function () {

            //SignOutService.SignOut(activeUserProfile.UserId)
            //.then(function (data) {

                SignOutFactory.admin();

            //}, function (data) {

            //});

        };

        // If browser is closed update 
        $window.onbeforeunload = $scope.onExit;
        */

        $scope.getPaymentReconciliationStatus();

    }

})();


   