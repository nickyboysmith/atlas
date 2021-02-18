(function () {

    'use strict';


    angular
        .module("app")
        .factory("EventHistoryFactory", EventHistoryFactory);


    function EventHistoryFactory() {

        var eventFactoryMethods = {
            hideTable: hideSmartTable,
            error: getErrors
        };

        return eventFactoryMethods;

        function hideSmartTable(currentObjectLength) {
            if (currentObjectLength === 0) {
                return true;
            }
            return false;
        }

        function getErrors(hideTable, option) {
            if (hideTable === true) {
                if (option === "empty") {
                    return "No history available";
                }
                if (option === "error") {
                    return "Something has gone wrong. If this continues to happen please contact yousupport team.";
                }
            }

        }

    };

})();