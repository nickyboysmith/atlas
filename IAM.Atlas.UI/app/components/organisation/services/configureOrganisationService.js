(function () {

    'use strict';

    angular
        .module('app')
        .service('ConfigureOrganisationService', ConfigureOrganisationService);


    ConfigureOrganisationService.$inject = ["$http"];

    function ConfigureOrganisationService($http) {

        var configure = this;

        /**
         * 
         */
        configure.saveDetails = function (organisationDetails) {
            return $http.post(apiServer + "/configureorganisation", organisationDetails)
                .then(function (data) {}, function() {});
        };


        /**
         * 
         */
        configure.validateOrganisationOptions = function (organisationDetails) {


            var checkLogoDisplayName = configure.displayNameOrLogo(organisationDetails);

            if (checkLogoDisplayName === false) {
                return false;
            }


            if (organisationDetails.showLogo === undefined) {
                organisationDetails.showLogo = false;
            }

            if (organisationDetails.showBorder === undefined) {
                organisationDetails.showBorder = false;
            }

            if (organisationDetails.showDisplayName === undefined) {
                organisationDetails.showDisplayName = false;
            }

            if (organisationDetails.alignDisplayName === undefined) {
                organisationDetails.alignDisplayName = "left";
            }


            if (organisationDetails.alignLogo === undefined) {
                organisationDetails.alignLogo = "right";
            }

            if (organisationDetails.backgroundColor === undefined) {
                organisationDetails.backgroundColor = null;
            }

            if (organisationDetails.fontColor === undefined) {
                organisationDetails.fontColor = "#000000";
            }

            if (organisationDetails.borderColor === undefined) {
                organisationDetails.borderColor = null;
            }

            if (organisationDetails.fontName === undefined) {
                organisationDetails.fontName = 1;
            }

            return organisationDetails;


        };

        /**
         * 
         */
        configure.displayNameOrLogo = function (organisationDetails) {

            var errors = [];

            if (organisationDetails.companyImage === undefined) {
                errors.push("company_image");
            }

            if (organisationDetails.companyName === undefined) {
                errors.push("display_name");
            }

            if (errors.length === 2) {
                return false;
            }

            return true;

        };

    }



})();