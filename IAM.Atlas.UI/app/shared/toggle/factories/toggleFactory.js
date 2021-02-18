(function () {

    'use strict';

    angular
        .module("app")
        .factory("ToggleFactory", ToggleFactory);


    function ToggleFactory() {

        function getNextAlignment(alignmentObject, currentAlignment) {

            /**
             * Get the object length
             */
            var alignmentAmount = alignmentObject.length;

            /**
             * The alignment key starting from 0
             * So we minus one to achieve that
             */
            var alignmentKey = alignmentAmount - 1;

            /**
             * The current key
             */
            var currentAlignmentKey = 0;

            /**
             * the updated key
             */
            var updatedKey = 0

            /**
             * Loop through the object
             * To find the correct key
             */
            angular.forEach(alignmentObject, function (value, key) {
                if (value.position === currentAlignment) {
                    currentAlignmentKey = key;
                }
            });

            /**
             * If the key is not at the end of the object 
             * Then increment value by 1
             */
            if (currentAlignmentKey !== alignmentKey) {
                updatedKey = ++currentAlignmentKey;
            }

            /**
             * Returns the next position
             */
            return alignmentObject[updatedKey]["position"];


        }

        return {
            getNextAlignment: getNextAlignment
        };

    }

})();