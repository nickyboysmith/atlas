(function () {

    'use strict';

    angular
        .module('app')
        .service('InterpreterLanguageService', InterpreterLanguageService);


    InterpreterLanguageService.$inject = ["$http"];

    function InterpreterLanguageService($http) {

        var interpreterLanguageService = this;

        /**
        * Get the Languages
        */
        interpreterLanguageService.getLanguages = function () {
            return $http.get(apiServer + "/interpreterLanguage/GetLanguages");
        };

        /**
        * Get the Interpreter Languages
        */
        interpreterLanguageService.getLanguagesByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/interpreterLanguage/GetLanguagesByOrganisation/" + OrganisationId)
        };

        /**
        * Get the Interpreter Names
        */
        interpreterLanguageService.getInterpreterNamesByOrganisationLanguage = function (OrganisationId, LanguageId) {
            return $http.get(apiServer + "/interpreterLanguage/GetInterpreterNamesByOrganisationLanguage/" + OrganisationId + "/" + LanguageId)
        };

        /**
        * Get the Interpreter Titles
        */
        interpreterLanguageService.getInterpreterTitles = function () {
            return $http.get(apiServer + "/interpreterLanguage/GetTitles");
        };

       /**
       * Save Add Interpreter
       */
        interpreterLanguageService.saveAdd = function (interpreter) {
            return $http.post(apiServer + "/interpreterLanguage/AddInterpreter/", interpreter)
        };

        /**
      * Save Edit Interpreter
      */
        interpreterLanguageService.saveEdit = function (interpreter) {
            return $http.post(apiServer + "/interpreterLanguage/EditInterpreter/", interpreter)
        };

        /**
        * Get an Interpreter
        */
        interpreterLanguageService.getInterpreterById = function (InterpreterId) {
            return $http.get(apiServer + "/interpreterLanguage/GetInterpreterById/" + InterpreterId);
        };

        /**
        * Get Interpreter Notes By Id
        */
        interpreterLanguageService.getInterpreterNotesById = function (InterpreterId) {
            return $http.get(apiServer + "/interpreterLanguage/GetInterpreterNotesById/" + InterpreterId);
        };

        /**
        * Save an Interpreter Note
        */
        interpreterLanguageService.saveNote = function (note) {
            return $http.post(apiServer + "/interpreterLanguage/SaveNote", note)
        };
    }

})();