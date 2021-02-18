(function () {

    'use strict';

    angular
        .module("app")
        .factory("ModalOptionsFactory", ModalOptionsFactory);

    function ModalOptionsFactory() {

        /**
         * Method to extend the current modal
         * use view app\components\courseTypeCategories\assignTrainer.html
         * To See how the extend HTML Markup is structured
         * 
         * ModalOptions Required
         * mainModalID: "#viewVenue" // ID of the modal
         * firstColumn: "#firstVenueModalColumn" // Column to change the 
         * secondColumn: "#additionalVenueDetailContainer" // Column to unhide - 
         * classToRemove: "col-md-12" // column size that needs to be changed
         * classToAdd: "col-md-4" // column size that will replace the changed col size
         * cssProperties: {width: "1000px"} // Style properties in an object
         * 
         */
        this.extendModal = function (modalExtensionOptions) {


            var sampleObject = {
                mainModalID: "#viewVenue",
                firstColumn: "#firstVenueModalColumn",
                secondColumn: "#additionalVenueDetailContainer",
                classToRemove: "col-md-12",
                classToAdd: "col-md-4",
                cssProperties: {
                    width: "1000px"
                }
            };



            /**
             * Open the modal
             */
            $(".modal-dialog").css(modalExtensionOptions.cssProperties);
            $(modalExtensionOptions.mainModalID).css(modalExtensionOptions.cssProperties);

            /**
             * Change the column from 12 to 4
             */
            $(modalExtensionOptions.firstColumn)
                .removeClass(modalExtensionOptions.classToRemove)
                .addClass(modalExtensionOptions.classToAdd);

            /**
             *  Show the additional details
             */
            $(modalExtensionOptions.secondColumn).show();
            
        };

        return {
            extend: this.extendModal
        };

    }


})();