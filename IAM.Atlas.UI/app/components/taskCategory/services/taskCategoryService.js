(function () {

    'use strict';

    angular
        .module('app')
        .service('TaskCategoryService', TaskCategoryService);


    TaskCategoryService.$inject = ["$http"];

    function TaskCategoryService($http) {

        var taskCategoryService = this;

        /**
        * Get the Languages
        */
        //interpreterLanguageService.getLanguages = function () {
        //    return $http.get(apiServer + "/interpreterLanguage/GetLanguages");
        //};

        /**
        * Get the Interpreter Languages
        */
        taskCategoryService.getTaskCategoryByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/taskCategory/GetTaskCategoryByOrganisation/" + OrganisationId)
        };

        /**
        * Get the Interpreter Names
        */
        //interpreterLanguageService.getInterpreterNamesByOrganisationLanguage = function (OrganisationId, LanguageId) {
        //    return $http.get(apiServer + "/interpreterLanguage/GetInterpreterNamesByOrganisationLanguage/" + OrganisationId + "/" + LanguageId)
        //};

        /**
        * Get the Interpreter Titles
        */
        //interpreterLanguageService.getInterpreterTitles = function () {
        //    return $http.get(apiServer + "/interpreterLanguage/GetTitles");
        //};

        /**
        * Update a Task Category
        */
        taskCategoryService.saveTaskCategory = function (taskCategory) {
            return $http.post(apiServer + "/taskCategory/SaveTaskCategory/", taskCategory)
        };

        /**
        * Add a new Task Category
        */
        taskCategoryService.addTaskCategory = function (taskCategory) {
            return $http.post(apiServer + "/taskCategory/AddTaskCategory/", taskCategory)
        };


        /**
      * Save Edit Interpreter
      */
        //interpreterLanguageService.saveEdit = function (interpreter) {
        //    return $http.post(apiServer + "/interpreterLanguage/EditInterpreter/", interpreter)
        //};

        /**
        * Get an Interpreter
        */
        //interpreterLanguageService.getInterpreterById = function (InterpreterId) {
        //    return $http.get(apiServer + "/interpreterLanguage/GetInterpreterById/" + InterpreterId);
        //};

        /**
        * Get Interpreter Notes By Id
        */
        //interpreterLanguageService.getInterpreterNotesById = function (InterpreterId) {
        //    return $http.get(apiServer + "/interpreterLanguage/GetInterpreterNotesById/" + InterpreterId);
        //};

        /**
        * Save an Interpreter Note
        */
        //interpreterLanguageService.saveNote = function (note) {
        //    return $http.post(apiServer + "/interpreterLanguage/SaveNote", note)
        //};
    }

})();