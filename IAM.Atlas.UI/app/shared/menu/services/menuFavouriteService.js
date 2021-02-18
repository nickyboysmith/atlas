(function () {


    'use strict';

    angular
        .module("app")
        .service("MenuFavouriteService", MenuFavouriteService);

    MenuFavouriteService.$inject = ["$http"];
    
    function MenuFavouriteService($http) {

        var menuFavouriteService = this;

        /**
         * Get menu favourites for a user id
         */
        menuFavouriteService.getMenuFavourite = function (userId) {
            return $http.get(apiServer + "/menuFavourite/" + userId);
        };

        /**
         * save a menu item
         */
        menuFavouriteService.saveMenuFavourite = function (favouriteMenu) {
            return $http.post(apiServer + "/menuFavourite", favouriteMenu);
        };
        
    }
 
})();




