(function () {

    angular
        .module("app")
        .controller("QuickSearchCtrl", QuickSearchCtrl);

    QuickSearchCtrl.$inject = ["$scope", "ModalService", "QuickSearchService", "UserService", "activeUserProfile"];

    function QuickSearchCtrl($scope, ModalService, QuickSearchService, UserService, activeUserProfile) {


        /**
         * The logged in user Id
         *
         */
        $scope.userId = activeUserProfile.UserId;

        /**
         * Get the organisation Id
         * From the active user profile
         */
        if(activeUserProfile.selectedOrganisation){
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        }
        else {
            $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;
        }
        

        /**
         * Instantiate the variable to 
         * display the client search
         */
        $scope.showSearch = false;

        /**
         * Instantiate the variable to 
         * display the blocked users
         */
        $scope.showingBlockedUsers = false;

        $scope.blockedUsers = {};
        $scope.selectedBlockedUserId = -1;
        $scope.userService = UserService;

        /**
         * Instatiate the search type property
         * On the scope
         */
        $scope.theSearchType;

        /**
         * Default to not show the checkbox
         */
        $scope.showCheckBox = false;


        /**
         * Instantiate the futureDates property
         * Default to false
         */
        $scope.showFutureDates = false;

        /**
         * Property on the scope that will hold the 
         * Selected Object
         */
        $scope.selected;

        /**
         * Show and hide the quick search based upon
         * a boolean value on the showClientSearch
         */
        $scope.showQuickSearchBox = function ($event, searchText, searchType) {

            /**
             * Check to see if the same icon is being clicked
             * If it's a different icon, hide the container
             */
            if ($scope.theSearchType !== searchType) {
                $scope.showSearch = false;
            }

            if ($scope.showSearch === false) {

                var css = { "top": top };

                /**
                 * Set the search type on the scope
                 */
                $scope.theSearchType = searchType;

                /**
                 * Set the search text on the scope
                 */
                $scope.searchText = searchText;

                /**
                 * Get the position of the icon
                 */
                var top = ($event.currentTarget.offsetTop - 8) + "px";

                /**
                 * If the search type is course
                 * show the checkbox
                 * extend the css object
                 */
                if ($scope.theSearchType === "course") {
                    $scope.showCheckBox = true;
                    angular.extend(css, {
                        "top": top,
                        "height": "110px"
                    }) ;
                }

                /**
                 * If the search type is client
                 * hide the checkbox
                 * extend the css object
                 */
                if ($scope.theSearchType === "client") {
                    $scope.showCheckBox = false;
                    angular.extend(css, {
                        "top": top,
                        "height": "86px"
                    });
                }

                /**
                 * If the search type is system feature 
                 * hide the checkbox
                 * extend the css object
                 */
                if ($scope.theSearchType === "systemfeature") {
                    $scope.showCheckBox = false;
                    angular.extend(css, {
                        "top": top,
                        "height": "86px"
                    });
                }


                $("#quickSearchContainer").show();
                $("#quickType").focus();
                $("#quickSearchContainer").css(css);


                
                $scope.showSearch = true;
                return false;
            }
            else if ($scope.showSearch === true) {
                $scope.closeContainer();
            }
        };

        /**
         * Show and hide the blocked user list based upon
         * a boolean value on the showClientSearch
         */
        $scope.showBlockedUsers = function () {

            $scope.showingBlockedUsers = !$scope.showingBlockedUsers;
            $scope.showSearch = false;
            if ($scope.showingBlockedUsers) {
                $scope.refreshBlockedUserList();
            }
        };

        $scope.refreshBlockedUserList = function() {
            $scope.userService.getBlockedUsers($scope.organisationId, $scope.userId)
                    .then(function (data) {
                        $scope.selectedBlockedUserId = -1;
                        $scope.blockedUsers = data;
                    });
        }

        $scope.selectBlockedUser = function (blockedUserId) {
            if ($scope.selectedBlockedUserId == blockedUserId) {
                $scope.selectedBlockedUserId = -1;
            }
            else {
                $scope.selectedBlockedUserId = blockedUserId;
            }
        }

        $scope.unblockUser = function (userId) {
            $scope.userService.unblockUser(userId)
                .then(function (data) {
                    $scope.refreshBlockedUserList();
                });
        }

        $scope.unblockAllUsers = function () {
            $scope.userService.unblockAllUsersInOrganisation($scope.organisationId, $scope.userId)
                .then(function (data) {
                    $scope.refreshBlockedUserList();
                });
        }

        $scope.GetBlockedSince = function (dateString) {
            var date = new Date(dateString);
            var hours = date.getHours();
            var ampm = hours >= 12 ? 'pm' : 'am';
            hours = hours % 12;
            hours = hours == 0 ? 12 : hours;    // if hours is 0 change it to 12
            var minutes = date.getMinutes();
            var minutes = ("0" + minutes).slice(-2); //format to '00'
            var day = date.getDate();

            var ordinal = 'th';
            if (day <= 3 || day >= 21) {    // to avoid the teens
                switch (day % 10) {
                    case 1: ordinal = "st";
                        break;
                    case 2: ordinal = "nd";
                        break;
                    case 3: ordinal = "rd";
                        break;
                    default: ordinal = "th";
                }
            }
            
            
            var monthIndex = date.getMonth();
            var monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return " (since "+ hours + ":" + minutes + ampm + " "  + day + ordinal + " " + monthArray[monthIndex] + ")";
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
                organisationId: $scope.organisationId,
                content: $scope.searchContent,
                searchType: $scope.theSearchType
            };

            /**
             * If the search type is a course 
             * add a further property to the object
             */
            if ($scope.theSearchType === "course") {

                /**
                 * Add a "+" to the icon to 
                 * Convert the Boolean to an int
                 */
                var futureDateInteger = +$scope.showFutureDates;
                searchOptions = angular.extend(searchOptions, { showRecent: futureDateInteger});
            }

            /**
             * Return the related content
             */
            return QuickSearchService.getSearchableContent(searchOptions);
            
        };

        /**
         * Callback to fire once the client has been selected
         */
        $scope.selectedItem = function () {

            var modalDetails = {
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            }

            /**
             * If the searchtype is "client"
             * Create the object for the modal options
             */
            if ($scope.theSearchType === "client") {
                
                $scope.clientId = $scope.selected.ClientId;
                modalDetails = angular.extend(modalDetails, {
                    scope: $scope,
                    title: "Client Details",
                    cssClass: "clientDetailModal",
                    filePath: "/app/components/client/cd_view.html",
                    controllerName: "clientDetailsCtrl",
                });

            }

            /**
             * If the searchtype is "client"
             * Create the object for the modal options
             */
            if ($scope.theSearchType === "course") {

                //$scope.clientId = $scope.selected.CourseId;
                $scope.courseId = $scope.selected.CourseId;
                modalDetails = angular.extend(modalDetails, {
                    scope: $scope,
                    title: "View course",
                    cssClass: "courseViewModal",
                    filePath: "/app/components/course/edit.html",
                    controllerName: "editCourseCtrl",
                });

            }

            /**
             * If the searchtype is "systemfeature"
             * Create the object for the modal options
             */
            if ($scope.theSearchType === "systemfeature") {
                $scope.systemFeatureId = $scope.selected.SystemFeatureItemId;
                $scope.systemFeatureTitle = $scope.selected.TitleContent;
                modalDetails = angular.extend(modalDetails, {
                    scope: $scope,
                    title: $scope.selected.TitleContent,
                    cssClass: "systemFeatureInformationModal",
                    filePath: "/app/components/systemFeature/view.html",
                    controllerName: "SystemFeatureInformationCtrl",
                });
            }


            /**
             * Empty the selected Object
             * After the selected.Id has been assigned
             */
            $scope.selected = undefined;

            /**
             * Hide the quickSearchContainer
             */
            $("#quickSearchContainer").hide();
            $scope.showSearch = false;

            /**
             * Fire the modal
             */
            ModalService.displayModal(modalDetails);
        };

        /**
         * 
         */
        $scope.closeContainer = function () {

            $("#quickSearchContainer").hide();
            $scope.showSearch = false;

            /**
             * Empty the selected Object
             * After container has been closed
             */
            $scope.selected = undefined;

            /**
             * Set both loading and no results to false
             */
            $scope.loadingLocations = false;
            $scope.noResults = false;

            return false;
        }



    }

})();