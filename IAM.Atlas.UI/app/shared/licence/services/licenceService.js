(function () {

    'use strict';

    angular
        .module("app")
        .service("LicenceService", LicenceService);

    LicenceService.$inject = ["$http"];

    function LicenceService($http) {

        var driverLicence = this;

        /**
         * The driver details return object
         */
        driverLicence.details = {};

        driverLicence.extractDriverDetails = function (licenceNumber) {
            try {
                var LicenceNumber = licenceNumber.replace(/ /g, "").toUpperCase();
                var r = new RegExp("^[A-Z][A-Z0-9]{4}" +
                                "[0-9]{6}" +
                                "[A-Z0-9]{5}$");
                if (r.test(LicenceNumber)) {
                    var monthDigit1 =
                        (LicenceNumber.charAt(6) == "5") ? "0" :
                            (LicenceNumber.charAt(6) == "6") ? "1" : LicenceNumber.charAt(6);
                    var dateString = "20" + LicenceNumber.charAt(10) + LicenceNumber.charAt(5) +
                        "/" +
                        monthDigit1 + LicenceNumber.charAt(7) +
                        "/" +
                        LicenceNumber.charAt(8) + LicenceNumber.charAt(9);

                    if (isNaN(Date.parse(dateString))) {
                        return false;
                    }
                    var licenceValidity = (Date.parse(dateString) > 0);

                    if (licenceValidity == true) {
                        //Create and return the driverLicence.details object
                        driverLicence.details.DOB = dateString;
                        driverLicence.details.firstName = isLetter(LicenceNumber.charAt(11)) ? LicenceNumber.charAt(11) : "";
                        driverLicence.details.otherNames = isLetter(LicenceNumber.charAt(12)) ? LicenceNumber.charAt(12) : "";
                        driverLicence.details.surname = LicenceNumber.substr(0, 5).replace(/9/g, "");
                        try{
                            if (driverLicence.details.surname != null && driverLicence.details.surname != undefined && driverLicence.details.surname.length > 2) {
                                driverLicence.details.surname = driverLicence.details.surname.charAt(0).toUpperCase() + driverLicence.details.surname.toLowerCase().slice(1);
                            }
                        }
                        catch (ignoreErr) {
                            //No Need to Worry about this one.
                        }
                        return driverLicence.details;
                    }
                } else {
                    return false;
                }
            }
            catch (err) {
                return false;
            }
        }

         function isLetter(character){
             var code = character.charCodeAt(0);
            if ( ((code >= 65) && (code <= 90)) || ((code >= 97) && (code <= 122)) ) {
                return true;
            }else{
                return false;
            }
        }

         function isNumber(character){
             var code = character.charCodeAt(0);
            if ( ((code >= 48) && (code <= 57))) {
                return true;
            }else{
                return false;
            }
        }
    }
})();