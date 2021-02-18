using System;
using System.Net;
using System.Net.Http.Formatting;
using System.Text;
using System.Linq;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System.Web;
using System.Web.Mvc;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Data.Entity.Validation;
using System.Data.Entity;
using System.Configuration;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class AtlasBaseController : ApiController
    {
        private Atlas_DevEntities _atlasDB = new Atlas_DevEntities();
        private Atlas_DevEntitiesViews _atlasDBViews = new Atlas_DevEntitiesViews();

        public enum UserLevel {Client, Trainer, OrganisationUser, OrganisationAdministrator, SystemAdministrator};

        public Atlas_DevEntities atlasDB
        {
            get
            {
                //TODO: Add to all relevant configs but we default to 60
                var EFCommandTimeout = StringTools.GetInt(ConfigurationManager.AppSettings["EntityFrameworkCommandTimeout"]);

                _atlasDB.Configuration.LazyLoadingEnabled = false;
                _atlasDB.Database.CommandTimeout = EFCommandTimeout == -1 ? 60 :  EFCommandTimeout;
                return _atlasDB;
            }
        }

        public Atlas_DevEntitiesViews atlasDBViews
        {
            get
            {
                //TODO: Add to all relevant configs but we default to 60
                var EFCommandTimeout = StringTools.GetInt(ConfigurationManager.AppSettings["EntityFrameworkCommandTimeout"]);

                _atlasDBViews.Configuration.LazyLoadingEnabled = false;
                _atlasDBViews.Database.CommandTimeout = EFCommandTimeout == -1 ? 60 : EFCommandTimeout;
                return _atlasDBViews;
            }
        }
        
        /// <summary>
        /// Determines whether [is valid email] [the specified email address].
        /// Unit Test Written
        /// </summary>
        /// <param name="emailAddress">The email address.</param>
        /// <returns></returns>
        public bool IsValidEmail(string emailAddress)
        {
            if (Regex.IsMatch(emailAddress, @"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$"))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        //public void GetReportData(int reportRequestId)
        //{
        //    var items = _atlasDB.Database.SqlQuery<Object>("uspGetReportData @p0", reportRequestId);
        //}

        /// <summary>
        /// Verify that a user has the requested user level for the organisation in question: System Admins are always authorised
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="organisationId"></param>
        /// <param name="userLevel"></param>
        /// <returns></returns>
        public bool UserAuthorisedForOrganisation(int userId, int organisationId, UserLevel userLevel)
        {
            if (this.UserHasSystemAdminStatus(userId))
            {
                return true;
            }

            var hasOrganisationUserStatus = this.UserHasOrganisationUserStatus(userId, organisationId);

            var hasOrganisationAdminStatus = this.UserHasOrganisationAdminStatus(userId, organisationId);

            switch (userLevel)
            {
                case UserLevel.OrganisationUser:
                    return hasOrganisationUserStatus || hasOrganisationAdminStatus;

                case UserLevel.OrganisationAdministrator:
                    return hasOrganisationAdminStatus;

                    //TODO: cater for trainer-user and client-user scenarios                                                
            }

            return false;
        }

        public int? GetUserIdFromToken(HttpRequestMessage request)
        {
            if (request.Headers.Contains("X-Auth-Token"))
            {
                var authorisationToken = request.Headers.GetValues("X-Auth-Token").First();
                if (authorisationToken != "")
                {
                    var session = atlasDB.LoginSessions.Where(x => x.AuthToken == authorisationToken && x.ExpiresOn > DateTime.Now).OrderByDescending(y => y.Id).FirstOrDefault();
                    if (session != null)
                    {
                        return session.UserId;
                    }
                    else
                    {
                        return null;
                    }
                }
                else
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
        }


        public bool UserMatchesToken(int userId, HttpRequestMessage request)
        {
            if(request.Headers.Contains("X-Auth-Token"))
            {
                var authorisationToken = request.Headers.GetValues("X-Auth-Token").First();
                if(authorisationToken != "")
                {
                    if(userId == atlasDB.LoginSessions.Where(x=>x.AuthToken == authorisationToken && x.ExpiresOn > DateTime.Now).OrderByDescending(y=>y.Id).First().UserId)
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// Verify that a user has the requested user level for the client in question, taking into account the respective permission sets of the user in relation to the organisation 
        /// under which the client is being administered (clients can theoretically belong to more than one organisation as can users but with varying levels of authority within each organisation): 
        /// System Admins are always authorised
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="clientId"></param>
        /// <param name="userSelectedOrganisationId"></param>
        /// <param name="userLevel"></param>
        /// <returns></returns>
        public bool UserAuthorisedForClient(int userId, int clientId, int userSelectedOrganisationId, UserLevel userLevel)
        {
            if (this.UserHasSystemAdminStatus(userId))
            {
                return true;
            }

            //Verify that the client belongs to the selected organisation
            if (!(atlasDB.ClientOrganisations.Where(x=>x.ClientId == clientId && x.OrganisationId == userSelectedOrganisationId).Count() > 0))
            {
                return false;
            }

            var hasOrganisationUserStatus = this.UserHasOrganisationUserStatus(userId, userSelectedOrganisationId);

            var hasOrganisationAdminStatus = this.UserHasOrganisationAdminStatus(userId, userSelectedOrganisationId);

            switch (userLevel)
            {
                case UserLevel.OrganisationUser:
                    return hasOrganisationUserStatus || hasOrganisationAdminStatus;

                case UserLevel.OrganisationAdministrator:
                    return hasOrganisationAdminStatus;

                    //TODO: cater for trainer-user and client-user scenarios                                                
            }

            return false;
        }

        /// <summary>
        /// Verify that a user has the requested user level for the course in question, taking into account the respective permission sets of the user in relation to the organisation 
        /// under which the course is being administered (courses can theoretically belong to more than one organisation as can users but with varying levels of authority within each organisation): 
        /// System Admins are always authorised
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="courseId"></param>
        /// <param name="userSelectedOrganisationId"></param>
        /// <param name="userLevel"></param>
        /// <returns></returns>
        public bool UserAuthorisedForCourse(int userId, int courseId, int userSelectedOrganisationId, UserLevel userLevel)
        {
            if (this.UserHasSystemAdminStatus(userId))
            {
                return true;
            }

            //Verify that the course belongs to the selected organisation
            if (!(atlasDB.Course.Where(x => x.Id == courseId && x.OrganisationId == userSelectedOrganisationId).Count() > 0))
            {
                return false;
            }

            var hasOrganisationUserStatus = this.UserHasOrganisationUserStatus(userId, userSelectedOrganisationId);

            var hasOrganisationAdminStatus = this.UserHasOrganisationAdminStatus(userId, userSelectedOrganisationId);

            switch (userLevel)
            {
                case UserLevel.OrganisationUser:
                    return hasOrganisationUserStatus || hasOrganisationAdminStatus;

                case UserLevel.OrganisationAdministrator:
                    return hasOrganisationAdminStatus;

                    //TODO: cater for trainer-user and client-user scenarios                                                
            }

            return false;
        }


        /// <summary>
        /// Verify if a user has organisation user status for a particular organisation
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="organisationId"></param>
        /// <returns></returns>
        protected bool UserHasOrganisationUserStatus(int userId, int organisationId)
        {
            return (atlasDB.OrganisationUsers
                           .Include(x => x.User)
                           .Where(x => x.UserId == userId && x.OrganisationId == organisationId)
                           .Count()) > 0;
        }

        /// <summary>
        /// Verify if a user has organisation administrator status for a particular organisation
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="organisationId"></param>
        /// <returns></returns>
        protected bool UserHasOrganisationAdminStatus(int userId, int organisationId)
        {
            return (atlasDB.OrganisationAdminUsers
                           .Include(x => x.User)
                           .Where(x => x.UserId == userId && x.OrganisationId == organisationId)
                           .Count()) > 0;
        }

        /// <summary>
        /// Verify if a user has system administrator status
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        protected bool UserHasSystemAdminStatus(int userId)
        {
            return (atlasDB.SystemAdminUsers
                           .Where(x => x.UserId == userId)
                           .Count()) > 0;
        }
        
        protected string GetIPAddress()
        {
            return GetClientIp();
        }

        protected string GetClientIp(HttpRequestMessage request = null)
        {
            request = request ?? Request;

            if (request.Properties.ContainsKey("MS_HttpContext"))
            {
                return ((HttpContextWrapper)request.Properties["MS_HttpContext"]).Request.UserHostAddress;
            }
            else if (HttpContext.Current != null)
            {
                return HttpContext.Current.Request.UserHostAddress;
            }
            else
            {
                return null;
            }
        }

        private void RecordUserLogin(string loginId, UserLogin userLogin, bool success)
        {
            userLogin.LoginId = loginId;
            userLogin.Success = success;

            try
            {
                atlasDB.UserLogins.Add(userLogin);
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                //Write error details to text log or DB here once error logging has been implemented
                string errorDetails = ex.Message;
            }
        }

        private void AmendUserLoginCounter(string loginCredentials, bool emailAuthentication, bool authenticated)
        {
            User User;

            if (emailAuthentication)
            {
                User = atlasDB.Users.SingleOrDefault(u => u.Email == loginCredentials);
            }
            else
            {
                User = atlasDB.Users.SingleOrDefault(u => u.LoginId == loginCredentials);
            }

            if (User != null)
            {
                if (authenticated)
                {
                    User.FailedLogins = 0;
                }
                else
                {
                    User.FailedLogins++;
                }

                atlasDB.SaveChanges();
            }
        }

        protected CurrentUserJSON GetUserData(CurrentUserJSON userData, User foundUser)
        {
            //Populate basic user data
            userData.userId = foundUser.Id.ToString();
            userData.name = foundUser.Name;
            userData.loginStatus = "login_accepted";

            var menuData = (from data in atlasDB.AdministrationMenuGroupItem
                            .Include("AdministrationMenuGroup")
                            .Include("AdministrationMenuItem")
                            .Include("AdministrationMenuItemUser")
                            .Include("AdministrationMenuUser")
                            where data.AdministrationMenuItem.AdministrationMenuItemUser.Any(c => c.UserId == foundUser.Id)
                            select data
                            ).ToList().OrderBy(z => z.AdministrationMenuGroup.SortNumber).ThenBy(u => u.SortNumber);

            List<AdminMenuGroup> adminGroup = new List<AdminMenuGroup>();
            List<AdminMenuItem> adminMenu = new List<AdminMenuItem>();
            AdminMenuGroup lastMenuGroup = new AdminMenuGroup();

            foreach (var dataItem in menuData)
            {
                //If iteration has moved onto a new Menu Group or this is the first Group...
                if (dataItem.AdminMenuGroupId != int.Parse(lastMenuGroup.Id))
                {
                    if (lastMenuGroup != null)
                    {
                        //Add the menu items to the menu group
                        lastMenuGroup.adminMenuItems = adminMenu.ToArray();
                        adminMenu.Clear();
                        //Add the menu group to the array
                        adminGroup.Add(lastMenuGroup);
                    }
                    //Create a new Menu Group
                    lastMenuGroup = new AdminMenuGroup
                    {
                        Id = dataItem.AdminMenuGroupId.ToString(),
                        Title = dataItem.AdministrationMenuGroup.Title,
                        Description = dataItem.AdministrationMenuGroup.Description,
                    };
                }

                //Add the menu item
                adminMenu.Add(new AdminMenuItem
                {
                    Title = dataItem.AdministrationMenuItem.Title,
                    Description = dataItem.AdministrationMenuItem.Description,
                    Modal = (dataItem.AdministrationMenuItem.Modal ?? true) ? "true" : "false",
                    Disabled = (dataItem.AdministrationMenuItem.Disabled ?? true) ? "true" : "false",
                    Url = dataItem.AdministrationMenuItem.Url,
                    Controller = dataItem.AdministrationMenuItem.Controller,
                    Parameters = dataItem.AdministrationMenuItem.Parameters
                });
            }
            userData.adminMenuGroups = adminGroup.ToArray();
            return userData;
        }

        protected AdminMenuGroup[] GetUserMenuData(int userId, int organisationId)
        {
            var menuData = atlasDBViews.vwAdminMenuItems
                .Where(x => x.UserId == userId && (x.OrganisationId == organisationId || x.SystemsAdmin == "True"))
                .ToList()
                .OrderBy(w => w.MenuGroupSortNumber).ThenBy(y => y.MenuGroupTitle).ThenBy(y => y.MenuGroupItemSortNumber).ThenBy(z => z.MenuItemTitle);
         
            List<AdminMenuGroup> adminGroup = new List<AdminMenuGroup>();
            List<AdminMenuItem> adminMenu = new List<AdminMenuItem>();
            AdminMenuGroup lastMenuGroup = new AdminMenuGroup();

            for (int x = 0; x < menuData.Count(); x++)
            {
                var dataItem = menuData.ElementAt(x);
                //if this is the first menu group encountered, create this
                if (lastMenuGroup.Id == null)
                {
                    //Create a new Menu Group
                    lastMenuGroup = new AdminMenuGroup
                    {
                        Id = dataItem.MenuGroupId.ToString(),
                        Title = dataItem.MenuGroupTitle,
                        Description = dataItem.MenuGroupDescription
                    };

                    //And add the menu item to the admin menu list                    
                    adminMenu.Add(new AdminMenuItem
                    {
                        Title = dataItem.MenuItemTitle,
                        Description = dataItem.MenuItemDescription,
                        Modal = dataItem.MenuItemModal == true ? "true" : "false",
                        Disabled = dataItem.MenuItemDisabled == true ? "true" : "false",
                        Url = dataItem.MenuItemUrl,
                        Controller = dataItem.MenuItemController,
                        Parameters = dataItem.MenuItemParameters,
                        Class = dataItem.MenuItemClass
                    });

                    if (menuData.Count() == 1)
                    {
                        lastMenuGroup.adminMenuItems = adminMenu.ToArray();
                        adminGroup.Add(lastMenuGroup);
                    }
                }
                else
                {
                    //Handle as a normal entry

                    //If we have switched to the next group, push off the results before continuing to process
                    if (dataItem.MenuGroupId != int.Parse(lastMenuGroup.Id))
                    {
                        //Add the menu items to the menu group and clear the admin menu list
                        lastMenuGroup.adminMenuItems = adminMenu.ToArray();
                        adminMenu.Clear();

                        //Add the menu group to the groups array
                        adminGroup.Add(lastMenuGroup);

                        //Create a new Menu Group
                        lastMenuGroup = new AdminMenuGroup
                        {
                            Id = dataItem.MenuGroupId.ToString(),
                            Title = dataItem.MenuGroupTitle,
                            Description = dataItem.MenuGroupDescription
                        };

                        //And add the menu item to the admin menu list                    
                        adminMenu.Add(new AdminMenuItem
                        {
                            Title = dataItem.MenuItemTitle,
                            Description = dataItem.MenuItemDescription,
                            Modal = dataItem.MenuItemModal == true ? "true" : "false",
                            Disabled = dataItem.MenuItemDisabled == true ? "true" : "false",
                            Url = dataItem.MenuItemUrl,
                            Controller = dataItem.MenuItemController,
                            Parameters = dataItem.MenuItemParameters,
                            Class = dataItem.MenuItemClass

                        });

                        //If this is the last dataItem push up the results
                        if (x == menuData.Count() - 1)
                        {
                            lastMenuGroup.adminMenuItems = adminMenu.ToArray();
                            adminGroup.Add(lastMenuGroup);
                        }
                    }
                    else
                    {
                        //Otherwise we are dealing with another menu entry for the same group
                        //Add the menu item to the admin menu list                    
                        adminMenu.Add(new AdminMenuItem
                        {
                            Title = dataItem.MenuItemTitle,
                            Description = dataItem.MenuItemDescription,
                            Modal = dataItem.MenuItemModal == true ? "true" : "false",
                            Disabled = dataItem.MenuItemDisabled == true ? "true" : "false",
                            Url = dataItem.MenuItemUrl,
                            Controller = dataItem.MenuItemController,
                            Parameters = dataItem.MenuItemParameters,
                            Class = dataItem.MenuItemClass

                        });
                    }
                }
            }
            lastMenuGroup.adminMenuItems = adminMenu.ToArray();
            adminGroup.Add(lastMenuGroup);

            return adminGroup.ToArray();
        }

        /// <summary>
        /// Save details of an exception to the SystemTrappedError table
        /// </summary>
        /// <param name="FeatureName">The function/feature name where this originated</param>
        /// <param name="ex"></param>
        protected void LogError(string FeatureName, Exception ex)
        {
            var sb = new StringBuilder();
            var systemTrappedError = new SystemTrappedError();

            try {
                RollBackChangedAtlasDBEntries();

                systemTrappedError.DateRecorded = DateTime.Now;
                systemTrappedError.FeatureName = FeatureName;
                sb.AppendLine(ex.Message);
                sb.AppendLine(ex.StackTrace);
                systemTrappedError.Message = sb.ToString();
                if (!String.IsNullOrEmpty(systemTrappedError.Message)) {
                    if(systemTrappedError.Message.Length > 8000)
                        systemTrappedError.Message = systemTrappedError.Message.Substring(0, 7999);
                }
                atlasDB.SystemTrappedErrors.Add(systemTrappedError);
                atlasDB.SaveChanges();
            } catch(Exception ex2)
            {
                var err = ex2;
                //Do Nothing for this one. By Design. 
                //Undo DB Changes If Necessary. Just in case Error Logging Blocks Database Functions
                switch (atlasDB.Entry(systemTrappedError).State)
                {
                    case EntityState.Modified:
                        atlasDB.Entry(systemTrappedError).CurrentValues.SetValues(atlasDB.Entry(systemTrappedError).OriginalValues);
                        atlasDB.Entry(systemTrappedError).State = EntityState.Unchanged;
                        break;
                    case EntityState.Added:
                        atlasDB.Entry(systemTrappedError).State = EntityState.Detached;
                        break;
                    case EntityState.Deleted:
                        atlasDB.Entry(systemTrappedError).State = EntityState.Unchanged;
                        break;
                }
            }
        }

        /// <summary>
        /// Save details of an exception to the SystemTrappedError table and add a custom message.
        /// </summary>
        /// <param name="FeatureName">The function/feature name where this originated</param>
        /// <param name="ex"></param>
        /// <param name="message">Message giving more information regarding the issue. This will appear first.</param>
        protected void LogError(string FeatureName, Exception ex, string message)
        {
            var sb = new StringBuilder();
            var systemTrappedError = new SystemTrappedError();

            try
            {
                RollBackChangedAtlasDBEntries();

                systemTrappedError.DateRecorded = DateTime.Now;
                systemTrappedError.FeatureName = FeatureName;
                sb.AppendLine(message);
                sb.AppendLine(ex.Message);
                sb.AppendLine(ex.StackTrace);
                systemTrappedError.Message = sb.ToString();
                if (!String.IsNullOrEmpty(systemTrappedError.Message))
                {
                    if (systemTrappedError.Message.Length > 8000)
                        systemTrappedError.Message = systemTrappedError.Message.Substring(0, 7999);
                }
                atlasDB.SystemTrappedErrors.Add(systemTrappedError);
                atlasDB.SaveChanges();
            } catch(Exception ex2)
                {
                    var err = ex2;
                    //Do Nothing for this one. By Design. 
                    //Undo DB Changes If Necessary. Just in case Error Logging Blocks Database Functions
                    switch (atlasDB.Entry(systemTrappedError).State)
                    {
                        case EntityState.Modified:
                            atlasDB.Entry(systemTrappedError).CurrentValues.SetValues(atlasDB.Entry(systemTrappedError).OriginalValues);
                            atlasDB.Entry(systemTrappedError).State = EntityState.Unchanged;
                            break;
                        case EntityState.Added:
                            atlasDB.Entry(systemTrappedError).State = EntityState.Detached;
                            break;
                        case EntityState.Deleted:
                            atlasDB.Entry(systemTrappedError).State = EntityState.Unchanged;
                            break;
                    }
            }
        }

        /// <summary>
        /// Save details of an error to the SystemTrappedError table and add a custom message.
        /// </summary>
        /// <param name="FeatureName">The function/feature name where this originated</param>
        /// <param name="message">Message giving more information regarding the issue</param>
        protected void LogError(string FeatureName, string message)
        {
            var systemTrappedError = new SystemTrappedError();

            try
            {
                RollBackChangedAtlasDBEntries();

                systemTrappedError.DateRecorded = DateTime.Now;
                systemTrappedError.FeatureName = FeatureName;
                systemTrappedError.Message = message;
                if (!String.IsNullOrEmpty(systemTrappedError.Message))
                {
                    if (systemTrappedError.Message.Length > 8000)
                        systemTrappedError.Message = systemTrappedError.Message.Substring(0, 7999);
                }
                atlasDB.SystemTrappedErrors.Add(systemTrappedError);
                atlasDB.SaveChanges();
            }
            catch (Exception ex2)
            {
                var err = ex2;
                //Do Nothing for this one. By Design. 
                //Undo DB Changes If Necessary. Just in case Error Logging Blocks Database Functions
                switch (atlasDB.Entry(systemTrappedError).State)
                {
                    case EntityState.Modified:
                        atlasDB.Entry(systemTrappedError).CurrentValues.SetValues(atlasDB.Entry(systemTrappedError).OriginalValues);
                        atlasDB.Entry(systemTrappedError).State = EntityState.Unchanged;
                        break;
                    case EntityState.Added:
                        atlasDB.Entry(systemTrappedError).State = EntityState.Detached;
                        break;
                    case EntityState.Deleted:
                        atlasDB.Entry(systemTrappedError).State = EntityState.Unchanged;
                        break;
                }
            }
        }

        protected void RollBackChangedAtlasDBEntries()
        {
            //This Method Will Remove Failed/Uncommitted Database Changes
            var changedEntries = atlasDB.ChangeTracker.Entries()
                .Where(x => x.State != EntityState.Unchanged).ToList();

            foreach (var entry in changedEntries)
            {
                switch (entry.State)
                {
                    case EntityState.Modified:
                        entry.CurrentValues.SetValues(entry.OriginalValues);
                        entry.State = EntityState.Unchanged;
                        break;
                    case EntityState.Added:
                        entry.State = EntityState.Detached;
                        break;
                    case EntityState.Deleted:
                        entry.State = EntityState.Unchanged;
                        break;
                }
            }
        }

        /// <summary>
        /// Returns a name for the system's environment, e.g. Test, Dev, UAT...
        /// </summary>
        /// <returns>the name for this environment</returns>
        protected string getSystemName()
        {
            var environmentName = "Dev";
            var systemControl = atlasDB.SystemControls.FirstOrDefault();
            if (systemControl != null)
            {
                environmentName = systemControl.AtlasSystemCode;
            }
            return environmentName;
        }
    }
}


