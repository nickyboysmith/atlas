(function () {

    angular
        .module("app")
        .service("QuickSearchService", QuickSearchService);

    QuickSearchService.$inject = ["$http"];

    function QuickSearchService($http) {

        var quickSearch = this;

        /**
         * Get searchable content
         */
        quickSearch.getSearchableContent = function (searchOptions) {

            if (searchOptions.hasOwnProperty("showRecent")) {
                var endpoint = apiServer + "/quicksearch/" + searchOptions.searchType + "/" + searchOptions.content + "/" + searchOptions.organisationId + "/" + searchOptions.showRecent;
            }  
                
            if (!searchOptions.hasOwnProperty("showRecent")) {
                var endpoint = apiServer + "/quicksearch/" + searchOptions.searchType + "/" + searchOptions.content + "/" + searchOptions.organisationId;
            }

            return $http.get(endpoint)
                .then(function (response) {
                    return response.data.map(function (item) {
                        return item;
                    });
                });
        };

    }

})();