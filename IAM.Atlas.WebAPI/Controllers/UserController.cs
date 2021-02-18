using IAM.Atlas.Data;
using System.Data.Entity.Validation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Security;
using System.Data.Entity;
using System.Net.Http.Formatting;
using System.ComponentModel.DataAnnotations;
using System.Web.Http.ModelBinding;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class UserController : AtlasBaseController
    {
        // GET api/<controller>
        public IEnumerable<User> Get()
        {
            return atlasDB.Users.ToList();
        }

        // GET api/quickSearch/client/searchText/5
        [Route("api/User/GetUnassignedByOrganisationId/{OrgId}/{SearchText}")]
        [HttpGet]
        public List<User> UserQuickSearch(int OrgId, string SearchText)
        {
            var updatedSearchText = SearchText.ToString().Replace("%20", " ");
            var searchResults = atlasDB.Users
                .Where(
                    usr =>
                        usr.OrganisationUsers.Any(ou => ou.OrganisationId == OrgId) &&
                        usr.LoginId.Contains(updatedSearchText) //&&
                                                                //!usr.Trainers.Any()
                )
                .Take(15)
                .ToList();
            return searchResults;
        }

        // GET api/User/UserAssignedToTrainer/
        [Route("api/User/UserAssignedToTrainer/{UserId}")]
        [HttpGet]
        public bool UserAssignedToTrainer(int UserId)
        {
            bool returnValue = atlasDB.Trainer.Count(t => t.UserId == UserId) > 0;
            return returnValue;
        }

        [Route("api/User/IsAssignedToClient/{UserId}")]
        [HttpGet]
        public bool IsAssignedToClient(int UserId)
        {
            bool assignedToClient = atlasDB.Clients.Count(c => c.UserId == UserId) > 0;
            return assignedToClient;
        }

        // GET api/<controller>/5
        /// <summary>
        /// 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/User/{UserId}")]
        public User Get(int UserId)
        {
            var user = atlasDB.Users
                        .Include(u => u.Gender)
                        .Where(u => u.Id == UserId).FirstOrDefault();
            return user;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/User/GetCurrentUserRoles/{UserId}/{OrganisationId}")]
        public CurrentUserRolesJSON GetCurrentUserRoles(int userId, int organisationId)
        {
            var userRoles = atlasDBViews.vwUserDetails
                        .Where(u => u.UserId == userId && u.OrganisationId == organisationId)
                        .Select(x => new CurrentUserRolesJSON
                        {
                            UserId = x.UserId
                            , IsSystemAdministrator = x.IsSystemAdministrator.HasValue ? (bool)x.IsSystemAdministrator : false
                            , IsAdministrator = x.IsAdministrator.HasValue ? (bool)x.IsAdministrator : false
                            , IsOrgUser = x.IsOrgUser.HasValue ? (bool)x.IsOrgUser : false
                            , IsSupportStaff = x.IsSupportStaff.HasValue ? (bool)x.IsSupportStaff : false
                            , IsClient = x.IsClient.HasValue ? (bool)x.IsClient : false
                            , IsTrainer = x.IsTrainer.HasValue ? (bool)x.IsTrainer : false
                            , OrganisationName = x.Organisation
                            , OrganisationId = x.OrganisationId
                        }

                         ).FirstOrDefault();

            return userRoles;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/User/GetCurrentUserExtendedRoles/{UserId}")]
        public CurrentUserExtendedRolesJSON GetCurrentUserExtendedRoles(int userId)
        {
            //vwDashboardMeter_UserAccess
            var userRoles = atlasDBViews.vwUserExtendedPermissions
                        .Where(u => u.UserId == userId)
                        .Select(x => new CurrentUserExtendedRolesJSON
                        {
                            UserId = x.UserId
                            , CanSeeMeters = false
                            , IsAllowedAccessToTaskPanel = x.ShowTaskList
                            , IsAllowedToCreateTasks = x.AllowTaskCreation
                        }

                         ).FirstOrDefault();
            if (userRoles == null)
            {
                userRoles = new CurrentUserExtendedRolesJSON();
                userRoles.UserId = userId;
                userRoles.CanSeeMeters = false;
                userRoles.IsAllowedAccessToTaskPanel = false;
                userRoles.IsAllowedToCreateTasks = false;
            }

            if (atlasDBViews.vwDashboardMeter_UserAccess.Where(u => u.UserId == userId).Count() > 0)
            {
                userRoles.CanSeeMeters = true;
            }
            return userRoles;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/User/GetActiveUsers/{OrganisationId}/{UserId}")]
        public object GetActiveUsers(int OrganisationId, int UserId)
        {

            var users = atlasDBViews.vwAtlasActiveUsersByUsers
                        .Where(u => u.UserId == UserId)      
                        .Select(x =>
                                new
                                {
                                    Name = x.ActiveUserName,
                                    CreationTime = x.LoggedInTime
                                    
                        })
                        .ToList();

            return users;
        }

        [HttpGet]
        [Route("api/User/GetOrganisationUsers/{OrganisationId}")]
        public List<UserJSON> GetOrganisationUsers(int OrganisationId)
        {
            var organisationUsers = atlasDB.Users
                                            .Include(u => u.OrganisationUsers)
                                            .Where(u => u.OrganisationUsers.Any(ou => ou.OrganisationId == OrganisationId))
                                            .Select(u => new UserJSON {
                                                Id = u.Id,
                                                Name = u.Name,
                                                Email = u.Email,
                                                LoginId = u.LoginId
                                            })
                                            .ToList();
            return organisationUsers;
        }

        // POST api/<controller>
        public object Post([FromBody]FormDataCollection formBody)
        {
            var organisationId = 0;
            var userId = 0;
            var isSystemAdmin = false;
            var userRole = formBody["role"];

            var addedByUserId = StringTools.GetInt("addedByUserId", ref formBody);

            // Try parse the OrganisationId
            if (Int32.TryParse(formBody["organisation[Id]"], out organisationId))
            {
            }
            else
            {
                return "There was an error verifying your organisation. Please retry.";
            }

            // Try parse the UserId
            if (Int32.TryParse(formBody["Id"], out userId))
            {
            }
            else
            {
                return "There was an error verifying the user. Please retry.";
            }

            // try parse the addedByUserId
            if (!Int32.TryParse(formBody["addedByUserId"], out addedByUserId))
            {
                return "There was an error verifying the adding user. Please retry.";
            }

            // Check email field is not empty
            if (string.IsNullOrEmpty(formBody["email"]))
            {
                return "Email is empty, please provide an email address";
            }

            var emailCheck = new EmailAddressAttribute().IsValid(formBody["email"]);

            if (!emailCheck)
            {
                return "Please use a valid email address";

            }

            // Check email field is not empty
            if (string.IsNullOrEmpty(formBody["name"]))
            {
                return "Name is invalid";
            }

            try
            {
                var checkUserBelongsToOrganisation = atlasDB.OrganisationUsers.Any(
                    organisationUser =>
                        organisationUser.UserId == userId &&
                        organisationUser.OrganisationId == organisationId
                );

                SystemAdminController systemAdmin = new SystemAdminController();
                isSystemAdmin = systemAdmin.Get(userId);

                if (!checkUserBelongsToOrganisation && !isSystemAdmin)
                {
                    return "This doesnt seem to be your organisation. Please only use your organisation";
                }

                // do role checks here
                User user = new User();

                user.Password = Membership.GeneratePassword(12, 1);
                user.Name = formBody["name"];
                user.Email = formBody["email"];
                user.Phone = formBody["phone"];
                user.GenderId = 9;
                user.CreationTime = DateTime.Now;
                user.FailedLogins = 0;
                user.Disabled = false;
                user.LoginId = getUserLoginId(user.Name);
                user.DateUpdated = DateTime.Now;
                user.CreatedByUserId = addedByUserId;

                atlasDB.Users.Add(user);

                //atlasDB.SaveChanges();



                if (userRole == "trainer")
                {
                    Trainer trainer = new Trainer();
                    TrainerOrganisation trainerOrganisation = new TrainerOrganisation();

                    trainer.User = user;
                    trainerOrganisation.Trainer = trainer;
                    trainerOrganisation.OrganisationId = organisationId;

                    atlasDB.Trainer.Add(trainer);
                    atlasDB.TrainerOrganisation.Add(trainerOrganisation);
                }

                // OrganisationUser
                if (userRole == "user")
                {
                    OrganisationUser organisationUser = new OrganisationUser();

                    organisationUser.User = user;
                    organisationUser.OrganisationId = organisationId;
                    atlasDB.OrganisationUsers.Add(organisationUser);
                }

                // Client
                //if (userRole == "client")
                //{
                //    Client client = new Client();
                //    ClientOrganisation clientOrganisation = new ClientOrganisation();

                //    client.User_User = user;
                //    client.Locked = false;
                //    client.GenderId = 9;
                //    //client.DateCreated = DateTime.Now;

                //    clientOrganisation.Client = client;
                //    clientOrganisation.OrganisationId = organisationId;
                //    //clientOrganisation.DateAdded = DateTime.Now;

                //    atlasDB.Clients.Add(client);

                //    //atlasDB.SaveChanges();

                //    atlasDB.ClientOrganisations.Add(clientOrganisation);


                //}

                // Organisation Administrator
                if (userRole == "administrator")
                {

                    OrganisationUser organisationUser = new OrganisationUser();
                    OrganisationAdminUser organisationAdminUser = new OrganisationAdminUser();

                    organisationUser.User = user;
                    organisationUser.OrganisationId = organisationId;

                    organisationAdminUser.User = user;
                    organisationAdminUser.OrganisationId = organisationId;

                    atlasDB.OrganisationUsers.Add(organisationUser);
                    atlasDB.OrganisationAdminUsers.Add(organisationAdminUser);
                }

                if (isSystemAdmin == true)
                {
                    if (userRole == "system_administrator")
                    {
                        SystemAdminUser systemAdminUser = new SystemAdminUser();

                        systemAdminUser.User = user;
                        atlasDB.SystemAdminUsers.Add(systemAdminUser);
                    }
                }

                // is this a Referring Authority User?
                int referringAuthorityId = -1;
                if (Int32.TryParse(formBody["referringAuthorityId"], out referringAuthorityId))
                {
                    var referringAuthorityUser = new ReferringAuthorityUser();
                    referringAuthorityUser.DateAdded = DateTime.Now;
                    referringAuthorityUser.ReferringAuthorityId = referringAuthorityId;
                    referringAuthorityUser.AddedByUserId = addedByUserId;
                    user.ReferringAuthorityUsers.Add(referringAuthorityUser);
                }

                atlasDB.SaveChanges();
                return GetUserResult(userRole, user);

            }
            catch (DbEntityValidationException ex)
            {
                return "There was an error saving your details. Please retry.";
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="firstName"></param>
        /// <param name="lastName"></param>
        /// <param name="otherNames"></param>
        /// <returns></returns>
        public string getUserLoginId(string firstName, string lastName, string otherNames)
        {
            // same method as the generate the loginId from the client register controller function
            // var clientRegisterController = new ClientRegisterController();
            // Use the surname and current year and month: strip out any non-alpha characters
            char[] arr = lastName.ToCharArray();

            arr = Array.FindAll<char>(arr, (c => (char.IsLetter(c))));
            string possibleLogin = new string(arr) + DateTime.Now.Year.ToString() + DateTime.Now.Month.ToString("D2");

            // See if this login exists
            if (atlasDB.Users.Where(x => x.LoginId == possibleLogin).Count() > 0)
            {
                //...need to make it a bit more unique
                possibleLogin = (new string(arr)) + (firstName != "" ? firstName[0].ToString() : "") + (otherNames != "" ? otherNames[0].ToString() : "") + (DateTime.Now.Year.ToString()) + (DateTime.Now.Month.ToString("D2"));
                if (atlasDB.Users.Where(x => x.LoginId == possibleLogin).Count() > 0)
                {
                    //...use the DB id's to ensure no duplications
                    LoginNumber loginNumber = new LoginNumber
                    {
                        DateAdded = DateTime.Now,
                        LoginReference = (new string(arr)) + (firstName[0].ToString()) + (otherNames != "" ? otherNames[0].ToString() : "")
                    };
                    atlasDB.LoginNumbers.Add(loginNumber);
                    atlasDB.SaveChanges();

                    //Add the loginNumber Id to the end of the possibleLogin 
                    possibleLogin = possibleLogin + loginNumber.Id.ToString();
                }
            }
            return possibleLogin;
        }

        public string getUserLoginId(string fullName)
        {
            var nameArray = fullName.Split(" ".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
            var firstName = "";
            var otherNames = "";
            var lastName = "";
            var message = "";

            switch (nameArray.Length)
            {
                case 0:
                    message = "Can't generate login: No name supplied.";
                    break;
                case 1:
                    lastName = fullName;
                    break;
                case 2:
                    firstName = nameArray[0];
                    lastName = nameArray[1];
                    break;
                default:    // more than 3 names
                    firstName = nameArray[0];
                    lastName = nameArray[nameArray.Length - 1];
                    for (int i = 1; i < nameArray.Length - 1; i++)  // traverse the middle names
                    {
                        otherNames += nameArray[i];
                        if (i != nameArray.Length - 2) otherNames += " ";
                    }
                    break;
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return getUserLoginId(firstName, lastName, otherNames);
        }

        [Route("api/user/postEntity")]
        [HttpPost]
        [AllowCrossDomainAccess]
        [AuthorizationRequired]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="formBody"></param>
        /// <returns></returns>
        public int PostEntity([FromBody]FormDataCollection formBody)
        {
            var userId = -1;
            var user = formBody.ReadAs<User>();

            var isAdministrator = StringTools.GetBool("IsAdministrator", ref formBody);
            var organisationId = StringTools.GetInt("OrganisationId", ref formBody);

            //var createdByUserId = StringTools.GetInt("createdByUserId", ref formBody);
            var updatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formBody);

            if (user != null)
            {
                if (user.Id > 0) // update the entity
                {
                    // i don't want to update the child entities that were loaded by includes so point them all to null
                    // to avoid having to loop over all of them to set their state as modified or detached

                    user = (User)Classes.EntityTools.NullifyICollections(user);

                    // also have to nullify the Gender child entity:
                    user.Gender = null;
                    user.UpdatedByUserId = updatedByUserId;

                    atlasDB.Users.Attach(user);
                    var entry = atlasDB.Entry(user);
                    entry.State = EntityState.Modified;

                    //if user toggled role we either need to add or remove from the OrganisationAdminUser table
                    var organisationAdminUser = atlasDB.OrganisationAdminUsers.Where(x => x.UserId == user.Id && x.OrganisationId == organisationId).FirstOrDefault();

                    if (organisationAdminUser == null && isAdministrator == true)
                    {
                        organisationAdminUser = new OrganisationAdminUser() { OrganisationId = organisationId, UserId = user.Id };
                        var newEntry = atlasDB.Entry(organisationAdminUser);
                        newEntry.State = EntityState.Added;
                    }
                    else if (organisationAdminUser != null && isAdministrator == false)
                    {
                        var deletedEntry = atlasDB.Entry(organisationAdminUser);
                        deletedEntry.State = EntityState.Deleted;
                    }
                }
                else   // add to db
                {

                    //user.CreatedByUserId = createdByUserId;
                    atlasDB.Users.Add(user);
                }
                atlasDB.SaveChanges();
                userId = user.Id;
            }
            return userId;
        }

        private UserResult GetUserResult(string theRole, User user)
        {
            var userResult = new UserResult();

            userResult.UserId = user.Id;
            userResult.UserRole = theRole;

            // If Client was updated
            if (user.User_Clients.Count != 0)
            {
                userResult.Id = user.User_Clients.FirstOrDefault().Id;
            }

            /// If trainer was updated
            if (user.Trainers.Count != 0)
            {
                userResult.Id = user.Trainers.FirstOrDefault().Id;
            }

            // If Organisation User was updated
            if (user.OrganisationUsers.Count != 0)
            {
                userResult.Id = user.OrganisationUsers.FirstOrDefault().Id;
            }

            // If Organisation Admin User was updated
            if (user.OrganisationAdminUsers.Count != 0)
            {
                userResult.Id = user.OrganisationAdminUsers.FirstOrDefault().Id;
            }

            // If System Admin User was updated
            if (user.SystemAdminUsers.Count != 0)
            {
                userResult.Id = user.SystemAdminUsers.FirstOrDefault().Id;
            }

            return userResult;
        }

        public class UserResult
        {
            public int UserId { get; set; }
            public int Id { get; set; }
            public string UserRole { get; set; }

        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }

        [Route("api/user/GetBlockedUsersByOrganisation/{organisationId}/{userId}")]
        public List<User> GetBlockedUsersByOrganisation(int organisationId, int userId)
        {
            var blockedUsers = new List<User>();
            var systemAdminController = new SystemAdminController();
            bool isAdmin = systemAdminController.Get(userId);
            if (isAdmin)
            {
                blockedUsers = atlasDB.Users
                                .Include(u => u.Trainers)
                                .Where(u => u.Disabled)
                                .Where(u => u.OrganisationUsers.Any(ou => ou.OrganisationId == organisationId))
                                .OrderByDescending(u => u.LastLoginAttempt)
                                .ToList();
            }
            else
            {
                blockedUsers = atlasDB.Users
                                .Include(u => u.SystemAdminUsers)
                                .Include(u => u.Trainers)
                                .Where(u => u.Disabled)
                                .Where(u => u.SystemAdminUsers.ToList().Count() == 0)
                                .Where(u => u.OrganisationUsers.Any(ou => ou.OrganisationId == organisationId))
                                .OrderByDescending(u => u.LastLoginAttempt)
                                .ToList();
            }
            return blockedUsers;
        }

        [Route("api/user/unblockUser/{userId}")]
        [HttpGet]
        public void UnblockUser(int userId)
        {
            var user = atlasDB.Users.Where(u => u.Id == userId).FirstOrDefault();
            if (user != null)
            {
                user.Disabled = false;
                user.FailedLogins = 0;
                atlasDB.Users.Attach(user);
                var entry = atlasDB.Entry(user);
                entry.State = System.Data.Entity.EntityState.Modified;
                atlasDB.SaveChanges();
            }
        }

        [Route("api/user/UnblockAllUsersInOrganisation/{organisationId}/{userId}")]
        [HttpGet]
        public void UnblockAllUsersInOrganisation(int organisationId, int userId)
        {
            var users = GetBlockedUsersByOrganisation(organisationId, userId);

            users
                .ForEach(u =>
                {
                    u.Disabled = false;
                    u.FailedLogins = 0;
                });
            atlasDB.SaveChanges();
        }

        /// <summary>
        /// Return a filtered list of users: logic departs from this if no options or disabled only is selected, in which case all, 
        /// or all including disabled (with System Administrators if logged in as a System Admin) are returned
        /// </summary>
        /// <param name="organisationId"></param>
        /// <param name="userId"></param>
        /// <param name="administrators"></param>
        /// <param name="trainers"></param>
        /// <param name="systemAdministrators"></param>
        /// <param name="clients"></param>
        /// <param name="systemUsers"></param>
        /// <param name="disabled"></param>
        /// <returns></returns>
        [Route("api/user/GetFilteredUsersByOrganisation/{organisationId}/{userId}/{administrators}/{trainers}/{systemAdministrators}/{clients}/{systemUsers}/{disabled}")]
        public object GetFilteredUsersByOrganisation(int organisationId, int userId, bool administrators, bool trainers, bool systemAdministrators, bool clients, bool systemUsers, bool disabled)
        {
            //Check if the user is an administrator
            var isAdmin = atlasDB.SystemAdminUsers.Count(u => u.UserId == userId) > 0;

            var filteredUsers = atlasDBViews.vwUserDetails
                                .Where(u =>
                                    ((u.IsSystemAdministrator == true && systemAdministrators == true)
                                      || (u.IsAdministrator == true && administrators == true && u.OrganisationId == organisationId)
                                      || (u.IsOrgUser == true && systemUsers == true && u.OrganisationId == organisationId)
                                      || (u.IsTrainer == true && trainers == true && u.OrganisationId == organisationId)
                                      || (u.IsClient == true && clients == true && u.OrganisationId == organisationId))
                                      && ((u.Disabled == false && disabled == false) || disabled == true)
                                )
                                .ToList()
                                .Select(user =>
                                        new
                                        {
                                            Id = user.UserId,
                                            UserType =
                                            (
                                                user.IsSystemAdministrator == true ? "Atlas System Administrator" :
                                                user.IsAdministrator == true ? "Administrator" :
                                                user.IsClient == true ? "Client" :
                                                user.IsTrainer == true ? "Trainer" :
                                                user.IsOrgUser == true ? "User" : ""
                                            ),
                                            Name = user.UserName,
                                            LoginId = user.LoginId,
                                            Email = user.Email,
                                            LastLogin = user.LastSuccessfulLogin.ToString(),
                                            Disabled = user.Disabled ? "Yes" : "No"
                                        })
                                    .OrderBy(f => f.Name);

            return filteredUsers;
        }


        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/GetSystemSupportUsers/{organisationId}")]
        public List<User> GetSystemSupportUsers(int organisationId)
        {
            List<User> users = null;
            users = atlasDB.Users
                            .Include(u => u.SystemSupportUsers)
                            .Where(u => u.SystemSupportUsers.Any(ssu => ssu.OrganisationId == organisationId))
                            .ToList();
            return users;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/GetNonSystemSupportUsers/{organisationId}")]
        public List<User> GetNonSystemSupportUsers(int organisationId)
        {
            List<User> users = null;
            users = atlasDB.Users
                            .Include(u => u.SystemSupportUsers)
                            .Include(u => u.OrganisationUsers)
                            .Where(u => !u.SystemSupportUsers.Any(ssu => ssu.OrganisationId == organisationId) &&
                                        u.OrganisationUsers.Any(ou => ou.OrganisationId == organisationId)
                            ).ToList();
            return users;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/makeSupportUser/{userId}/{organisationId}/{addedByUserId}")]
        public bool makeSupportUser(int userId, int organisationId, int addedByUserId)
        {
            bool made = false;
            // does the user have permission to grant this permission?
            var addingUser = atlasDB.Users
                                    .Include(u => u.SystemAdminUsers)
                                    .Include(u => u.OrganisationAdminUsers)
                                    .Where(u => u.Id == addedByUserId)
                                    .FirstOrDefault();
            if (addingUser != null)
            {
                if (addingUser.SystemAdminUsers.Count > 0 ||
                   addingUser.OrganisationAdminUsers.Where(oau => oau.OrganisationId == organisationId).FirstOrDefault() != null)
                {
                    var systemSupportUser = atlasDB.SystemSupportUsers.Where(ssu => ssu.UserId == userId).FirstOrDefault();
                    if (systemSupportUser == null)   // doesn't already exist
                    {
                        systemSupportUser = new SystemSupportUser();
                        systemSupportUser.UserId = userId;
                        systemSupportUser.OrganisationId = organisationId;
                        systemSupportUser.AddedByUserId = addedByUserId;
                        systemSupportUser.DateAdded = DateTime.Now;

                        atlasDB.SystemSupportUsers.Add(systemSupportUser);
                        atlasDB.SaveChanges();
                        made = true;
                    }
                }
            }
            return made;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/unmakeSupportUser/{userId}/{organisationId}/{adminUserId}")]
        public bool unmakeSupportUser(int userId, int organisationId, int adminUserId)
        {

            bool revoked = false;
            // does the user have permission to remove this permission?
            var adminUser = atlasDB.Users
                                    .Include(u => u.SystemAdminUsers)
                                    .Include(u => u.OrganisationAdminUsers)
                                    .Where(u => u.Id == adminUserId)
                                    .FirstOrDefault();
            if (adminUser != null)
            {
                if (adminUser.SystemAdminUsers.Count > 0 ||
                   adminUser.OrganisationAdminUsers.Where(oau => oau.OrganisationId == organisationId).FirstOrDefault() != null)
                {
                    var systemSupportUser = atlasDB.SystemSupportUsers.Where(ssu => ssu.UserId == userId && ssu.OrganisationId == organisationId).FirstOrDefault();
                    if (systemSupportUser != null)
                    {
                        var entry = atlasDB.Entry(systemSupportUser);
                        entry.State = EntityState.Deleted;
                        atlasDB.SaveChanges();
                        revoked = true;
                    }
                }
            }
            return revoked;
        }


        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/GetSystemAdminSupportUsers")]
        public object GetSystemAdminSupportUsers()
        {

            var users = atlasDBViews.vwSystemAdminsProvidingAtlasSupports.ToList();
            return users;

        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/GetNonSystemAdminSupportUsers")]
        public object GetNonSystemAdminSupportUsers()
        {

            var users = atlasDBViews.vwSystemAdminsNotProvidingAtlasSupports.ToList();
            return users;

        }



        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/makeAdminSupportUser/{userId}/{addedByUserId}")]
        public bool makeAdminSupportUser(int userId, int addedByUserId)
        {
            bool made = false;
            // does the user have permission to remove this permission?
            var adminUser = atlasDB.SystemAdminUsers
                                    .Where(sau => sau.UserId == addedByUserId)
                                    .FirstOrDefault();
            if (adminUser != null)
            {

                SystemAdminUser systemAdminUser = atlasDB.SystemAdminUsers
                                                .Where(sau => sau.UserId == userId)
                                                .FirstOrDefault();

                if (systemAdminUser != null)
                {

                    atlasDB.SystemAdminUsers.Attach(systemAdminUser);
                    var entry = atlasDB.Entry(systemAdminUser);
                    systemAdminUser.CurrentlyProvidingSupport = true;
                    atlasDB.Entry(systemAdminUser).Property("CurrentlyProvidingSupport").IsModified = true;

                    try
                    {
                        atlasDB.SaveChanges();
                        made = true;
                    }
                    catch (DbEntityValidationException ex)
                    {
                        throw new HttpResponseException(
                            new HttpResponseMessage(HttpStatusCode.InternalServerError)
                            {
                                Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                                ReasonPhrase = "We can't process your request."
                            }
                        );
                    }


                }
            }

            return made;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/unmakeAdminSupportUser/{userId}/{adminUserId}")]
        public bool unmakeAdminSupportUser(int userId, int adminUserId)
        {
            bool revoked = false;
            // does the user have permission to remove this permission?
            var adminUser = atlasDB.SystemAdminUsers
                                    .Where(sau => sau.UserId == adminUserId)
                                    .FirstOrDefault();
            if (adminUser != null)
            {

                var systemAdminUserCount = atlasDB.SystemAdminUsers
                                                 .Where(saus => saus.CurrentlyProvidingSupport == true).Count();

                // only remove if there is more then 1 admin currently providing support
                if (systemAdminUserCount > 1 )
                {

                    SystemAdminUser systemAdminUser = atlasDB.SystemAdminUsers
                                                .Where(sau => sau.UserId == userId)
                                                .FirstOrDefault();

               
                    if (systemAdminUser != null)
                    {

                        atlasDB.SystemAdminUsers.Attach(systemAdminUser);
                        var entry = atlasDB.Entry(systemAdminUser);
                        systemAdminUser.CurrentlyProvidingSupport = false;
                        atlasDB.Entry(systemAdminUser).Property("CurrentlyProvidingSupport").IsModified = true;

                        try
                        {
                            atlasDB.SaveChanges();
                            revoked = true;
                        }
                        catch (DbEntityValidationException ex)
                        {
                            throw new HttpResponseException(
                                new HttpResponseMessage(HttpStatusCode.InternalServerError)
                                {
                                    Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                                    ReasonPhrase = "We can't process your request."
                                }
                            );
                        }
                    }

                }
            }

            return revoked;
        }

        

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/GetAvailableNetcallAgentsByOrganisation/{OrganisationId}")]
        public List<User> GetAvailableNetcallAgentsByOrganisation(int OrganisationId)
        {
            List<User> users = null;
            users = atlasDB.Users
                            .Include(u => u.OrganisationUsers)
                            .Include(u => u.NetcallAgents)
                            .Where(u => u.OrganisationUsers.Any(ou => ou.OrganisationId == OrganisationId) &&
                                    !u.NetcallAgents.Any())
                            .ToList();
            return users;

            //OrganisationUsers
            //            .Include(u => u.User)
            //            .Include(u => u.User.NetcallAgents)
            //                .Where(u => u.OrganisationId == OrganisationId && !u.User.NetcallAgents.Any())
            //                .Select(u => new
            //                {
            //                    Id = u.User.Id,
            //                    Name = u.User.Name
            //                })
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/GetNetcallAgentsByOrganisation/{OrganisationId}")]
        public object GetNetcallAgentsByOrganisation(int OrganisationId)
        {

            return atlasDB.NetcallAgents
               .Include(u => u.User)
               .Include(u => u.User.OrganisationUsers)
                                       .Where(u => u.User.OrganisationUsers.Any(x => x.OrganisationId == OrganisationId))
                               .Select(
                                   na =>
                                           new
                                           {
                                               Id = na.Id,
                                               Name = na.User.Name,
                                               UserId = na.UserId,
                                               LoginId = na.User.LoginId,
                                               DefaultCallingNumber = na.DefaultCallingNumber,
                                               Disabled = na.Disabled
                                           }).ToList();


        }

        [AuthorizationRequired]
        [Route("api/user/SaveNetcallAgentCallingNumber")]
        [HttpPost]
        public int SaveNetcallAgentCallingNumber([FromBody]FormDataCollection formBody)
        {

            var netcallAgent = formBody.ReadAs<NetcallAgent>();

            netcallAgent.DateUpdated = DateTime.Now;



            if (netcallAgent.Id > 0) // update
            {
                atlasDB.NetcallAgents.Attach(netcallAgent);
                var entry = atlasDB.Entry(netcallAgent);
                entry.State = System.Data.Entity.EntityState.Modified;
            }
            else // add
            {
                atlasDB.NetcallAgents.Add(netcallAgent);

            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return netcallAgent.Id;

        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/user/IsMysteryShopperAdministrator/{userId}")]
        public bool IsMysteryShopperAdministrator(int userId)
        {
            bool isMysteryShopperAdministrator = false;

            var mysteryShopperAdministrators = atlasDB.MysteryShopperAdministrators
                                                        .Where(msa => msa.UserId == userId)
                                                        .FirstOrDefault();
            if (mysteryShopperAdministrators != null)
            {
                isMysteryShopperAdministrator = true;    
            }

            return isMysteryShopperAdministrator;
        }

    }
}