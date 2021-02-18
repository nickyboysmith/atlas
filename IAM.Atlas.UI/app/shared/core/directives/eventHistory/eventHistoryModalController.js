(function () {

    'use strict';

    angular
        .module("app.controllers")
        .controller("EventHistoryModalCtrl", EventHistoryModalCtrl);


    EventHistoryModalCtrl.$inject = ["$scope", "$filter", "EventHistoryService", "EventHistoryFactory", "ModalService", "activeUserProfile"];


    function EventHistoryModalCtrl($scope, $filter, EventHistoryService, EventHistoryFactory, ModalService, activeUserProfile) {

        /**
         * Set the client ID variable
         */
        $scope.typeId = $scope.typeId;

        $scope.historyNotes = [];

        /**
         * List of client event types
         */
        $scope.loadClientHistoryOptions = function () {
            EventHistoryService.getClientHistoryEventTypes($scope.typeId, activeUserProfile.selectedOrganisation.Id)
                .then(function (data) {
                    $scope.historyOptions = data;
                }, function () {
                });
        }

        /**
         * List of client historys
         */
        $scope.loadClientHistory = function () {
            EventHistoryService.getClientHistory($scope.typeId, activeUserProfile.selectedOrganisation.Id)
                .then(function (data) {
                    $scope.errorMessage = "";

                    // hide the table if 0 results are returned
                    $scope.hideTable = EventHistoryFactory.hideTable(data.length);

                    //Show an error message if 0 results are returned
                    $scope.errorMessage = EventHistoryFactory.error($scope.hideTable, "empty");

                    //Set the history returned objects
                    $scope.historyNoteCollection = data;
                    $scope.historyNotes = $scope.historyNoteCollection;
                    $scope.historyNoteItems = $scope.historyNoteCollection;
                }, function () {
                    //Hide the table if 0 results are returned
                    $scope.hideTable = EventHistoryFactory.hideTable(0);

                    //Show an error message to display error
                    $scope.errorMessage = EventHistoryFactory.error(true, "error");
                });
        }

        /**
         * List of course event types
         */
        $scope.loadCourseHistoryOptions = function () {
            EventHistoryService.getCourseHistoryEventTypes($scope.typeId)
                .then(function (data) {
                    $scope.historyOptions = data;
                }, function () {
                });
        }

        /**
         * List of course historys
         */
        $scope.loadCourseHistory = function () {
            EventHistoryService.getCourseHistory($scope.typeId)
                .then(function (data) {
                    $scope.errorMessage = "";

                    // hide the table if 0 results are returned
                    $scope.hideTable = EventHistoryFactory.hideTable(data.length);

                    //Show an error message if 0 results are returned
                    $scope.errorMessage = EventHistoryFactory.error($scope.hideTable, "empty");

                    //Set the history returned objects
                    $scope.historyNoteCollection = data;
                    $scope.historyNotes = $scope.historyNoteCollection;
                    $scope.historyNoteItems = $scope.historyNoteCollection;
                }, function () {
                    //Hide the table if 0 results are returned
                    $scope.hideTable = EventHistoryFactory.hideTable(0);

                    //Show an error message to display error
                    $scope.errorMessage = EventHistoryFactory.error(true, "error");

                });
        }


        if ($scope.typeName.toLowerCase() == "client") {
            $scope.loadClientHistory();
            $scope.loadClientHistoryOptions();

        } else if ($scope.typeName.toLowerCase() == "course") {
            $scope.loadCourseHistory();
            $scope.loadCourseHistoryOptions();

        }

        /**
         * Set the not type when option chosen from the drop down
         */
        $scope.chooseNoteType = function () {

            $scope.selectedNoteType = null;
            if (!this.noteTypes == false) {
                $scope.selectedNoteType = this.noteTypes.EventType;
            }

            if ($scope.selectedNoteType) {
                $scope.historyNoteItems = $filter('filter')($scope.historyNotes, {
                    EventType: $scope.selectedNoteType
                });
                $scope.historyNoteCollection = $scope.historyNoteItems;
            }
            else {
                $scope.historyNoteItems = $scope.historyNotes;
                $scope.historyNoteCollection = $scope.historyNoteItems;
            }
        };

        $scope.removeHtml = function (s) {
            return s.replace(new RegExp('<br>', 'g'), ' ').replace(new RegExp('<p>', 'g'), ' ').replace(new RegExp('</p>', 'g'), ' ');
        }
    }

})();