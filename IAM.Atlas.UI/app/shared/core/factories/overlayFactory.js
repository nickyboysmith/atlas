// Interceptor for overlay spinner
(function(){

    angular
        .module("app")
        .factory("OverlayFactory", OverlayFactory);

    OverlayFactory.$inject = ["$q"];

    function OverlayFactory($q) {


        //initialize counter 
        var requestCounter=0; 
        
        return {
            // optional method

            // On request success 
            'request': function (config) {

                // will be incremented on each request 
                requestCounter++;

                // show loader if not visible already 
                if (!$('#preloader').is(':visible')) {
                    $('#preloader').show();
                }

                // Return the config or wrap it in a promise if blank. 
                //it is required to return else call will not work 
                return config || $q.when(config);

            },

            // On request failure 

            'requestError': function (rejection) {

                //decrement counter as request is failed 
                requestCounter--;
                hideLoaderIfNoCall();

                // Return the promise rejection. 
                return $q.reject(rejection);

            },

            // On response success 

            'response': function (response) {

                //decrement counter as request is failed 

                requestCounter--;
                hideLoaderIfNoCall();

                // Return the response or promise. 
                return response || $q.when(response);

            },

            // On response failture 

            'responseError': function (rejection) {

                //decrement counter as request is failed 

                requestCounter--;

                hideLoaderIfNoCall();

                // Return the promise rejection. 

                return $q.reject(rejection);

            }
        };

        function hideLoaderIfNoCall(){ 
 
            // check if counter is zero means  
            // no request is in process 
 
            // use triple equals see why http://goo.gl/2K4oTX 
 
            if(requestCounter === 0)   
                $('#preloader').hide();         
        } 

}

})();