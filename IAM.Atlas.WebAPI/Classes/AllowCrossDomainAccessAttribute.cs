using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.Filters;

namespace IAM.Atlas.WebAPI
{
    public class AllowCrossDomainAccessAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuted(HttpActionExecutedContext actionExecutedContext)
        {
            if (actionExecutedContext.Response != null)
            {
                actionExecutedContext.Response.Headers.Add("Access-Control-Allow-Headers", "X-Auth-Token");
                actionExecutedContext.Response.Headers.Add("Access-Control-Expose-Headers", "X-Auth-Token");
                actionExecutedContext.Response.Headers.Add("Access-Control-Allow-Origin", "*");
            }


            base.OnActionExecuted(actionExecutedContext);
        }
    }
}