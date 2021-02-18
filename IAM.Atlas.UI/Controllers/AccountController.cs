using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using System.Web.Helpers;
using System.Web.Security;
using IAM.Atlas.Data;

namespace App.IAM.Atlas.UI.Controllers
{
    public class AccountController : AtlasBaseController
    {
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(UserData model, string returnUrl)
        {
            // Lets first check if the Model is valid or not
            if (ModelState.IsValid)
            {               
                    //string username = model.username;
                    //string password = model.password;
                    // Check if user is submitting an id or email
                bool usingEmail = this.isValidEmail(model.UserName);
                    // Now if our password was enctypted or hashed we would have done the
                    // same operation on the user entered password here, But for now
                    // since the password is in plain text lets just authenticate directly

                    //bool userValid = entities.Users.Any(user => user.username == username && user.password == password);

                    // User found in the database
                    if (this.authenticateUserCredentials(
                    usingEmail ? model.UserName : "",
                    usingEmail ? "" : model.UserName,
                    model.Password,
                    usingEmail))
                    {

                        FormsAuthentication.SetAuthCookie(model.UserName, false);
                        if (Url.IsLocalUrl(returnUrl) && returnUrl.Length > 1 && returnUrl.StartsWith("/")
                            && !returnUrl.StartsWith("//") && !returnUrl.StartsWith("/\\"))
                        {
                            return Redirect(returnUrl);
                        }
                        else
                        {
                            return RedirectToAction("Index", "Home");
                        }
                    }
                    else
                    {
                        ModelState.AddModelError("", "The user name or password provided is incorrect.");
                    }                
            }

            // If we got this far, something failed, redisplay form
            return View(model);
        }

        public ActionResult LogOff()
        {
            FormsAuthentication.SignOut();

            return RedirectToAction("Index", "Home");
        }

        public class UserData
        {
            public string UserName { get; set; }
            public string Password { get; set; }
            public string Os { get; set; }
            public string Browser { get; set; }
            public string Ip { get; set; }
        }
    }
}
