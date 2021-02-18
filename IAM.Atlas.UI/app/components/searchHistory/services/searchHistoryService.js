(function () {

    'use strict';

    angular
        .module("app")
        .service("SearchHistoryService", SearchHistoryService);

    SearchHistoryService.$inject = ["$http"];

    function SearchHistoryService($http) {

        var searchHistoryService = this;

        /**
         * Object properties are returned as searchParam[xxxxx]
         * Need to extract the "xxxxx" out of the string
         */
        searchHistoryService.keyExtraction = function (searchString) {
            var regExp = /\[(.*?)\]/;
            var matches = regExp.exec(searchString);
            return matches[1];
        }


        /**
         * Return the transformed Date
         */
        searchHistoryService.dateTransformation = function (dateToConvert) {
            var theDate = new Date(dateToConvert);
            var convertedDate = theDate.toGMTString();
            return convertedDate;
        };


        /**
         * Transform the data in to a usable format
         */
        searchHistoryService.transformSearchData = function (searchResults) {

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
                            creationDate = searchHistoryService.dateTransformation(searchParam.CreationDate);

                            if (searchResultObject[searchParam.SearchHistoryUserId] === undefined) {
                                searchResultObject[searchParam.SearchHistoryUserId] = {};
                            }

                            /**
                             * Add to the search result object
                             */
                            searchResultObject[searchParam.SearchHistoryUserId][searchHistoryService.keyExtraction(searchParam.Name)] = searchParam.Value;

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
        searchHistoryService.getPreviousSearches = function (searchInterfaceTitle, theUserId) {

            return $http({
                url: apiServer + "/usersearchhistory",
                method: "GET",
                params: {
                    searchInterfaceTitle: searchInterfaceTitle,
                    userId: theUserId
                },
            })
            .then(function (data) { }, function (data) { });

        };


        /**
         * Save the current search into the search history
         */
        searchHistoryService.saveCurrentSearch = function (searchDetails) {
            return $http.post(apiServer + "/usersearchhistory", searchDetails)
                .then(function (data) {
                    //console.log(data);
                    return "success";
                }, function(data, status) {
                    //console.log(data);
                    //console.log(status);
                    return "failed: " + status;
                });
        }

    }


})();