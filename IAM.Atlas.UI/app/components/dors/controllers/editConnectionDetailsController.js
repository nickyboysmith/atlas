(function () {

    'use strict';

    angular
        .module("app")
        .controller("EditConnectionDetailsCtrl", EditConnectionDetailsCtrl);

    EditConnectionDetailsCtrl.$inject = ["$scope", "DorsConnectionDetailsService", "DateFactory", "ModalService", "activeUserProfile"];

    function EditConnectionDetailsCtrl($scope, DorsConnectionDetailsService, DateFactory, ModalService, activeUserProfile) {



        /**
         * Create a new connection object
         */
        $scope.connection = {};

        /**
         * Decides whether or not to add notes
         */
        $scope.hasConnection = false;

        /**
         * Set the selected org name on the scope
         */
        if ($scope.$parent.dorsSettingsOrganisation === undefined) {
            $scope.organisationName = activeUserProfile.selectedOrganisation.Name;
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        } else {
            $scope.organisationName = $scope.$parent.dorsSettingsOrganisation.Name;
            $scope.organisationId = $scope.$parent.dorsSettingsOrganisation.Id;
        }


        /**
         * List of notes
         */
        $scope.notes = [];

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        /**
         * GetDetails
         */
        DorsConnectionDetailsService.getConnectionDetails($scope.organisationId)
        .then(
            function (response) {
                if (response.length !== 0) {
                    $scope.connection = response[0];
                    $scope.connection.LastChanged = $scope.convertTheDate($scope.connection.LastChanged);
                    $scope.hasConnection = true;
                    $scope.getConnectionNotes();
                }
            },
            function (response) {
                console.log(response);
            }
        );

        /**
         * 
         */
        $scope.revealButtonText = "show";


        /**
         * Change the input on a keypress
         */
        $scope.changeInputWhenTyping = function (event) {

            /**
             * If the "changeBackToPassword" variable
             * Is an integer clear the timeout
             */
            if ($scope.changeBackToPassword !== undefined) {
                clearTimeout($scope.changeBackToPassword);
            }

            /**
             * Change the password input to a text input
             */
            $(event.target).prop("type", "text");

            /**
             * Change back
             */
            $scope.changeBackToPassword = setTimeout(function () {
                $(event.target).prop("type", "password");
                $scope.changeBackToPassword = undefined;
            }, 800);

        };

        /**
         * Change the password input type
         */
        $scope.revealPassword = function () {

            /**
             * Show the password in plain text
             */
            if ($scope.revealButtonText === "show") {
                $("#passwordReveal").prop("type", "text");
                $scope.revealButtonText = "hide"
                return false;
            }

            /**
             * Mask the password
             */
            if ($scope.revealButtonText === "hide") {
                $("#passwordReveal").prop("type", "password");
                $scope.revealButtonText = "show"
                return false;
            }
        };

        /**
         * Save the connection details on click
         */
        $scope.saveConnectionDetails = function () {
            
            console.log("Check the connection details arent empty before we submit");

            /**
             * Change the boolen to an integer
             */
            var enabledConnection = +$scope.connection.Enabled;
            
            $scope.connection.Enabled = enabledConnection;
            $scope.connection.OrganisationId = $scope.organisationId;
            $scope.connection.UserId = activeUserProfile.UserId;
            DorsConnectionDetailsService.saveConnectionDetails($scope.connection)
                .then(
                    function (response) {
                        $scope.showSuccessFader = true;
                        if ($scope.$parent.dorsSettingsOrganisation !== undefined) {
                            $scope.$parent.getOrganisations();
                        }
                        console.log("This is a success response");
                        console.log(response);
                    },
                    function (response) {
                        $scope.showErrorFader = true;
                        console.log("This is an error");
                        console.log(response);
                    }
                );
        };

        /**
         * Get the connection notes
         */
        $scope.getConnectionNotes = function () {

            DorsConnectionDetailsService.getNotes($scope.organisationId)
                .then(
                    function (response) {
                        if (response.length !== 0) {
                            $scope.notes = response;
                        }
                    },
                    function (response) {
                        console.log(response);
                    }
                );
        };


        /**
         * Convert the date fromm the web api timestamp
         * To a readable usable date
         */
        $scope.convertTheDate = function (date) {
            return DateFactory.convertWebApiDate(date, "/");
        };

        /**
         * Open the notes modal
         */
        $scope.openAddNoteModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add DORS Connection Note",
                closable: true,
                filePath: "/app/components/dors/addDORSConnectionNote.html",
                controllerName: "AddDORSConnectionNoteCtrl",
                cssClass: "addDORSConnectionNoteModal",
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
         * Save the note from the child modal
         */
        $scope.saveTheConnectionNote = function (noteDetails) {

            var noteObject = {
                NoteTypeId: noteDetails.Id,
                Text: noteDetails.content,
                OrganisationId: $scope.organisationId,
                UserId: activeUserProfile.UserId
            };



            console.log(noteObject);

        };

    }

})();