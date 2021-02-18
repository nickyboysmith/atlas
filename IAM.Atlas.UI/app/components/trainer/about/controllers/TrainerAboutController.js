(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('TrainerAboutCtrl', TrainerAboutCtrl);

    TrainerAboutCtrl.$inject = ["$scope", "$filter", "TrainerProfileService", "TrainerProfileFactory", "TrainerVehicleService", "GetAddressFactory", "GetAddressService", "ModalService", "DateFactory", "EmailService", "activeUserProfile"];


    function TrainerAboutCtrl($scope, $filter, TrainerProfileService, TrainerProfileFactory, TrainerVehicleService, GetAddressFactory, GetAddressService, ModalService, DateFactory, EmailService, activeUserProfile) {


        $scope.displayCalendar = false;
        $scope.displayPhotoCalendar = false;

        $scope.trainerTitles = {};
        $scope.selectedTitle = '';

        /**
         * Get the trainer Id
         * From the active user profile
         */
        if ($scope.trainerId == undefined) {
            $scope.trainerId = activeUserProfile.TrainerId;
            if ($scope.selectedTrainer != null) {
                $scope.trainerId = $scope.selectedTrainer;
            }
            /**
             * Check to see if a parent Trainer Id exists!
             */
            if ($scope.$parent.trainerId !== undefined) {
                $scope.trainerId = $scope.$parent.trainerId;
                $scope.trainerDisplayName = $scope.$parent.name;
                /**
                 * Instatiate the  hideUploadContainer flag on the scope
                 */
                $scope.hideUploadContainer = true;

            }
        }

        $scope.userId = activeUserProfile.UserId;
        $scope.hoveringDocumentId = 0;

        /**
         * Instantiate the trainer
         */
        $scope.trainer = {};


        if (angular.isDefined($scope.selectedOrganisation)) {
            $scope.selectedOrganisationId = $scope.selectedOrganisation;
        }
        else {
            $scope.selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
        }

        $scope.selected;

        $scope.selectedUser;

        $scope.searchContent;

        $scope.showSuccessFader = false;
        $scope.showErrorFader = false;

        $scope.errorMessage = "";
        $scope.successMessage = "";

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

        $scope.trainerProfileService.getDriverLicenceTypes()
            .then(function (response) {

                /**
                 * Set the licenceTypes property on the scope
                 */
                $scope.licenceTypes = response;

            }, function () {
                $scope.licenceTypes = [];
            });

        /**
         * Get the phone types from the DB
         */
        $scope.trainerProfileService.getPhoneTypes()
             .then(function (response) {

                 /**
                  * Set the phoneTypes property on the scope
                  */
                 $scope.phoneTypes = response;

             }, function () {
                 $scope.phoneTypes = [];
             });


        /**
         * Get the trainer profile details
         */
        $scope.trainerProfileService.getTrainerDetails($scope.trainerId)
            .then(function (response) {
                /**
                 * Transform the response from the web api
                 * Set the trainer property on the scope
                 */
                $scope.trainer = TrainerProfileFactory.transform(response);

                /**
                 * Check to see if profile picture is empty
                 * if it is add ludo man in empty box
                 */
                $scope.checkProfilePicture($scope.trainer.ProfilePicture);

                /**
                 * If coming from the add User 
                 * and we're pulling the name from the parent scope
                 * set the display name after we've got the trainer details
                 */
                if ($scope.trainerDisplayName !== undefined) {
                    $scope.trainer.DisplayName = $scope.trainerDisplayName;
                }

                if ($scope.trainer.Title !== undefined) {

                    if ($scope.isKnownTitle($scope.trainer.Title)) {
                        $scope.selectedTitle = $scope.trainer.Title;
                    }
                    else {

                        $scope.selectedTitle = 'Other';
                        $scope.trainer.otherTitle = $scope.trainer.Title;
                    }
                }

                /**
                 * Transform the date into a format 
                 * dd-mmm/yyyy
                 */
                if ($scope.trainer.Licence !== undefined) {

                    $scope.trainer.Licence.ExpiryDate = $filter('date')($scope.trainer.Licence.ExpiryDate, 'dd-MMM-yyyy');
                    $scope.trainer.Licence.PhotocardExpiryDate = $filter('date')($scope.trainer.Licence.PhotocardExpiryDate, 'dd-MMM-yyyy');

                }


                //Assign the email address to the confirmation email address
                if ($scope.trainer.Email) {
                    $scope.trainer.Email.ConfirmAddress = $scope.trainer.Email.Address;
                }
            }, function () {
                $scope.trainer = {}
            });


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
         * Decide what to do with profile picture
         */
        $scope.checkProfilePicture = function (pictureName) {
            var imageLink = "";
            if (pictureName === null) {
                imageLink = "/app_assets/images/x-profile-picture-large.png";
            } else {
                imageLink = apiServerImagePath + "/" + pictureName;
            }
            $("#previewProfilePicture").attr('src', imageLink).show();
        };

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

        $scope.getTrainerTitles();


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


                }, function () {
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

        $scope.getNotes();

        // get the trainer's documents
        $scope.getDocuments = function () {
            return $scope.trainerProfileService.getTrainerDocuments($scope.trainerId, $scope.userId)
                    .then(
                        function successCallback(response) {
                            $scope.trainerDocuments = response.data;
                            $scope.trainerDocuments = $filter('filter')(response.data, { MarkedForDeletion: false });;
                        },
                        function errorCallback(response) { }
                    );
        }

        //Get Vehicle Trainer Details
        $scope.getTrainerVehicleDetailsByOrganisation = function () {

            $scope.selectedTrainerVehicle = {
                selectedOrganisationId: $scope.selectedOrganisationId,
                selectedTrainerId: $scope.trainerId,
                selectedVehicleTypeId: null,
                selectedVehicleCategoryId: null,
            };

            $scope.trainerVehicleDetails = {};

            TrainerVehicleService.getTrainerVehicleDetailsByOrganisation($scope.selectedTrainerVehicle)
            .then(
                function (response) {

                    $scope.trainerVehicleDetails = response.data;

                    if ($scope.trainerVehicleDetails.length > 0) {

                        $scope.aboutTrainerVehicleDetail = $scope.trainerVehicleDetails[0];
                        $scope.selectedTrainerVehicleDetailId = $scope.trainerVehicleDetails[0].TrainerVehicleId;

                    }
                    else {
                        $scope.aboutTrainerVehicleDetail = {};
                    }

                },
                function (response) {

                }
            );

        }

        $scope.getTrainerVehicleDetailsByOrganisation();

        $scope.isTrainerVehicleSelected = function () {

            if (angular.isDefined($scope.aboutTrainerVehicleDetail)) {

                if (angular.equals({}, $scope.aboutTrainerVehicleDetail)) {
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }

        }


        $scope.getDocuments();

        $scope.addDocument = function () {

            $scope.errorMessage = "";
            $scope.successMessage = "";

            ModalService.displayModal({
                scope: $scope,
                title: "Upload New Trainer Document",
                cssClass: "addTrainerDocumentModal",
                filePath: "/app/components/trainer/about/addDocument.html",
                controllerName: "addTrainerDocumentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        /**
         * Format the date picker date
         */
        //$scope.formatDate = function (date) {
        //    function pad(n) {
        //        return n < 10 ? '0' + n : n;
        //    }

        //    return date &&
        //        pad(date.getDate())
        //        + '/' + pad(date.getMonth() + 1)
        //        + '/' + date.getFullYear();
        //};

        /**
         * Get the search content from the Web API
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
            $scope.selectedUser = item;
        }

        $scope.bindToUser = function () {
            $scope.trainerProfileService.bindTrainerUser($scope.selectedUser.Id, $scope.trainerId)
                .then(function (response) {
                    $scope.trainer.UserName = $scope.selectedUser.LoginId;
                }, function () {
                });
        }

        /**
         * Display an image preview
         * @todo resize image for upload
         * http://stackoverflow.com/questions/10333971/html5-pre-resize-images-before-uploading
         */
        $scope.showImagePreview = function () {

            var selector = $("#trainerUpload");

            if (event.target.files && event.target.files[0]) {

                var reader = new FileReader();
                reader.onload = function (e) {

                    /**
                     * Add a message to the user.
                     */
                    $scope.message = "PLEASE NOTE: Your new profile picture is not saved automatically. You will need to press the 'Save Details' button to save the new image!";

                    /**
                     * Show the image only if a new image has been uploaded
                     */
                    $("#previewProfilePicture").show();

                    /**
                     * Show the image preview
                     */
                    $("#previewProfilePicture").attr('src', e.target.result);


                    $scope.tempImage = e.target.result.split(",");
                    console.log($scope.tempImage);

                    $scope.trainer.pictureToUpload = $scope.tempImage[1];

                    /**
                     * Remove message after 5000ms
                     */
                    setTimeout(function () {
                        $scope.trainer.ProfilePicture = "";
                        $scope.message = "";
                    }, 5000);

                }
                reader.readAsDataURL(event.target.files[0]);
            }
        };

        /**
         * Show the relevant date picker
         * Hide it if it's already shown
         */
        //$scope.showDatePicker = function (type) {
        //    if ($scope.datePickerReveal[type]) {
        //        $scope.datePickerReveal[type] = false;
        //        return false;
        //    }
        //    $scope.datePickerReveal[type] = true;
        //}

        $scope.toggleCalendar = function () {
            $scope.displayCalendar = !$scope.displayCalendar;
        }

        $scope.togglePhotoCalendar = function () {
            $scope.displayPhotoCalendar = !$scope.displayPhotoCalendar;
        }

        $scope.formatDate = function (date) {
            return $filter('date')(date, 'dd-MMM-yyyy');
        }

        /**
         * Add new phone number into div
         * @todo re-factor into a directive
         */
        $scope.addNewPhoneNumber = function () {

            var html = '<div class="row trainer-field-holder-row the-phone-number-container">';
            html += '   <div class="col-xs-12 col-sm-3">';
            html += '       <label>Phone:</label>';
            html += '   </div>';
            html += '   <div class="col-xs-6 col-sm-3">';
            html += '       <select  class="getPhoneType"> ';

            angular.forEach($scope.phoneTypes, function (type, index) {
                html += '   <option value="' + type.Id + '">' + type.Type + '</option>';
            });

            html += '       </select>';
            html += '   </div>';
            html += '   <div class="col-xs-6 col-sm-5">';
            html += '       <input type="text" class="getPhoneNumber" value=""/>';
            html += '   </div>';
            html += '</div>';

            $("#addedPhoneNumbers").append(html);
        }


        /**
         * Get the address choices
         */
        $scope.getAddressChoices = function () {

            GetAddressService.getAddress($scope.trainer.Address.Postcode)
                .then(function (response) {

                    /**
                     * Set the address list
                     */
                    //$scope.AddressList = response;
                    $scope.TransformedAddressList = response.Addresses;
                    /**
                     * Transform the Address List
                     */
                    //$scope.TransformedAddressList = GetAddressFactory.transform(response.Addresses);

                }, function (response) {
                    alert("There was an issue retrieving your address");
                });
        }

        /**
         * Merge the address to enter in to the text field
         */
        $scope.selectAddress = function (theSelectedAddress) {

            if (theSelectedAddress) {
                $scope.trainer.Address.Address = GetAddressFactory.format(theSelectedAddress);
            }
            /**
             * Empty the transformed Address List
             */
            $scope.TransformedAddressList = [];
        }

        /**
        * Method to open the add trainer note modal
        */
        $scope.addTrainerNoteModal = function () {

            $scope.errorMessage = "";
            $scope.successMessage = "";

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Add trainer note",
                cssClass: "courseNoteModal",
                filePath: "/app/components/trainer/about/addNote.html",
                controllerName: "addTrainerNoteCtrl"
            });
        };

        $scope.selectDocument = function (document) {
            $scope.selectedDocument = document;
        };



        $scope.setSelectedTrainerVehicleDetails = function (trainerVehicleDetails) {

            $scope.selectedTrainerVehicleDetailId = trainerVehicleDetails.TrainerVehicleId;
        }

        $scope.selectTrainerVehicle = function (trainerVehicle) {

            $scope.aboutTrainerVehicleDetail = trainerVehicle;
            $scope.openTrainerVehicleDetailModal();

        };




        /**
        * Open the Trainer Vehicle Detail Modal
        */
        $scope.openTrainerVehicleDetailModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Trainer Vehicle Detail",
                closable: true,
                filePath: "/app/components/TrainerVehicle/detail.html",
                controllerName: "TrainerVehicleDetailCtrl",
                cssClass: "TrainerVehicleDetailModal",
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
        * Open the Add Trainer Vehicle Modal
        */
        $scope.openAddTrainerVehicleModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Add New/Additional Trainer Vehicle",
                closable: true,
                filePath: "/app/components/TrainerVehicle/add.html",
                controllerName: "AddTrainerVehicleCtrl",
                cssClass: "AddTrainerVehicleModal",
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
        * Open the Edit Trainer Vehicle Modal
        */
        $scope.openEditTrainerVehicleModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Edit Trainer Vehicle",
                closable: true,
                filePath: "/app/components/TrainerVehicle/edit.html",
                controllerName: "EditTrainerVehicleCtrl",
                cssClass: "EditTrainerVehicleModal",
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
         * Download an existing document
         */
        $scope.openDownloadDocumentModal = function () {

            $scope.errorMessage = "";
            $scope.successMessage = "";

            $scope.downloadDocumentObject = {};
            $scope.downloadDocumentObject.Id = $scope.selectedDocument.Id;
            $scope.downloadDocumentObject.typeLabel = "Trainer";
            $scope.downloadDocumentObject.typeDescription = $scope.trainer.DisplayName + " (Id: " + $scope.trainerId + ")";
            $scope.downloadDocumentObject.typeName = $scope.selectedDocument.Type != null ? $scope.selectedDocument.Type : '';
            $scope.downloadDocumentObject.documentSaveName = $scope.selectedDocument.Title;
            $scope.downloadDocumentObject.owningEntityId = $scope.trainerId;
            $scope.downloadDocumentObject.owningEntityPath = "trainer";

            $scope.modalService.displayModal({

                scope: $scope,
                title: "Download Trainer Document",
                cssClass: "downloadDocumentModal",
                filePath: "/app/components/documents/download.html",
                controllerName: "DocumentDownloadCtrl"
            });

        };

        /**
        * Is the title a pre-defined one or it's 'Other'
        */
        $scope.isKnownTitle = function (trainerTitle) {

            var KnownTitle = false;

            angular.forEach($scope.trainerTitles, function (value, key) {

                if (value.StringId == trainerTitle) {
                    KnownTitle = true;
                }

            });

            return KnownTitle;
        };

        // is the form valid? 
        $scope.validForm = function () {
            var valid = false;
            var message = "";
            if ($scope.trainer && $scope.trainer.Email && $scope.trainer.Email.Address) {
                if ($scope.trainer.Email.Address != "") {
                    if (EmailService.validate($scope.trainer.Email.Address)) {
                        valid = true;
                    }
                    else {
                        $scope.errorMessage = "Email address is not in a recognised format.";
                        valid = false;
                        return valid;
                    }
                }
            }
            if ($scope.trainer.Address && valid == true) {
                if ($scope.trainer.Address.Address) {
                    if ($scope.trainer.Address.Address.length == 0) {
                        $scope.errorMessage = "Please enter an address.";
                        valid = false;
                        return valid;
                    }
                    else{
                        valid = true;
                    }
                }
                else {
                    $scope.errorMessage = "Please enter an address.";
                    valid = false;
                    return valid;
                }
            }
            else {
                $scope.errorMessage = "Please enter an address.";
                valid = false;
                return valid;
            }
            if ($scope.trainer.Licence && valid == true) {
                if ($scope.trainer.Licence.Type == undefined || $scope.trainer.Licence.Type == null) {
                    $scope.errorMessage = "Please provide a driving licence type before proceeding.";
                    valid = false;
                    return valid;
                }
                else {
                    valid = true;
                }
            }
            else {
                $scope.errorMessage = "Please provide a driving licence type before proceeding.";
                valid = false;
            }
            return valid;
        }




            /**
             * Save the data
             * To send back to the web api
             */
        $scope.save = function () {
            if ($scope.validForm()) {
                $scope.errorMessage = "";
                $scope.successMessage = "";

                var phoneTypes = $(".getPhoneType:visible");
                var phoneNumbers = $(".getPhoneNumber:visible");

            /**
             * Empty any added phone number divs
             */
                $("#addedPhoneNumbers").empty();

            /**
             * Add the Id to the trainer object
             * In future it'll come from the active profile object 
             * so we can be inject it in the service
             */
                $scope.trainer.Id = $scope.trainerId;

            /**
             * Transform phone numbers to send back to the web api
             */
                $scope.trainer.PhoneNumbers = TrainerProfileFactory.create(phoneTypes, phoneNumbers);

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

                $scope.trainer.UserId = activeUserProfile.UserId;

            /**
             * Send the request to the web api
             */
                $scope.trainerProfileService.saveTrainerDetails($scope.trainer)
                    .then(function (response) {

                        if (response === "success") {

                            $scope.showSuccessFader = true;

                            /**
                             * If successful
                             */
                            if ($scope.$parent.closeTheActiveModal !== undefined) {
                                $scope.$parent.printSuccessMessage("Updated " +$scope.trainer.DisplayName + "'s Trainer details.");
                                $scope.$parent.cancelAddUser($scope.$parent.closeTheActiveModal);
                        }

                            /**
                             * On success of the save
                             */
                            if ($scope.trainer.pictureToUpload) {
                                $scope.trainer.ProfilePicture = "";
                                $(".trainer-profile-picture img").prop("src", $scope.tempImage);
                                $("#previewProfilePicture").prop("src", "");
                                $("#previewProfilePicture").hide();
                        }

                            if ($scope.isModal == true) {
                                $scope.$parent.refreshTrainers();
                                $scope.$parent.printSuccessMessage("Updated " +$scope.trainer.DisplayName + "'s Trainer details.");
                                $scope.successMessage = "Updated " +$scope.trainer.DisplayName + "'s Trainer details.";
                        }
                    }

                        if (response !== "success") {

                            $scope.showErrorFader = true;
                            $scope.errorMessage = response;
                            console.log("Error Message: " +response);
                    }

                        $scope.successMessage = "Updated " +$scope.trainer.DisplayName + "'s Trainer details.";

                }, function (response) {

                        $scope.showErrorFader = true;
                        $scope.errorMessage = response;
                        console.log("Error Message: " +response);
        });
        }
            };
    }

})();