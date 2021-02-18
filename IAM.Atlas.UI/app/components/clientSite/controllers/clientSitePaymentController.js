(function () {
    'use strict';

    angular
        .module('app')
        .controller('clientSitePaymentCtrl', ['$scope', '$location', '$window', 'activeUserProfile', 'OrganisationContactService', clientSitePaymentCtrl]);

    function clientSitePaymentCtrl($scope, $location, $window, activeUserProfile, OrganisationContactService) {

        $scope.organisationContact = {};

        OrganisationContactService.getOrganisationContacts(activeUserProfile.OrganisationIds[0].Id)
            .then(
                function successCallback(response) {
                    if (response.data.length > 0) {
                        $scope.organisationContact = response.data[0];
                    }
                },
                function errorCallback(response) {

                }
            );
    }
})();