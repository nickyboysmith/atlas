// --------------------------------------------------------------------------------------------------------------------
// <copyright file="DefaultRouteHandler.cs" company="Hewlett-Packard Company">
//   Copyright © 2015 Hewlett-Packard Company
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace IAM.Atlas.UI.Routing
{
    using System;
    using System.Web;
    using System.Web.Routing;
    using System.Web.WebPages;
    using IAM.Atlas.Tools;


    public class DefaultRouteHandler : IRouteHandler
    {

        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            // Use cases:
            //     ~/            -> ~/views/index.cshtml
            //     ~/about       -> ~/views/about.cshtml or ~/views/about/index.cshtml
            //     ~/views/about -> ~/views/about.cshtml
            //     ~/xxx         -> ~/views/404.cshtml

            // StringCipher.Decrypt()


            var authCookie = "";
            var browserCookie = requestContext.HttpContext.Request.Cookies["Atlas_userSession"];

            if (browserCookie == null)
            {
                authCookie = "no_cookie_found";
            }

            if (browserCookie != null)
            {
                var passPhrase = StringCipher.cookieOnlyPassPhrase;
                authCookie = StringCipher.Decrypt(browserCookie.Value, passPhrase);
            }


            var filePath = requestContext.HttpContext.Request.AppRelativeCurrentExecutionFilePath;

            var organisationCookieValue = "organisationUser";
            var trainerCookieValue = "trainerUser";
            var clientCookieValue = "clientUser";
            
            if (filePath == "~/unavailable")
            {
                filePath = "~/app/landingPages/client/loginView.cshtml";
            }
            else if (filePath == "~/login")
            {
                filePath = "~/app/landingPages/client/loginView.cshtml";
            }
            else if (filePath.Contains("~/admin/login"))
            {
                filePath = "~/app/landingPages/organisation/loginView.cshtml";
            }
            else if (filePath.Contains("~/admin") && authCookie == organisationCookieValue)
            {
                filePath = "~/app/landingPages/organisation/baseView.cshtml";
            }
            else if (filePath.Contains("~/admin") && authCookie != organisationCookieValue)
            {
                requestContext.HttpContext.Response.Redirect("/admin/login");
            }
            else if (filePath.Contains("~/trainer/login"))
            {
                filePath = "~/app/landingPages/trainer/loginView.cshtml";
            }
            else if (filePath.Contains("~/login"))
            {
                filePath = "~/app/landingPages/client/loginView.cshtml";
            }
            else if (filePath.Contains("~/trainer") && authCookie == trainerCookieValue)
            {
                filePath = "~/app/landingPages/trainer/baseView.cshtml";
            }
            else if (filePath.Contains("~/trainer") && authCookie != trainerCookieValue)
            {
                requestContext.HttpContext.Response.Redirect("/trainer/login");
            }
            else if (filePath.Contains("~/") && authCookie == clientCookieValue)
            {
                filePath = "~/app/landingPages/client/baseView.cshtml";
            }

            else if (filePath.Contains("~/ClientEmailConfirm"))
            {
                filePath = "~/app/landingPages/client/loginView.cshtml";
            }

            else if (filePath.Contains("~/") && authCookie != clientCookieValue && authCookie != organisationCookieValue)
            {
                //requestContext.HttpContext.Response.Redirect("/login");
                //Filter here to allow for possible organisation name paths

                filePath = "~/app/landingPages/client/loginView.cshtml";
            }
            else
            {
                if (!filePath.StartsWith("~/app/", StringComparison.OrdinalIgnoreCase))
                {
                    filePath = filePath.Insert(2, "app/");
                }

                if (!filePath.EndsWith(".html", StringComparison.OrdinalIgnoreCase))
                {
                    filePath = filePath += ".html";
                }
            }

            var handler = WebPageHttpHandler.CreateFromVirtualPath(filePath); // returns NULL if .cshtml file wasn't found
            if (handler == null)
            {
                requestContext.RouteData.DataTokens.Add("templateUrl", "/app/shared/error/view.html");
                handler = WebPageHttpHandler.CreateFromVirtualPath("~/app/shared/error/view.html");
            }
            else
            {
                requestContext.RouteData.DataTokens.Add("templateUrl", filePath.Substring(1, filePath.Length - 8));
            }

            return handler;
        }
    }
}
