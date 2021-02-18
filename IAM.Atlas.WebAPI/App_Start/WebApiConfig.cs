using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using System.Web.Http.Cors;


namespace IAM.Atlas.WebAPI
{
    public static class WebApiConfig
    {



        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services
            // @todo put url in webapi config
            var allowedURL = System.Configuration.ConfigurationManager.AppSettings["frontendUrl"].ToString();
            var cors = new EnableCorsAttribute(allowedURL, "*", "*");
            config.EnableCors(cors);

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
