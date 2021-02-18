(function () {
    'use strict';

    angular
        .module('app')
        .controller('trainerSearchCtrl', trainerSearchCtrl);

    trainerSearchCtrl.$inject = ["$scope", "$timeout", "trainerSearchService", "UserService", "activeUserProfile"];

    function trainerSearchCtrl($scope, $timeout, trainerSearchService, UserService, activeUserProfile) {

        $scope.organisations = {};
        $scope.courseTypes = {};
        $scope.courseCategories = {};
        $scope.trainers = {};
        $scope.trainer = {};

        $scope.selectedOrganisation = {};
        $scope.selectedCourseType = {};
        $scope.selectedCourseCategory = {};
        $scope.selectedTrainer = {};

        $scope.trainerService = trainerSearchService;
        $scope.userService = UserService;
        $scope.userId = activeUserProfile.UserId;
        $scope.isAdmin = false;
        $scope.showCategories = true;

        /**
         * Instantiate an empty array of objetcs
         * For the trainer collection to copy the trainer List Array
         */
        $scope.trainerCollection = [];

        //Get Organisations function
        $scope.getOrganisations = function (userID) {
            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (data) {
                    $scope.isAdmin = data;
                    if ($scope.organisations.length > 0) {
                        $scope.getCourseTypes($scope.selectedOrganisation);
                    }

                });

            }, function (data) {
                console.log("Can't get Organisations");
            });
            $scope.selectedCourseType = '0';
        }

        if (activeUserProfile.selectedOrganisation) {
            $scope.selectedOrganisation = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.selectedOrganisation = activeUserProfile.OrganisationIds[0].Id;
            }
        }

        //Get Course Types function
        $scope.getCourseTypes = function (orgID) {
            //Clear any error message
            $scope.successMessage = '';
            $scope.courseCategories.length = 0;
            $scope.trainers.length = 0;
            $scope.selectedCourseCategory.length = 0;
            //$scope.selectedCourseType.length = 0;

            // clear trainers on change to organisation
            $scope.trainerCollection = [];

            $scope.trainerService.getRelatedCourseTypes(orgID)
            .then(function (data) {
                $scope.courseTypes = data;
                $scope.selectedOrganisation = orgID;
                $scope.getCourseCategories('All');
                $scope.selectedCourseType = 'All';
            }, function (data) {
                console.log("Can't get Course Types");
            });
        }

        /**
         * Print a success message on the page
         * Takes a message and displays it on the page
         */
        $scope.printSuccessMessage = function (message) {
            $scope.successMessage = message;
        }
        
        //Get Course Categories function
        $scope.getCourseCategories = function (courseTypeID) {
            $scope.trainers.length = 0;
            //If 'All' or 'Unallocated' are selected disable the coursetype category dropdown and get
            //the instructors
            if (courseTypeID == 'All') {
                $scope.trainerService.GetTrainersByOrganisation($scope.selectedOrganisation)
                    .then(function (data) {
                        $scope.trainers = data;
                        angular.forEach($scope.trainers, function (trainer, index) {
                            $scope.trainerCollection.push(trainer);
                        });
                        $scope.showCategories = false;
                    }, function (data) {
                        console.log("Can't get Trainers");
                    });
            }

            if (courseTypeID == 'Unallocated') {
                $scope.trainerService.getUnallocatedTrainersByOrganisation($scope.selectedOrganisation)
                    .then(function (data) {
                        $scope.trainers = data;
                        angular.forEach($scope.trainers, function (trainer, index) {
                            $scope.trainerCollection.push(trainer);
                        });
                        $scope.showCategories = false;
                    }, function (data) {
                        console.log("Can't get Trainers");
                    });
            }

            if (courseTypeID > 0) {
                $scope.trainerService.getRelatedCourseCategories(courseTypeID, $scope.userId)
                    .then(function (data) {
                        $scope.courseCategories = data;
                        $scope.selectedCourseType = courseTypeID;
                        $scope.showCategories = true;
                    }, function (data) {
                        console.log("Can't get Course Categories");
                    });

                //Show all trainers to start
                $scope.trainerService.getTrainersByCoursetype(courseTypeID)
                   .then(function (data) {
                       $scope.trainers = data;
                       angular.forEach($scope.trainers, function (trainer, index) {
                           $scope.trainerCollection.push(trainer);
                       });
                   }, function (data) {
                       console.log("Can't get Trainers");
                   });
            }
        }

        //Get the trainers based on the selected Organisation, Category and Course Type
        $scope.getTrainers = function (courseCategoryID) {
            if (courseCategoryID == 'All') {
                $scope.trainerService.getTrainersByCoursetype($scope.selectedCourseType)
                   .then(function (data) {
                       $scope.trainers = data;
                   }, function (data) {
                       console.log("Can't get Trainers");
                   });
            }
            else {
                if ($scope.selectedCourseType == 'All') {
                    $scope.trainerService.GetTrainersByOrganisation($scope.selectedOrganisation)
                        .then(function (data) {
                            $scope.trainers = data;
                            $scope.showCategories = false;
                        }, function (data) {
                            console.log("Can't get Trainers");
                        });
                } else {
                    $scope.trainerService.getTrainers(
                        $scope.selectedCourseType,
                        courseCategoryID,
                        $scope.selectedOrganisation)
                            .then(function (data) {
                                $scope.trainers = data;
                                $scope.selectedCourseCategory = courseCategoryID;
                            }, function (data) {
                                console.log("Can't get Trainers");
                            });
                }
            }
        };

        $scope.refreshTrainers = function () {
            if ($scope.selectedCourseCategory != null) {
                $scope.getTrainers($scope.selectedCourseCategory);
            }
        };

        $scope.selectTrainer = function (trainerID) {
            $scope.successMessage = '';
            $scope.selectedTrainer = trainerID;
        };

        $scope.showTrainer = function (trainerID) {
            $scope.successMessage = '';
            $scope.selectedTrainer = trainerID;
            $scope.updateTrainers($scope.selectedTrainer);
        };

        $scope.createTrainer = function () {
            //Check that an organisation has been selected first
            if ($scope.selectedOrganisation > 0) {
                $scope.modalService.displayModal({
                    scope: $scope,
                    title: "Add Trainer",
                    cssClass: "addTrainer",
                    filePath: "/app/components/trainer/about/add.html",
                    controllerName: "trainerAddCtrl",
                    buttons: {
                        label: 'Close',
                        cssClass: 'closeModalButton',
                        action: function (dialogItself) {
                            dialogItself.close();
                        }
                    }
                });
            }
            else {
                $scope.successMessage = 'Select an Organisation before adding a trainer.';
            }
        };

        $scope.editTrainer = function () {

            if ($scope.selectedTrainer > 0) {
                $scope.updateTrainers($scope.selectedTrainer);
            }
            else {
                $scope.successMessage = 'Please select a trainer before editing, click "Add New" to add a new trainer.';
            }
        };

        $scope.updateTrainers = function (trainerID) {
            //Open the trainer edit modal, passing in the trainer id

            $scope.trainer = trainerID;
            $scope.isModal = true;
            $scope.modalService.displayModal({
                scope: $scope,
                title: "Trainer Details",
                cssClass: "trainerEditModal",
                filePath: "/app/components/trainer/about/view.html",
                controllerName: "TrainerAboutCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.getOrganisations($scope.userId);

        $scope.setFadeMessage = function (message, image, delay) {
            $scope.fadeMessage = message;
            $scope.fadeImage = image;
            $scope.showFadeSaveMessage = true;
            $timeout(function () { $scope.showFadeSaveMessage = false; }, delay);
        }

        $scope.addToMenuFavourite = function () {

            var menuFavourouriteParams = {
                UserId: $scope.userId,
                Title: "Trainer Search",
                Link: "app/components/trainer/search/view",
                Parameters: "trainerSearchCtrl",
                Modal: "True",

            };
            $scope.$emit('savemenufavourite', menuFavourouriteParams);
        }
    }
})();