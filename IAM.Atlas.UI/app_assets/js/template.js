function TemplateManager()
{

    var body = document.getElementById("mainBody");

    /**
        * Check to see if a cookie with the 
        * Name of Atlas_Template exists
        * @return false or the value of the cookie
        */
    function checkCookieExists(cookieName)
    {
        cookieName = "Atlas_" + cookieName;
        if (cookieName === undefined) {
            return false;
        }
        return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(cookieName).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || false;
    };

    /**
        * Clear the old class
        * Then replace with the updated Class
        */
    function updateClass(newClass)
    {
        body.className = "";
        body.className = newClass;
    };

    /**
        * Change the template - Check to see if the cookie exists.
        * If it does then change the template
        */
    this.changeTemplate = function (cookieName)
    {

        var cookieCheck = checkCookieExists(cookieName);

        if (!cookieCheck) {
        }

        if (cookieCheck) {
            updateClass(cookieCheck);
        }

    };

    /**
     * Just update the template
     */
    this.update = function (template) {
        if (template === undefined) {
        }

        if (template) {
            updateClass(template);
        }
    }

    this.updateContainer = function (template) {
        body = document.getElementById("mainContentContainer");
        this.update(template);
    }

    this.changeContainer = function (cookie) {
        body = document.getElementById("mainContentContainer");
        this.change(cookie);
    }


    return {
        change: this.changeTemplate,
        changeContainer: this.changeContainer,
        update: this.update,
        updateContainer: this.updateContainer
    };

}


/**
    * Instatiate the template manager
    * Then call the change method
    */
var template = new TemplateManager();
template.change("template");
template.changeContainer("containerAlignment");


