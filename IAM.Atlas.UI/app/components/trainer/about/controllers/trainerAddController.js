(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('trainerAddCtrl', trainerAddCtrl);

    trainerAddCtrl.$inject = ["$scope", "TrainerProfileService", "TrainerProfileFactory", "CraftyClicksFactory", "CraftyClicksService", "ModalService", "activeUserProfile"];


    function trainerAddCtrl($scope, TrainerProfileService, TrainerProfileFactory, CraftyClicksFactory, CraftyClicksService, ModalService, activeUserProfile) {



        $scope.displayNameChanged = false;

        $scope.trainerTitles = {};
        $scope.selectedTitle = '';

        /**
         * Get the trainer Id
         * From the active user profile
         */
        $scope.trainerId = 1;
        $scope.userId = 1;
        if ($scope.selectedTrainer != null) {
            $scope.trainerId = $scope.selectedTrainer;
        }

        /**
         * Instantiate the trainer
         */
        $scope.trainer = {};

        /**
         * Check to see if a parent Trainer Id exists!
         */
        if ($scope.$parent.trainerId !== undefined) {
            $scope.trainerId = $scope.$parent.trainerId;
            $scope.trainerDisplayName = $scope.$parent.name;
        }


        $scope.selectedOrganisationId = $scope.selectedOrganisation;

        $scope.selected;

        $scope.selectedUser;

        $scope.searchContent;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        /**
         * Instantiate the phone types
         */
        $scope.phoneTypes = {};

        /**
         * Instantiate the datepicker showHide object
         */
        $scope.datePickerReveal = {};

        /**
         * Instantiate the transformed address list
         */
        $scope.TransformedAddressList = [];

        /**
         * Get the licence types from the DB
         */

        $scope.modalService = ModalService;

        $scope.trainerProfileService = TrainerProfileService;

        /**
         * Get the trainer titles
         */
        $scope.getTrainerTitles = function () {
            $scope.trainerProfileService.getTrainerTitles()
                    .then(
                        function (response) {
                            $scope.trainerTitles = response.data;
                        },
                        function (response) {
                        }
                    );
        }

        /**
         * Get the trainer notes from the DB
         */

        $scope.getNotes = function () {
            $scope.trainerProfileService.getTrainerNotes($scope.trainerId, $scope.userId)
                .then(function (response) {

                    /**
                     * Set the notes property on the scope
                     */
                    $scope.notes = response;
                    $scope.trainerNotes = $scope.noteText();


                }, function() {
                    $scope.notes = [];
                });
        }
        $scope.noteText = function () {
            var text = '';
            for (var i = 0; i < $scope.notes.length; i++) {
                var currentNote = $scope.notes[i];
                text = text + '\n' + currentNote.Date + ':-' + currentNote.Type + '(' + currentNote.User + '):' + '\n' + currentNote.Text + '\n......'
            };
            return text;
        }


        /**
         * Format the date picker date
         */
        $scope.formatDate = function (date) {
            function pad(n) {
                return n < 10 ? '0' + n : n;
            }

            return date &&
                pad(date.getDate())
                + '/' + pad(date.getMonth() + 1)
                + '/' + date.getFullYear();
        };



        $scope.displayName = function (selectedTitle) {
            if (!$scope.displayNameChanged) {

                $scope.selectedTitle = selectedTitle;

                if ($scope.selectedTitle == undefined) {
                    $scope.selectedTitle = '';
                }
                if ($scope.trainer.FirstName == undefined) {
                    $scope.trainer.FirstName = '';
                }
                if ($scope.trainer.Surname == undefined) {
                    $scope.trainer.Surname = '';
                }

                if ($scope.selectedTitle == 'Other') {
                    if ($scope.trainer.otherTitle == undefined) {
                        $scope.trainer.otherTitle = '';
                    }
                    if ($scope.trainer.otherTitle != '') {
                        $scope.trainer.DisplayName = $scope.trainer.otherTitle + " " + $scope.trainer.FirstName + " " + $scope.trainer.Surname;
                    } else {
                        $scope.trainer.DisplayName = $scope.trainer.FirstName + " " + $scope.trainer.Surname;
                    }
                }
                else {
                    if ($scope.selectedTitle != '') {
                        $scope.trainer.DisplayName = $scope.selectedTitle + " " + $scope.trainer.FirstName + " " + $scope.trainer.Surname;
                    } else {
                        $scope.trainer.DisplayName = $scope.trainer.FirstName + " " + $scope.trainer.Surname;
                    }
                }
            }
        }
       

        /**
         * Get the search content ffrom the Web API
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
                organisationId: $scope.selectedOrganisationId,
                content: $scope.searchContent
            };

            /**
             * Return the related content
             */

            return $scope.trainerProfileService.getOrganisationUsersContent($scope.selectedOrganisationId, $scope.searchContent);
        };

        $scope.selectedItem = function (item) {
            /**
            
            */
            $scope.trainerProfileService.isUserAssignedToTrainer(item.Id)
                .then(function (data) {
                    if (data == true) {
                        $scope.successMessage = "This User is already bound to a Trainer's Details";
                        $('#userText').val('');
                    }
                    else {
                        $scope.successMessage = "";
                        $('#trainerTitle').focus();

                        //Make the Display Name the same as the Login Id
                        $scope.trainer.DisplayName = item.LoginId

                        //Filter out any titles and assign the first word as the first name and last as surname
                        var loginText = item.LoginId;
                        loginText = loginText.replace(/(Mr |Dr |Rev |Mrs |Ms |Miss )/gi, '');
                        var loginTextValues = loginText.split(" ");
                        $scope.trainer.FirstName = loginTextValues[0];
                        $scope.trainer.Surname = loginTextValues[loginTextValues.length - 1]
                        $scope.trainer.UserId = item.Id;
                    }
                }, function() {
                });


            $scope.selectedUser = item;
        }

        $scope.bindToUser = function () {
            $scope.trainerProfileService.bindTrainerUser($scope.selectedUser.Id, $scope.trainerId)
                .then(function (response) {
                    $scope.trainer.UserName = $scope.selectedUser.LoginId;
                    $scope.trainer.UserId = $scope.selectedUser.Id;
                }, function() {
                });

        }
        
        /**
         * Save the data
         * To send back to the web api
         */
        $scope.save = function () {

            // if the title is other, set the title to the contents of the 'other' text
            if ($scope.selectedTitle == 'Other') {
                if (angular.isDefined($scope.trainer.otherTitle)) {
                    $scope.trainer.Title = $scope.trainer.otherTitle;
                }
                else {
                    $scope.trainer.Title = $scope.selectedTitle;
                }
            }
            else {
                $scope.trainer.Title = $scope.selectedTitle;
            }


            /**
             * Send the request to the web api
             */




            $scope.trainer.OrganisationId = $scope.selectedOrganisation;
            $scope.trainerProfileService.saveTrainerDetails($scope.trainer)
                .then(function (data) {
                    if ($.isNumeric(data)) {

                        $scope.showSuccessFader = true;

                        //Trigger search page update and forward user to trainer details page
                        $scope.$parent.refreshTrainers();

                        //Open the trainer edit modal, passing in the trainer id
                        $scope.trainerId = data;
                        $scope.isModal = true;
                        $scope.modalService.displayModal({
                            scope: $scope,
                            title: "Trainer Details",
                            cssClass: "trainerEditModal",
                            filePath: "/app/components/trainer/about/view.html",
                            controllerName: "TrainerAboutCtrl"
                        });

                        $scope.modalService.closeCurrentModal('addTrainer');
                    }
                    else {
                       

                        $scope.successMessage = data;
                        if (data == "This User is already bound to a Trainer's Details") {
                            //Clear search and set focus
                            $('#userText').val('');
                            $('#userText').focus();
                        }

                    }
                }, function(response) {
                    $scope.showErrorFader = true;
                    $scope.successMessage = "An Error Ocurred whilst saving the trainer. Please inform your support contact."
                    console.log("Error Message: " + response);
                });

        };

        $scope.getTrainerTitles();
    }

})();