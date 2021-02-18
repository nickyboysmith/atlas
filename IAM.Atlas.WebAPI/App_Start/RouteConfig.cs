﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace IAM.Atlas.WebAPI
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );

            routes.MapRoute(
                name: "GetAll",
                url: "{controller}/{action}",
                defaults: new { controller = "Settings", action = "GetAll" }
            );

            routes.MapRoute(
                name: "Get",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Settings", action = "Get", id = UrlParameter.Optional }
            );


        }
    }
}
