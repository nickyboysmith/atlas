(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ClientsCtrl', ClientsCtrl);

    ClientsCtrl.$inject = ['$scope', '$location', '$window', '$http', '$compile', 'AtlasCookieFactory', 'SearchHistoryService', 'activeUserProfile', "ModalService", "ClientService"];

    function ClientsCtrl($scope, $location, $window, $http, $compile, AtlasCookieFactory, SearchHistoryService, activeUserProfile, ModalService, ClientService) {

        $scope.cookieFactory = AtlasCookieFactory;

        var once = false;
        $scope.maxResults = 15;
        $scope.pagesToDisplay = 7;
        $scope.systemIsReadOnly = activeUserProfile.SystemIsReadOnly;

        $scope.$root.title = 'Client Search';

        $scope.clientSearch = new Object();
        if (activeUserProfile.selectedOrganisation) {
            $scope.clientSearch.organisationId = activeUserProfile.selectedOrganisation.Id;
        }

        $scope.maxRows = $scope.cookieFactory.getCookie("clientMaxRows");
        if ($scope.maxRows == undefined || !$scope.maxRows) $scope.maxRows = 200;

        $scope.$on('$viewContentLoaded', function () {
            $window.ga('send', 'pageview', { 'page': $location.path(), 'title': $scope.$root.title });
        });

        /* Start of search history params */
        $scope.userId = activeUserProfile.UserId;  // the logged in user Id, chosen at random
        $scope.baseScreenId = "ClientSearchPage";   // the search interface title

        /**
         * Set the scope.results object
         */
        $scope.results = {};

        /*
         * Set the scope.searches object
         */
        $scope.searches = {};

        /**
         * Put Course service on the scope
         */
        $scope.searchHistoryService = SearchHistoryService;

        /**
         * Call the method to pull the searches from the DB
         */
        $scope.searchHistoryService.getPreviousSearches($scope.baseScreenId, $scope.userId)
            .then(function (data) {
                var transformation = $scope.searchHistoryService.transformSearchData(data);
                $scope.searches = transformation.searches;
                $scope.results = transformation.results;
            }, function () {
            });

        /**
         * Add the search to the course object
         */
        $scope.loadSearchParams = function () {
            $scope.clientSearch = $scope.results[$scope.previousSearch];
        };

        /* End of search history params */

        //getClients function starts
        $scope.getClients = function () {

            $scope.cookieFactory.createCookie("clientMaxRows", $scope.maxRows, { expires: 18 });

            // Put maxRows on to the ClientSearch object
            $scope.clientSearch.clientMaxRows = $scope.maxRows;

            $scope.processing = true;
            $scope.noResults = false;
            $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

            $http.post(apiServer + '/clientsearch/search', $scope.clientSearch)
                .then(function (response, status, headers, config) {

                    $scope.clients = response.data;
                    $scope.clientsTemplate = $scope.clients;
                    if (!once) {
                        // give "smart-table" a table data template that won't change so it can maintain the structure while refreshing the data with an ajax call
                        // passed in to the table tag via the attribute "st-safe-src"
                        $scope.clientsTemplate = [].concat($scope.clients);
                        once = true;
                    }
                    if ($scope.previousSearch == undefined || $scope.previousSearch == '' || $scope.previousSearch == '1') {
                        // save the search into the search history
                        $scope.searchDetails = {};

                        $scope.searchDetails.userId = $scope.userId;
                        $scope.searchDetails.screenId = $scope.baseScreenId;
                        $scope.searchDetails.searchParams = $scope.clientSearch;

                        $scope.searchHistoryService.saveCurrentSearch($scope.searchDetails);
                    }
                    $scope.processing = false;
                    if ($scope.clients.length == 0) {
                        $scope.noResults = true;
                    }

                }, function(response, status, headers, config) {
                    alert('Error retrieving client list');
                    $scope.processing = false;
                });
        }


        //'Find My Clients' Search
        $scope.getSearchedClients = function () {

            $scope.cookieFactory.createCookie("clientMaxRows", $scope.maxRows, { expires: 18 });

            $scope.clientSearch.userId = $scope.userId;

            // Put maxRows on to the ClientSearch object
            $scope.clientSearch.clientMaxRows = $scope.maxRows;

            $scope.processing = true;
            $scope.noResults = false;
            $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

            $http.post(apiServer + '/clientsearch/SearchViewedClients', $scope.clientSearch)
                .then(function (response, status, headers, config) {

                    $scope.clients = response.data;
                    $scope.clientsTemplate = $scope.clients;
                    if (!once) {
                        // give "smart-table" a table data template that won't change so it can maintain the structure while refreshing the data with an ajax call
                        // passed in to the table tag via the attribute "st-safe-src"
                        $scope.clientsTemplate = [].concat($scope.clients);
                        once = true;
                    }
                    if ($scope.previousSearch == undefined || $scope.previousSearch == '' || $scope.previousSearch == '1') {
                        // save the search into the search history
                        $scope.searchDetails = {};

                        $scope.searchDetails.userId = $scope.userId;
                        $scope.searchDetails.screenId = $scope.baseScreenId;
                        $scope.searchDetails.searchParams = $scope.clientSearch;

                        $scope.searchHistoryService.saveCurrentSearch($scope.searchDetails);
                    }
                    $scope.processing = false;
                    if ($scope.clients.length == 0) {
                        $scope.noResults = true;
                    }

                }, function (response, status, headers, config) {
                    alert('Error retrieving client list');
                    $scope.processing = false;
                });
        }

        $scope.showClient = function (client) {
            return !client.Disabled || $scope.showDisabled;
        }

        /**
         * Method to open the add client modal
         */
        $scope.addClientModal = function () {

            ModalService.displayModal({
                scope: $scope,
                cssClass: "clientAddModal",
                title: "Add client",
                controllerName: "addClientCtrl",
                filePath: "/app/components/client/add.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };





        /**************************************************************************
         * 
         * Start client list options menu
         * 
         **************************************************************************/

        /**
         * Context menu object
         */
        $scope.clientListOptions = {
            view: {
                altText: "View Client Details",
                name: "View",
                modalTitle: "Client Details",
                modalFilePath: "/app/components/client/cd_view.html",
                modalController: "clientDetailsCtrl",
                modalClass: "clientDetailModal",
                hideIfLocked: false
            },
            edit: {
                altText: "Edit Client Details",
                name: "Edit",
                modalTitle: "Edit Client Details",
                modalFilePath: "/app/components/client/edit.html",
                modalController: "editClientCtrl",
                modalClass: "clientEditModal",
                hideIfLocked: true
            },
            addNote: {
                altText: "Add a Client Note",
                name: "Add Note",
                modalTitle: "Add Client Note",
                modalFilePath: "/app/components/client/addNote.html",
                modalController: "addClientNoteCtrl",
                modalClass: "clientAddNoteModal",
                hideIfLocked: false
            },
            takePayment: {
                altText: "Take a Client Payment for Processing",
                name: "Take Payment",
                modalTitle: "Take Card Payment",
                modalFilePath: "/app/components/payment/acceptCard.html",
                modalController: "AcceptCardPaymentCtrl",
                modalClass: "acceptCardPaymentModal",
                hideIfLocked: true
            },
            addPayment: {
                altText: "Enter the Details of a Client Payment",
                name: "Enter Payment",
                modalTitle: "Enter Payment Transaction",
                modalFilePath: "/app/components/payment/record.html",
                modalController: "RecordPaymentCtrl",
                modalClass: "recordPaymentModal",
                hideIfLocked: true
            },
            bookCourse: {
                altText: "Book Course",
                name: "Book Course",
                modalTitle: "",
                modalFilePath: "",
                modalController: "",
                modalClass: "",
                hideIfLocked: true
            },
            sendClientEmail: {
                altText: "Send Client an Email",
                name: "Send Email",
                modalTitle: "Send Client an Email",
                modalFilePath: "/app/components/email/view.html",
                modalController: "SendEmailCtrl",
                modalClass: "sendClientEmailModal",
                hideIfLocked: false
            },
            sendClientSMS: {
                altText: "Send Client an SMS",
                name: "Send SMS",
                modalTitle: "Send Client an SMS",
                modalFilePath: "/app/components/SMS/client.html",
                modalController: "ClientSMSCtrl",
                modalClass: "sendClientSMSModal",
                hideIfLocked: false
            },
            refundPayments: {
                altText: "Refund Payment",
                name: "Refund Payment",
                modalTitle: "Client Payments",
                modalFilePath: "/app/components/client/payments.html",
                modalController: "ClientPaymentsCtrl",
                modalClass: "ClientPaymentsModal",
                hideIfLocked: false
            }
        }

        /**
         * Open the client view in a modal when clicked
         */
        $scope.clientViewPage = function (clientID, index) {

            $scope.clientId = clientID;
            $scope.clientIndex = index;

            ModalService.displayModal({
                scope: $scope,
                cssClass: "clientDetailModal",
                title: "Client Details",
                controllerName: "clientDetailsCtrl",
                filePath: "/app/components/client/cd_view.html",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };

        /**
         * Open a modal from the content menu
         */
        $scope.openModalFromContextMenu = function (clientOption, clientID, clientDisplayName, clientPhone, clientEmail) {


            var clientObjectToPass = {
                clientName: clientDisplayName,
                courseName: "",
                isAssignedTo: "client",
                clientId: clientID,
                clientPhoneNumber: clientPhone,
                clientEmailAddress: clientEmail
            };

            /**
             * Check to see if Take payment has been added
             * If it has then add object
             */
            if (clientOption.name === "Take Payment") {
                $scope.clientTakePaymentDetail = clientObjectToPass;
            }

            /**
             * Check to see if Take payment has been added
             * If it has then add object
             */
            if (clientOption.name === "Enter Payment") {
                $scope.successfulPayment = clientObjectToPass;
            }


            if (clientOption.name === "Send SMS") {
                $scope.sendSMSFromClientsMenu = clientObjectToPass;
            }

            if (clientOption.name === "Send Email") {
                $scope.sendEmailFromClientsMenu = clientObjectToPass;
            }

            if (clientOption.name === "Refund Payment") {

            }

            $scope.clientId = clientID;
            ModalService.displayModal({
                scope: $scope,
                cssClass: clientOption.modalClass,
                title: clientOption.modalTitle,
                controllerName: clientOption.modalController,
                filePath: clientOption.modalFilePath,
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        // is the number a UK format phone number?
        $scope.isMobile = function (phoneNumber) {
            var mobile = false;
            if (/^(\+44\s?7\d{3}|\(?07\d{3}\)?)\s?\d{3}\s?\d{3}$/.test(phoneNumber)) {
                mobile = true;
            }
            return mobile;
        }

        $scope.getIsLocked = function (clientId, organisationId, userId) {
            ClientService.getClientLock(clientId, organisationId, userId)
            .then(
                function (response) {
                    $scope.theClientIsLocked = response.data.IsReadOnly;
                    $scope.lockedByUserName = response.data.LockedByUserName;
                    $scope.clientHiddenMenuVisible = true;

                },
                function(reason) {
                    console.log(reason);
                    }
            );
                };

        /**
         * Open the client menu
         */
        $scope.openClientMenu = function (clientId, clientName, clientPhone, clientEmail, $event, index) {

            /**
             * Check position of the mouse click and 
             * how far down the page it is 
             * Percent wise
             */
            $scope.clickRawPercentage = $event.clientY / $(window).height();
            $scope.clickPercent = $scope.clickRawPercentage.toFixed(2);

            /**
             * Set the position of the context menu
             */
            $scope.hiddenMenuTop = $event.pageY + "px";
            $scope.hiddenMenuLeft = $event.pageX + "px";

            /**
             * Check to see if the context menu is going over the page
             */
            if ($scope.clickPercent > 0.75) {
                var newAmount = (parseInt($event.pageY) - 211);
                $scope.hiddenMenuTop = newAmount + "px";
            }

            /**
             * Create object to pass to Ng Style
             */
            $scope.menuStyle = {
                top: $scope.hiddenMenuTop,
                left: $scope.hiddenMenuLeft
            };

            /**
             * Set the clients name
             */
            $scope.theClientName = clientName;

            /**
             * Set the client ID
             */
            $scope.theClientID = clientId;

            /**
             * See the client is locked
             */
            $scope.getIsLocked(clientId, activeUserProfile.selectedOrganisation.Id, activeUserProfile.UserId);

            /**
            * Is the current client's phone number a mobile phone?
            */
            $scope.currentClientHasMobile = false;
            $scope.currentClientPhone = '';
            if (clientPhone) {
                if ($scope.isMobile(clientPhone)) {
                    $scope.currentClientPhone = clientPhone;
                    $scope.currentClientHasMobile = true;
                }
            }

            /*
            * Set the client email
            */
            $scope.currentClientEmail = clientEmail;

            $scope.clientIndex = index;

        };

        $scope.showMenuItem = function (optionName, currentClientPhone, currentClientEmail) {
            var show = false;
            if (optionName == 'Send SMS') {
                if($scope.isMobile(currentClientPhone)) {
                    show = true;
                }
             }
             else if (optionName == 'Send Email') {
                if (currentClientEmail && currentClientEmail != '') {
                    show = true;
                }
            }
            else {
                show = true;
            }
            return show;
        }

        $scope.openDeletedClients = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Clients Marked For Deletion",
                cssClass: "userSearchModal",
                filePath: "/app/components/client/clientsMarkedForDeletion.html",
                controllerName: "ClientsMarkedForDeletionCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
    };

        /**************************************************************************
         * 
         * End Client list options
         * 
         **************************************************************************/

    }
    }) ();