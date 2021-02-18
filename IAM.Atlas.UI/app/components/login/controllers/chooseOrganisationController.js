(function () {
    'use strict';

    angular
        .module('app.controllers')
        .controller('ChooseOrganisationCtrl', ChooseOrganisationCtrl);

    ChooseOrganisationCtrl.$inject = ['$scope'];

    function ChooseOrganisationCtrl($scope) {

        /**
         * Selected organisation
         */
        $scope.selectedOrganisation;

        /**
         * List of organisations
         */
        $scope.organisationList = $scope.$parent.response[0]["OrganisationIds"];

        /**
         * Select the org and 
         * process login
         */
        $scope.chooseOrganisation = function (theSelectedOrganisation) {

            if (theSelectedOrganisation === undefined) {
                console.log("Please select an organisation");
                return false;
            }

            $scope.$parent.selectedOrganisation = {
                Id: theSelectedOrganisation.Id
                , Name: theSelectedOrganisation.Name
            };
            $scope.$parent.processLogin();

            /**
             * Close Modal??
             */

        };


    }
})();

