(function () {

    'use strict';

    angular
        .module("app")
        .factory("OrganisationDisplayFactory", OrganisationDisplayFactory);

    OrganisationDisplayFactory.$inject = ["$http"];

    function OrganisationDisplayFactory() {

        return {
            sortConfigurationOptions: sortConfigurationOptions
        };

    }

})();