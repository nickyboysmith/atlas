(function () {

    'use strict';

    angular
        .module("app")
        .service("NoteTypeService", NoteTypeService);

    NoteTypeService.$inject = ["$http"];

    /**
     * Get note types
     * Something that is used project wide
     */
    function NoteTypeService($http) {

        var noteType = this;

        noteType.getNoteTypes = function () {
            return $http.get(apiServer + '/ClientNote/GetTypes')
                .then(
                    function (response) {
                        return response.data;
                    },
                    function (response) {
                        return response.data;
                    }
                )
        };

    }



})();