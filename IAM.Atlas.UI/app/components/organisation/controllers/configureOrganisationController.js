(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('ConfigureOrganisationCtrl', ConfigureOrganisationCtrl);

    ConfigureOrganisationCtrl.$inject = ["$scope", "$window", "ConfigureOrganisationService", "SystemFontService", "OrganisationDisplayService"];

    function ConfigureOrganisationCtrl($scope, $window, ConfigureOrganisationService, SystemFontService, OrganisationDisplayService)
    {

        /**
         * Load the fonts into the Configure organisation form
         */
        SystemFontService.getFonts()
            .then(function (fontResponse) {
                $scope.fonts = fontResponse;
            }, function () {

            });

        /**
         * Create the organisation Object
         */
        $scope.organisation = {};

        /**
         * Create the return message
         */
        $scope.returnApiMessage = "";
        /**
         * If User has already filled out config org page
         */
        OrganisationDisplayService.getOrganisationConfiguration(100)
            .then(function (response) {

                if (response.ImageFilePath) {
                    OrganisationDisplayService.getImageBase64(
                        apiServerImagePath + "/" + response.ImageFilePath,
                        function (base64Img) {

                            $window.companyImage = base64Img;
                            $scope.tempImage = base64Img.split(",");
                            $scope.organisation.companyImage = $scope.tempImage[1];

                        }
                    );
                }

                $scope.organisation.companyName = response.DisplayName;
                $scope.organisation.showLogo = response.ShowLogo;
                $scope.organisation.alignLogo = response.LogoAlignment;
                $scope.organisation.showDisplayName = response.ShowDisplayName;
                $scope.organisation.alignDisplayName = response.DisplayNameAlignment;
                $scope.organisation.showBorder = response.HasBorder;
                $scope.organisation.borderColor = response.BorderColour;
                $scope.organisation.backgroundColor = response.BackgroundColour;
                $scope.organisation.fontColor = response.FontColour;
                $scope.organisation.fontName = response.SystemFontId;

            }, function (data) {
                $scope.organisation.showBorder = true;
            });

        /**
         * Get the correct preview position
         */
        $scope.previewPosition = ["left",  "right"];
        $scope.getOppositePosition = function (position) {
            var endPosition;
            angular.forEach($scope.previewPosition, function (value) {
                if (position !== value) {
                    endPosition = value;
                };
            });
            return endPosition;
        };

        /**
         * Display an image preview
         */
        $scope.showImagePreview = function () {
            if (event.target.files && event.target.files[0]) {
                $(".companyLogo").show();
                $("#displayName").css({ "width": "", "float": "right", "text-align": "" });
                var reader = new FileReader();
                reader.onload = function (e) {
                    $(".image-preview > img").attr('src', e.target.result);
                    $(".companyLogo > img").attr('src', e.target.result);

                    $scope.tempImage = e.target.result.split(",");
                    $scope.organisation.companyImage = $scope.tempImage[1];
                }
                reader.readAsDataURL(event.target.files[0]);
                $scope.organisation.showLogo = true;
            }
        };

        /**
         * Watch for Model changes
         */
        $scope.watchDisplayNameChanges = function () {
            if ($scope.organisation.companyName.length === 0) {
                $scope.organisation.showDisplayName = false;
            }
            if ($scope.organisation.companyName.length > 1) {
                $scope.organisation.showDisplayName = true;

                $scope.displayNameHeight = $("#displayName").outerHeight();
                if ($scope.displayNameHeight === 28) {
                   $("#displayName").css("margin-top", "11px");
                }
                if ($scope.displayNameHeight >= 56) {
                    $("#displayName").css("margin-top", "-4px");
                }
            }
            if ($scope.organisation.image === undefined) {
                $(".companyLogo").hide();
                $("#displayName").css({"width": "100%", "float":"none", "text-align": "center"});

            }
        };

        /**
         * Align the logo
         */
        $scope.logoAlignment = function () {
            $("#displayName").css("float", $scope.organisation.alignLogo);
            $("#companyLogo").css("float", $scope.getOppositePosition($scope.organisation.alignLogo));
        };

        /**
         * Align the display name 
         */
        $scope.displayNameAlignment = function () {
            $("#displayName").css("float", $scope.getOppositePosition($scope.organisation.alignDisplayName));
            $("#companyLogo").css("float", $scope.organisation.alignDisplayName);
        };

        /**
         * Show the preview border
         */
        $scope.showPreviewBorder = function () {
            if (!$scope.organisation.showBorder) {
                $("#previewHold").css("border", "0px");

            }
            if ($scope.organisation.showBorder) {
                $("#previewHold").css("border", "2px solid " + $scope.organisation.borderColor);
            }
        };

        /**
         * Change the border colour
         */
        $scope.changeBorderColor = function () {
            $("#previewHold").css("border", "2px solid " + $scope.organisation.borderColor);
        };


        $(document).on("click", "#theBorderColor", function () {
            $("#theBorderColor").spectrum({
                hideAfterPaletteSelect: true,
                move: function (color) {
                    $scope.organisation.borderColor = color.toHexString();
                    $("#previewHold").css("border", "2px solid " + $scope.organisation.borderColor);
                }
            }).trigger("click");
        });

        $(document).on("click", "#theBackgroundColor", function () {
            $(this).spectrum({
                hideAfterPaletteSelect: true,
                move: function (color) {
                    $scope.organisation.backgroundColor = color.toHexString();
                    $("#previewHold").css("background", $scope.organisation.backgroundColor);
                }
            }).trigger("click");
        });



        $(document).on("click", "#theFontColor", function () {
            $("#theFontColor").spectrum({
                hideAfterPaletteSelect: true,
                move: function (color) {
                    $scope.organisation.fontColor = color.toHexString();
                    $("#displayName").css("color", $scope.organisation.fontColor);
                }
            }).trigger("click");
        });


        $scope.changeFontName = function () {
            $("#displayName").css("font-family", $scope.organisation.fontName );
        };

        $scope.saveLogoOptions = function () {

            $scope.organisation.organisationId = 100;
            $scope.organisation.organisationName = "IAM";
            $scope.organisation.userID = 1;

            $scope.organisationService = ConfigureOrganisationService;

            $scope.validatedOrganisationDetails = $scope.organisationService.validateOrganisationOptions($scope.organisation);

            if ($scope.validatedOrganisationDetails === false) {
                $scope.returnApiMessage = "You need to add an image or a display name to proceed.";
            }

            if ($scope.validatedOrganisationDetails !== false) {
                $scope.organisationService.saveDetails($scope.validatedOrganisationDetails)
                .then(function (data) {
                    $scope.returnApiMessage = data;
                    $scope.organisation = {};
                    $(".companyLogo > img").attr("src", "");
                    $(".image-preview > img").attr("src", "");


                    $("#previewHold").removeAttr("style");
                    $("#displayName").removeAttr("style");
                }, function(data) {
                    $scope.returnApiMessage = data;
                    console.log("There has been an error");
                });
            }


        };


    }


})();