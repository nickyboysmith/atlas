(function () {
    'use strict';

    angular
        .module('app')
        .service('OrganisationListService', OrganisationListService);

    OrganisationListService.$inject = ["$http"];

    function OrganisationListService($http) {

        this.getOrganisations = function () {
            return $http.get(apiServer + '/organisation')
                .then(this.returnOrganisations)
                .catch(this.logError);  
        };
        
        this.returnOrganisations = function (response) {
            return response.data;
        };

        this.logError = function (error) {
            console.log(error);
        };

    }

})();