(function () {

    'use strict';

    angular
        .module("app")
        .controller("FindSingleClientCtrl", FindSingleClientCtrl);

    FindSingleClientCtrl.$inject = ["$scope", "activeUserProfile", "QuickSearchService", "ClientService", "ModalService", "RecordPaymentFactory", "DateFactory"];

    function FindSingleClientCtrl($scope, activeUserProfile, QuickSearchService, ClientService, ModalService, RecordPaymentFactory, DateFactory)
    {


        /**
         * Instaniate the client property on the scope
         */
        $scope.selectedClient;

        /**
         * Create selected course object 
         * Assign all course selected from checkbox
         * to the client array
         */
        $scope.selectedCourses = {
            client: []
        };

        /**
         * Call the web api to get results based on the search content
         */
        $scope.getSearchableItems = function (searchContent) {
            /**
             * Set the search content
             * To a property on the scope
             */
            $scope.searchContent = searchContent;

            /**
             * Create search options object
             */
            var searchOptions = {
                organisationId: activeUserProfile.selectedOrganisation.Id,
                content: $scope.searchContent,
                searchType: "client"
            };

            /**
             * Return the related content
             */
            return QuickSearchService.getSearchableContent(searchOptions);
        }

        /**
         * When the user selects a name 
         * From the list
         */
        $scope.selectedItem = function (client) {
            $scope.selectedClient = client;
            $scope.getClientDetails($scope.selectedClient.ClientId);
        };

        /**
         * Load the client details
         */
        $scope.getClientDetails = function (clientId) {
            ClientService.get(clientId)
            .then(
                function (response) {

                    /**
                     * Assign Client Details to the scope
                     */
                    $scope.clientDetails = response.data;

                    /**
                     * Assign the client address to
                     * A property on the scope 
                     */
                    $scope.clientAddress = $scope.clientDetails.ClientLocations[0].Location;

                    /**
                     * Get all courses that 
                     * Are related to he selected client
                     */
                    $scope.getRelatedCourse(clientId, activeUserProfile.selectedOrganisation.Id);
                    $("#additionalClientContainer").hide();
                    $("#additionalClientContainer").show();
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        /**
         * Convert a date to a readable string
         */
        $scope.convertDateForDisplay = function (date) {
            return DateFactory.convertWebApiDate(date, "/");
        };

        /**
         * Get the related courses for a client
         */
        $scope.getRelatedCourse = function (clientId, organisationId) {
            ClientService.getCourses(clientId, organisationId)
            .then(
                function (response) {
                    $scope.relatedCourses = response.data;

                    /**
                     * If there are courses related to the client.
                     * Then show the courses 
                     */
                    if ($scope.relatedCourses.length > 0) {
                        $("#coursesAvailableContainer").show();
                    }

                    /**
                     * Go off to the 'RecordPaymentFactory'
                     * To calculate the total outstanding amount
                     */
                    $scope.totalPaymentAmount = RecordPaymentFactory.getOutstandingAmount($scope.relatedCourses);
                },
                function (reason) {
                    console.log(reason);
                }
            );
        };

        /**
         * Assign the client
         * Create new object 
         * Then send to parent modal
         */
        $scope.assignClientToPayment = function () {
            /**
             * Merge the display Name
             */
            var mergedCourses = RecordPaymentFactory.mergeName(
                $scope.selectedCourses["client"]
            );

            /**
             * Create the data to send to the parent
             */
            var clientSelectedData = {
                clientId: $scope.clientDetails.Id,
                clientName: $scope.clientDetails.DisplayName,
                courseName: mergedCourses,
                courses: $scope.selectedCourses["client"],
                postCode: $scope.clientDetails.ClientLocations[0].Location.PostCode
            };

            /**
             * Send to the parent
             */
            $scope.$parent.updateAssignedClient(clientSelectedData);

            /**
             * Close the assign client modal
             */
            ModalService.closeCurrentModal("recordPaymentAssignClientModal");
        };

    };

})();