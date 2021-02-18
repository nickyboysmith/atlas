(function () {
    'use strict';

    angular
        .module('app')
        .controller('venueCtrl', venueCtrl);

    venueCtrl.$inject = ['$scope', '$timeout', '$location', '$window', '$http', 'VenueService', 'UserService', 'CraftyClicksFactory', 'CraftyClicksService', "GetAddressFactory", "GetAddressService", 'ModalService', 'VenueCostService', 'VenueCourseTypeService', 'ModalOptionsFactory', 'VenueImageMapService', "activeUserProfile"];

    function venueCtrl($scope, $timeout, $location, $window, $http, VenueService, UserService, CraftyClicksFactory, CraftyClicksService, GetAddressFactory, GetAddressService, ModalService, VenueCostService, VenueCourseTypeService, ModalOptionsFactory, VenueImageMapService, activeUserProfile) {

        $scope.venue = {};
        $scope.venue.selectedOrganisation = {};
        $scope.selectedVenue = null;
        $scope.organisations = {};
        $scope.regions = {};
        $scope.venueService = VenueService;
        $scope.userService = UserService;
        $scope.modalService = ModalService;
        $scope.venueCostService = VenueCostService;
        $scope.venueCourseTypeService = VenueCourseTypeService;
        $scope.venues = {};
        $scope.TransformedAddressList = [];
        $scope.AddressList = [];
        $scope.selectedVenueCost = -1;
        $scope.selectedVenueCourseType = -1;
        $scope.selectedVenueLocaleId = "";
        $scope.statusMessage = "";
        $scope.errorMessage = false;
        $scope.venueImageMapTitle = '';

        // first time through set the defaults.
        $scope.onFirst = true;


        if (activeUserProfile.selectedOrganisation) {
            $scope.venue.selectedOrganisation = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.venue.selectedOrganisation = activeUserProfile.OrganisationIds[0].Id;

            }
        }


        $scope.getOrganisationOptions = function () {
            $scope.userId = activeUserProfile.UserId;
            $scope.clearMessages();

            //Reset the venue
            var orgSelected = $scope.venue.selectedOrganisation;
            //Clear the Venue to allow adding new
            $scope.venue = {};
            $scope.venue.selectedOrganisation = orgSelected;

            $scope.userService.checkSystemAdminUser($scope.userId).then(function (response) {
                $scope.isAdmin = JSON.parse(response);
            });


            $scope.venueService.getUserOrganisations($scope.userId).then(function (response) {
                console.log(response);
                $scope.organisations = response;

                
            });

            
        };

        /**
        * Get the Regions associated with the selected Organisation
        */
        $scope.getOrganisationRegions = function (orgId) {
            $scope.clearMessages();
            $scope.venueService.getOrganisationRegions(orgId, $scope.userId).then(function (response) {
                $scope.regions = response;

                // if first time set the default region and get the venues 
                if ($scope.onFirst = true) {
                    if ($scope.regions.length > 0) {


                        $scope.ALLItem = {
                            id: null,
                            name: "*ALL*"
                        };

                        $scope.regions.unshift($scope.ALLItem);



                        $scope.venue.selectedRegion = $scope.regions[0].id;
                        $scope.getOrganisationVenuesByRegion($scope.venue.selectedOrganisation, $scope.venue.selectedRegion);
                    }
                };
                $scope.onFirst = false;

                $scope.venues = {};
            });
        }

        /**
       * Get the Venues associated with the selected Organisation and/or Region
       */
        $scope.getOrganisationVenuesByRegion = function (orgId, regId) {
            $scope.clearMessages();

            angular.forEach($scope.regions, function (value, key) {
                if (regId == value.id)
                    $scope.selectedRegionName = value.name;
            });

            $scope.venue.selectedRegion = regId;

            $scope.venueService.getOrganisationVenuesByRegion(orgId, regId)
                .then(function (response) {

                    if (response.length > 0) {
                        $scope.venues = response;
                    }
                    else {

                        $scope.venues = {};
                        //$scope.venue = {};
                    }
                });
        }

        /**
        * Get the details of the Venue that is selected
        */
        $scope.getVenueDetails = function (venueId) {
            //Call on VenueService to get key venue details for the selected venue...
       
            $scope.venueService.getVenue(venueId, $scope.userId)
                .then(function (response) {

                    $scope.extendVenueModal();

                    var selectedOrg = $scope.venue.selectedOrganisation;
                    var selectedReg = $scope.venue.selectedRegion;
                    $scope.venue = response[0];
                    $scope.venue.selectedOrganisation = selectedOrg;
                    $scope.venue.selectedRegion = selectedReg;

                    $scope.selectedVenue = venueId;

                    //need to negate endabled as we are showing disabled
                    $scope.venue.disabled = !$scope.venue.enabled;

                    // add an empty email 
                    $scope.addNewEmailAddress();

                    // clear the venue image map title
                    $scope.venueImageMapTitle = '';

                    VenueImageMapService.getVenueImageMap(venueId)
                        .then(
                            function successCallback(response) {
                                if (response.data) {
                                    $scope.venueImageMapTitle = response.data.Title;
                                }
                            },
                            function errorCallback(response) {
                                console.log("Couldn't load venue image map.")
                            }
                        );
                });
        }


        // used by child modals to refresh this page's venue cost list after deletion or addition
        $scope.refreshVenueModalVenueCosts = function () {
            $scope.venueService.getVenueCosts($scope.venue.id)
                        .then(function (response) {
                            $scope.selectedVenue = -1;
                            $scope.venue.venueCosts = response;
                        });
        }

        $scope.saveVenueDetails = function () {

            $scope.statusMessage = "";
            $scope.errorMessage = "";

            if ($scope.venueMeetsMinimumRequirements()) {

                $scope.venueService.saveVenueDetails($scope.venue)
                    .then(function (data, status) {
                        $scope.getOrganisationVenuesByRegion($scope.venue.selectedOrganisation, $scope.venue.selectedRegion);
                        $scope.venue.id = data;
                        $scope.selectedVenue = $scope.venue.id;
                        $scope.statusMessage = "Venue '" + $scope.venue.title + "' Saved";
                    }, function (data, status) {

                        $scope.errorMessage = 'Venue save failed!';
                    });
            }
            else {
                if($scope.venue.address.length == 0){
                    $scope.errorMessage = 'Please enter an address.';
                }
                else {
                    if ($scope.regions.length > 1) {
                        $scope.errorMessage = 'Please select an organisation, region and title before saving';
                    }
                    else {
                        $scope.errorMessage = 'Please select an organisation and title before saving';
                    }
                }
            }
        }

        $scope.venueMeetsMinimumRequirements = function () {
            if($scope.venue.selectedOrganisation > 0
                && ($scope.venue.selectedRegion > 0 || $scope.venue.selectedRegion != null)
                && $scope.venue.title.length > 0
                && $scope.venue.address.length > 0) {
                return true;
            } else {
                return false;
            }
        }

        $scope.clearMessages = function () {
            $scope.statusMessage = "";
            $scope.errorMessage = '';
        }

        $scope.addVenue = function () {
            $scope.clearMessages();
            $scope.extendVenueModal();
            var orgSelected = $scope.venue.selectedOrganisation;
            var regSelected = $scope.venue.selectedRegion;
            //Clear the Venue to allow adding new
            $scope.venue = {};
            $scope.venue.selectedOrganisation = orgSelected;
            $scope.venue.selectedRegion = regSelected;

            // clear the venue image map title
            $scope.venueImageMapTitle = '';

            // add an empty email 
            $scope.addNewEmailAddress();

            $scope.selectedVenue = null;
        }

        $scope.postcodePopulate = function () {
            $scope.venue.postCode = $scope.postcodeAddressLookup;
        }

        //$scope.getOrganisationOptions();

        /**
         * Get the address choices
         */
        $scope.getAddressChoices = function () {

            //CraftyClicksService.getAddress($scope.venue.postCode)
            GetAddressService.getAddress($scope.venue.postCode)
                .then(function (response) {

                    /**
                     * Set the addreess list
                     */
                    $scope.AddressList = response;

                    /**
                     * Transform the Address List
                     */
                    // $scope.TransformedAddressList = CraftyClicksFactory.transform(response.delivery_points);

                    $scope.TransformedAddressList = response.Addresses;

                }, function(response) {
                    alert("There was an issue retrieving your address");
                });
        }

        /**
         * Merge the address to enter in to the text field
         */
        $scope.selectAddress = function (theSelectedAddress) {


            //$scope.venue.address = CraftyClicksFactory.merge(selectedAddress, $scope.AddressList);

            if (theSelectedAddress) {
                $scope.venue.address = GetAddressFactory.format(theSelectedAddress);
            }

            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];

            /**
             * Empty the address List
             */
           // $scope.AddressList = [];

        }

        $scope.addNewEmailAddress = function () {
            //if emails variable is null or undefined
            if (!$scope.venue.emails == true)
            {
                $scope.venue.emails = [];
            }

            //Add another empty email field to the emails variable
            $scope.venue.emails.push({
                id:0,
                emailAddress: "",
                isMain: false
            });

        }

        $scope.addVenueCost = function () {
            $scope.addingVenueCost = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add Venue Cost",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/venueCost/edit.html",
                controllerName: "VenueCostCtrl",
                cssClass: "AddVenueCostModal"
            });
        }

        $scope.selectVenueCost = function (venueCostId) {
            if ($scope.selectedVenueCost == venueCostId) {
                $scope.selectedVenueCost = -1;
            }
            else
            {
                $scope.selectedVenueCost = venueCostId;
            }
        }

        $scope.getVenueCostDetails = function (venueCostId) {
            if (venueCostId > 0) {
                $scope.addingVenueCost = false;     // so we don't let them choose another cost type
                $scope.selectedVenueCost = venueCostId;
                $scope.modalService.displayModal({
                    scope: $scope,
                    title: "Edit Venue Cost",
                    closable: true,
                    closeByBackdrop: false,
                    closeByKeyboard: false,
                    draggable: true,
                    filePath: "/app/components/venueCost/edit.html",
                    controllerName: "VenueCostCtrl",
                    cssClass: "AddVenueCostModal"
                });
            }
        }

        $scope.removeVenueCost = function () {
            if ($scope.selectedVenueCost)
            {
                $scope.venueCostService.deleteVenueCost($scope.selectedVenueCost)
                    .then(function (data) {
                        $scope.refreshVenueModalVenueCosts();
                    });
            }
        }



        
        $scope.selectVenueCourseType = function (venueCourseTypeId) {
                $scope.selectedVenueCourseType = venueCourseTypeId;
        }


        $scope.removeVenueCourseType = function () {
            if ($scope.selectedVenueCourseType) {
                $scope.venueCourseTypeService.deleteVenueCourseType($scope.selectedVenueCourseType)
                    .then(function (data) {
                        $scope.refreshVenueCourseTypeModal();
                    });
            }
        }

        $scope.addVenueCourseType = function () {
            $scope.addingCourseType = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Select Course Type",
                closable: true,
                closeByBackdrop: false,
                closeByKeyboard: false,
                draggable: true,
                filePath: "/app/components/venueCourseType/add.html",
                controllerName: "addVenueCourseTypeCtrl",
                cssClass: "xxxAddCourseType",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        $scope.openVenueImageMapModal = function () {
            $scope.venueId = $scope.selectedVenue;
            $scope.venueTitle = $scope.venue.title;
            ModalService.displayModal({
                scope: $scope,
                title: "Venue Image Map",
                filePath: "/app/components/venue/venueImageMap.html",
                controllerName: "VenueImageMapCtrl",
                cssClass: "venueImageMapModal"
            });
        }


        $scope.isRegionSelected = function () {

            if ($scope.venue.selectedRegion == null) {
                return true;
            }
            else {
                return false;
            }
        }

       /**
        * Add venue Locale
        */
        $scope.addVenueLocale = function (isEdit) {

            /**
             * Check to see if the edit is empty
             * If it is then add an error message
             */
            if (isEdit !== undefined && $scope.selectedVenueLocaleId === "") {
                console.log("Issue: No locale has been selected");
                return false;
            }

            /**
             * If it is empty 
             * But something was previously selected
             * Clear it
             */
            if (isEdit === undefined && $scope.selectedVenueLocaleId !== "") {
                $scope.selectedVenueLocaleId = "";
            }

            console.log("we open here");
            ModalService.displayModal({
                scope: $scope,
                title: "Add Venue Locale",
                filePath: "/app/components/venueLocale/add.html",
                controllerName: "AddVenueLocaleCtrl",
                cssClass: "addVenueLocaleModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        };

        /**
         * Select the venue locale Id
         * Add to the scope
         */
        $scope.selectVenueLocale = function (venueLocaleId) {
            if (venueLocaleId !== undefined) {
                $scope.selectedVenueLocaleId = venueLocaleId;
                console.log($scope.selectedVenueLocaleId)
            }
        }
       
        // used by child modals to refresh this page
        $scope.refreshVenueCourseTypeModal = function () {
            $scope.venueService.getVenueCourseTypes($scope.venue.id)
                        .then(function (response) {
                            $scope.selectedVenueCourseType = -1
                            $scope.venue.courseTypes = response;
                        });
        }

        /**
         * Get the venue Locale
         */
        $scope.getVenueLocale = function (venueId) {
            VenueService.getVenueLocale(venueId)
                .then(
                    function (response) {
                        $scope.venue.venueLocales = response.data;
                        console.log(response.data);
                    },
                    function (response) {
                        console.log(response);
                    }
                );
        };

        /**
         * Extend the venue modal
         */
        $scope.extendVenueModal = function () {

            /**
             * Extend the modal!
             */
            ModalOptionsFactory.extend({
                mainModalID:    "#viewVenue",
                firstColumn:    "#firstVenueModalColumn",
                secondColumn:   "#additionalVenueDetailContainer",
                classToRemove:  "col-md-12",
                classToAdd:     "col-md-3",
                cssProperties:  {
                    width: "1000px"
                }
            });
        };

        $scope.setRegionModal = function (venueId) {
            $scope.venueId = venueId;
            ModalService.displayModal({
                scope: $scope,
                title: "Add Region to Venue",
                filePath: "/app/components/venue/addRegion.html",
                controllerName: "AddVenueRegionCtrl",
                cssClass: "addVenueRegionModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        // this function is so we can reload the modal from child modals
        $scope.loadVenueModal = function () {
            $scope.getOrganisationOptions();
            $scope.getOrganisationRegions($scope.venue.selectedOrganisation);
        }

        $scope.loadVenueModal();

        
    }
})();


