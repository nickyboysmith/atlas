(function () {

    'use strict';

    angular
        .module("app")
        .service("OrganisationDisplaySortService", OrganisationDisplaySortService);

    // OrganisationDisplaySortService.$inject = [];

    function OrganisationDisplaySortService() {

        this.sortConfigurationOptions = function (organisation) {
            return this.decideOptionsToDisplay(organisation);
        }

        this.decideOptionsToDisplay = function (organisationOptionObject) {
            var options = {};

            if (organisationOptionObject["ShowLogo"] === true) {
                options["logo"] = this.logoDisplayOptions(organisationOptionObject);
            }
            if (organisationOptionObject["ShowDisplayName"] === true) {
                options["displayName"] = this.displayNameOptions(organisationOptionObject);
            }
            if (organisationOptionObject["HasBorder"] === true) {
                options["border"] = this.borderDisplayOptions(organisationOptionObject);
            }

            if (organisationOptionObject["BackgroundColour"]) {
                options["background"] = this.backgroundOptions(organisationOptionObject);
            }

            return options;
        }

        this.logoDisplayOptions = function (organisationOptionObject) {
            return {
                imageSrc: organisationOptionObject["ImageFilePath"],
                css: {
                    "float": organisationOptionObject["LogoAlignment"],
                    "width": "128px"
                }
            };
        }

        this.displayNameOptions = function (organisationOptionObject) {
            return {
                text: organisationOptionObject["DisplayName"],
                css: {
                    "float": organisationOptionObject["DisplayNameAlignment"],
                    "color": organisationOptionObject["FontColour"]
                }
            };
        }

        this.borderDisplayOptions = function (organisationOptionObject) {
            return {
                css: {
                    border: "2px solid " + organisationOptionObject["BorderColour"]
                }
            }
        };

        this.backgroundOptions = function (organisationOptionObject) {
            return {
                css: {
                    background: organisationOptionObject["BackgroundColour"],
                }
            }
        };

    }

})();