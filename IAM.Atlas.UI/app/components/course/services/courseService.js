(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseService", CourseService);

    CourseService.$inject = ["$http"];

    function CourseService($http) {

        var course = this;

        course.get = function (courseId, userId) {
            return $http.get(apiServer + "/course/" + courseId + "/" + userId)
        }

        /**
         * Object properties are returned as searchParam[xxxxx]
         * Need to extract the "xxxxx" out of the string
         */
        course.keyExtraction = function (searchString) {
            var regExp = /\[(.*?)\]/;
            var matches = regExp.exec(searchString);
            return matches[1];
        }


        /**
         * Return the transformed Date
         */
        course.dateTransformation = function (dateToConvert) {
            var theDate = new Date(dateToConvert);
            var convertedDate = theDate.toGMTString();
            return convertedDate;
        };


        /**
         * Transform the data in to a usable format
         */
        course.transformSearchData = function (searchResults) {

            var transformedSearchresults = {};
            var selectOptionList = {};

            angular.forEach(searchResults, function (searchResultValue, searchResultKey) {

                // get the date here
                var creationDate;


                /**
                 * Loop through the object the object
                 */
                angular.forEach(searchResultValue, function (resultValue, resultKey) {

                    /**
                     * So we only loop through the [Results] object
                     * Ignore anything that isn't in the a [Results] object
                     */
                    if (resultKey === "Results") {
                        /**
                         * [Results]
                         * Loop through the object again
                         */

                        var searchResultObject = {};
                        var searchOptionObject = {};

                        angular.forEach(resultValue, function (searchParam, searchParamKey) {
                            creationDate = course.dateTransformation(searchParam.CreationDate);

                            if (searchResultObject[searchParam.SearchHistoryUserId] === undefined) {
                                searchResultObject[searchParam.SearchHistoryUserId] = {};
                            }

                            /**
                             * Add to the search result object
                             */
                            searchResultObject[searchParam.SearchHistoryUserId][course.keyExtraction(searchParam.Name)] = searchParam.Value;

                            /**
                             * Add to the search option object
                             */
                            searchOptionObject[searchParam.SearchHistoryUserId] = creationDate;
                        });

                        /**
                         * Add the newly created object to the transformationObject
                         */
                        angular.extend(transformedSearchresults, searchResultObject);

                        /**
                         * Add the newly created object to the optionListObject
                         */
                        angular.extend(selectOptionList, searchOptionObject);

                    }
                });



            });

            return {
                results: transformedSearchresults,
                searches: selectOptionList
            };

        }


        /**
         * Get the searches 
         */
        course.getPreviousSearches = function (CourseId, UserId) {

            return $http.get(apiServer + "/SearchCourses/GetPreviousSearches/" + CourseId + "/" + UserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        };

        /**
         * Send the course params to the webapi 
         */
        course.searchCourses = function (searchDetails) {

            return $http.post(apiServer + "/SearchCourses", searchDetails)
                .then(function (response) {
                    return response.data;
                }, function (response, status) {
                    return response.data;
                });
        };

        /**
         * Get the related Venues
         */
        course.getRelatedVenues = function (organisationID) {
            return $http.get(apiServer + "/venue/" + organisationID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Venues for DORS/Non DORS Courses
         */
        course.getRelatedVenuesCheckDors = function (organisationID, dorsVenue) {
            var callPath = "/venue/GetVenuesWithDorsCheck/" + organisationID + "/" + dorsVenue;
            return $http.get(apiServer + callPath)
                .then(function (response) {
                    return response.data;
                }, function (response) {
                    var status = response.status;
                    var statusText = response.statusText;
                    var errMessage = "'" + callPath + "' ERROR: (" + status + ") " + statusText;
                    console.log(errMessage);
                    return false;
                });
        };

        /**
         * Get the related Course Types
         */
        course.getRelatedCourseTypes = function (organisationId) {
            return $http.get(apiServer + "/coursetype/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Course Type Categories
         */
        course.getRelatedCourseCategories = function (organisationID, userID) {
            return $http.get(apiServer + "/CourseTypeCategory/GetByOrganisation/" + organisationID + "/" + userID)            
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Course Type Categories
         */
        course.getCourseTypeCourseTypeCategories = function (courseTypeId, userID) {
            return $http.get(apiServer + "/CourseTypeCategory/GetByCourseType/" + courseTypeId + "/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Get the related Organisation Languages
         */
        course.getRelatedOrganisationLanguages = function (organisationId) {
            return $http.get(apiServer + "/organisationlanguage/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        course.getCourseNotes = function (courseId) {
            return $http.get(apiServer + "/coursenote/GetByCourseId/" + courseId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
        

        course.getClients = function (courseId, organisationId) {
            return $http.get(apiServer + "/course/getClients/" + courseId + "/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Get the Organisation System Configuration Settings
        */
        course.getOrganisationSystemConfiguration = function (organisationId) {
            return $http.get(apiServer + "/organisationsystemconfiguration/GetByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
        * Get the Organisation Self Configuration Settings
        */
        course.getOrganisationSelfConfiguration = function (organisationId) {
            return $http.get(apiServer + "/organisationselfconfiguration/GetByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        course.getDORSCourse = function (courseId) {
            return $http.get(apiServer + "/course/GetDORSCourse/" + courseId);
        }

        course.getCourseDocuments = function (courseId) {
            return $http.get(apiServer + "/course/GetCourseDocuments/" + courseId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        course.addDocument = function (document) {
            //return $http.post(apiServer + "/course/addDocument", document);
            var formData = new FormData();
            formData.append("CourseId", document.CourseId);
            formData.append("FileName", document.FileName);
            formData.append("Title", document.Title);
            formData.append("Description", document.Description);
            formData.append("OriginalFileName", document.OriginalFileName);
            formData.append("file", document.UploadedFile);
            formData.append("UpdatedByUserId", document.UpdatedByUserId);
            formData.append("OrganisationId", document.OrganisationId);

            var uploadUrl = apiServer + "/course/addDocument";

            //var fd = new FormData();
            ////Take the first selected file
            //fd.append("file", files[0]);

            return $http.post(uploadUrl, formData, {
                //withCredentials: true,
                headers: { 'Content-Type': undefined },
                transformRequest: angular.identity
            });
        }

        course.getCourseReference = function (organisationId, courseTypeCode) {
            return $http.get(apiServer + "/course/getCourseReference/" + organisationId + "/" + courseTypeCode)
            .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        course.getAvailableCourses = function (organisationId, userId, courseTypeId, courseTypeCategoryId, DORSCoursesOnly, clientId) {
            return $http.get(apiServer + "/course/GetAvailableCourses/" + organisationId + "/" + userId + "/" + courseTypeId + "/" + courseTypeCategoryId + "/" + DORSCoursesOnly + "/" + clientId);
        }

        course.getAvailableCoursesForTransfer = function (organisationId, userId, courseTypeId, courseTypeCategoryId, DORSCoursesOnly, clientId) {
            return $http.get(apiServer + "/course/getAvailableCoursesForTransfer/" + organisationId + "/" + userId + "/" + courseTypeId + "/" + courseTypeCategoryId + "/" + DORSCoursesOnly + "/" + clientId);
        }


        course.getReminderEmailByOrganisationCourseCode = function (organisationId, courseCode) {
            return $http.get(apiServer + "/course/GetReminderEmailByOrganisationCourseCode/" + organisationId + "/" + courseCode);
        }

        course.saveReminderEmailTemplate = function (reminderEmailTemplate) {
            return $http.post(apiServer + "/course/SaveReminderEmailTemplate/", reminderEmailTemplate);
        }

        course.getReminderSMSByOrganisationCourseCode = function (organisationId, courseCode) {
            return $http.get(apiServer + "/course/GetReminderSMSByOrganisationCourseCode/" + organisationId + "/" + courseCode);
        }

        course.saveReminderSMSTemplate = function (reminderSMSTemplate) {
            return $http.post(apiServer + "/course/SaveReminderSMSTemplate/", reminderSMSTemplate);
        }

        course.referenceGenerator = function () {
            var endpoint = apiServer + "/coursereferencegenerator";
            return $http.get(endpoint);
        }

        course.cloneCourseRequest = function (cloneSettings) {
            var endpoint = apiServer + "/courseclonerequest";
            return $http.post(endpoint, cloneSettings);
        };

        /* this function has the same functionality as getAvailableCourses but uses newer code */
        course.getCoursesWithPlaces = function (organisationId, courseTypeId, regionId, venueId, interpreter) {
            return $http.get(apiServer + "/course/GetCoursesWithPlaces/" + organisationId + "/" + courseTypeId + "/" + regionId + "/" + venueId + "/" + interpreter + "/-1");
        }

        /* this function has the same functionality as getAvailableCourses but uses newer code */
        course.getCoursesWithPlaces = function (organisationId, courseTypeId, regionId, venueId, interpreter, clientId) {
            return $http.get(apiServer + "/course/GetCoursesWithPlaces/" + organisationId + "/" + courseTypeId + "/" + regionId + "/" + venueId + "/" + interpreter + "/" + clientId);
        }

        course.getTrainingSessions = function () {
            return $http.get(apiServer + "/course/GetTrainingSessions")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        course.book = function (clientId, courseId, addedByUserId) {
            return $http.get(apiServer + "/course/book/" + clientId + "/" + courseId + "/" + addedByUserId);
        }

        course.getCourseAllocatedTrainersAndInterpreters = function (courseId) {
            return $http.get(apiServer + "/course/GetCourseAllocatedTrainersAndInterpreters/" + courseId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        course.GetByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/course/GetByOrganisation/" + organisationId);
        }

        course.getCoursePlacesDetail = function (courseId) {
            return $http.get(apiServer + "/course/GetCoursePlacesDetail/" + courseId);
        }
        
    }

})();