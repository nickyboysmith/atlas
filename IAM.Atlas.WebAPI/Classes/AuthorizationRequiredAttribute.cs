using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http.Filters;
using System.Net;
using System.Net.Http;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI
{
    public class AuthorizationRequiredAttribute : ActionFilterAttribute
    {
        public TokenServices _tokenServices = new TokenServices();
 
        public override void OnActionExecuted(HttpActionExecutedContext actionExecutedContext)
        {
            var hasToken = actionExecutedContext.Request.Headers.Contains("X-Auth-Token");

            // Check to see if the request has a token
            if (hasToken)
            {
                var token = actionExecutedContext.Request.Headers.GetValues("X-Auth-Token").ToList();
                var userIdAssociatedWithToken = _tokenServices.GetTokenUserId(token[0]);
                var errorMessage = "";

                //TO DO: Refactor messages - use enum or JSON. Used in unAuthorizedAccessFactory.js
                if (!_tokenServices.ValidateToken(token[0]))
                {
                    if (userIdAssociatedWithToken == 0)
                    {
                        errorMessage = "You've been signed in, in another location. You will be signed out.";
                    } else {
                        errorMessage = "For security reasons your session has timed out and you will be logged out.";
                    }

                    var responseMessage = new HttpResponseMessage(HttpStatusCode.Unauthorized)
                    {
                        ReasonPhrase = errorMessage
                    };
                    actionExecutedContext.Response = responseMessage;
                }
            }

            // If the request doesn't have a valid token
            // Then discard straight away
            if (!hasToken)
            {
                var responseMessage = new HttpResponseMessage(HttpStatusCode.Unauthorized) {
                    ReasonPhrase = "Unauthorized Request"
                };
                actionExecutedContext.Response = responseMessage;
            }
            base.OnActionExecuted(actionExecutedContext);

        }
    }
}