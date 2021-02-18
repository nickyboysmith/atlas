// --------------------------------------------------------------------------------------------------------------------
// <copyright file="RouteConfig.cs" company="Hewlett-Packard Company">
//   Copyright © 2015 Hewlett-Packard Company
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace IAM.Atlas.UI
{
    using System.Web.Routing;

    using IAM.Atlas.UI.Routing;
    using System.Web.Mvc;

    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.Add("Default", new DefaultRoute());
        }
    }
}
