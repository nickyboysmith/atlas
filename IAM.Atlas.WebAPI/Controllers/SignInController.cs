using IAM.Atlas.Data;
using IAM.Atlas.Tools;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web;
using IAM.Atlas.WebAPI.Classes;
using IAM.DORS.Webservice;
using System.Configuration;
using IAM.DORS.Webservice.Models;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SignInController : AtlasBaseController
    {

        private readonly TokenServices _tokenServices = new TokenServices();

        public TokenServices tokenServices
        {
            get
            {
                return _tokenServices;
            }
        }

        [Route("api/signin/organisation")]
        [HttpPost]
        public object LoginOrganisationUser([FromBody] FormDataCollection formBody)
        {
            var username = formBody["user"];
            var password = formBody["password"];
            var userId = this.ValidateUserLoginCredentials(username, password);

            if(userId == 0)
            {
                LogUserLogin(username, false);
                return new object { };
            }

            //If user account is locked, verify this to client
            if (this.UserAcountLocked(username))
            {
                return "accountlocked";
            }

            var cookieEncryption = StringCipher.Encrypt("organisationUser", StringCipher.cookieOnlyPassPhrase);
            var adminUser = atlasDB.SystemAdminUsers.Where(systemAdminUser => systemAdminUser.UserId == userId).Count() > 0;

            var EmptyList = Enumerable.Empty<object>().Select(x => new { Id = 0, Name = "", Display = "" }).ToList();

            if (adminUser)
            {
                var allOrganisationIds = atlasDBViews.vwOrganisationDetails
                                                    .Where(x => x.IsManagedOrganisation == false)
                                                    .Select(o => new
                                                    {
                                                        Id = o.OrganisationId,
                                                        Name = o.OrganisationName,
                                                        Display = o.OrganisationDisplayName
                                                    }).ToList();

                //checkOrgUser.OrganisationIds = allOrganisationIds;
                
                var checkOrgUser = atlasDBViews.vwUserDetails
                                            .Where(u => u.UserId == userId)
                                            .ToList()
                                            .Select(userDetail => new {
                                                UserId = userId,
                                                Name = userDetail.UserName,
                                                PasswordChangeRequired = userDetail.PasswordChangeRequired,
                                                ReferringAuthorityName = userDetail.ReferringAuthorityName == null ? "" : userDetail.ReferringAuthorityName,
                                                IsReferringAuthority = userDetail.IsReferringAuthorityStaff,
                                                IsSystemAdmin = userDetail.IsSystemAdministrator,
                                                IsSystemAdminSupport = userDetail.IsSystemAdminSupport,
                                                IsOrganisationAdmin = userDetail.IsAdministrator,
                                                OrganisationIds = allOrganisationIds,
                                                SystemIsReadOnly = userDetail.SystemIsReadOnly,
                                                cookie = cookieEncryption
                                            }).ToList();

                // Remove all previous tokens
                tokenServices.DeleteTokenByUserId(userId);

                // Create a new set of tokens
                var responseHeaders = GetAuthToken(userId);

                // Add The token headers to the login request
                HttpContext.Current.Response.Headers.Add("X-Auth-Token", responseHeaders.Token);
                HttpContext.Current.Response.Headers.Add("TokenExpiry", responseHeaders.TokenExpiry);

                // Log the login request
                LogUserLogin(username, true);
                return checkOrgUser;
            }
            else
            {
                var allOrganisationIds = atlasDBViews.vwUserOrganisations
                                                    .Where(x => x.UserId == userId && x.OrganisationActive == true)
                                                    .Select(o => new
                                                    {
                                                        Id = o.OrganisationId,
                                                        Name = o.OrganisationName,
                                                        Display = o.OrganisationName
                                                    }).ToList();
                
                var checkOrgUser = atlasDBViews.vwUserDetails
                                            .Where(u => u.UserId == userId)
                                            .ToList()
                                            .Select(userDetail => new {
                                                UserId = userId,
                                                Name = userDetail.UserName,
                                                PasswordChangeRequired = userDetail.PasswordChangeRequired,
                                                ReferringAuthorityName = userDetail.ReferringAuthorityName == null ? "" : userDetail.ReferringAuthorityName,
                                                IsReferringAuthority = userDetail.IsReferringAuthorityStaff,
                                                IsSystemAdmin = userDetail.IsSystemAdministrator,
                                                IsSystemAdminSupport = userDetail.IsSystemAdminSupport,
                                                IsOrganisationAdmin = userDetail.IsAdministrator,
                                                OrganisationIds = allOrganisationIds,
                                                SystemIsReadOnly = userDetail.SystemIsReadOnly,
                                                cookie = cookieEncryption
                                            }).ToList();

                // Remove all previous tokens
                tokenServices.DeleteTokenByUserId(userId);

                // Create a new set of tokens
                var responseHeaders = GetAuthToken(userId);

                // Add The token headers to the login request
                HttpContext.Current.Response.Headers.Add("X-Auth-Token", responseHeaders.Token);
                HttpContext.Current.Response.Headers.Add("TokenExpiry", responseHeaders.TokenExpiry);

                // Log the login request
                LogUserLogin(username, true);
                return checkOrgUser;
            }

        }

        [Route("api/signin/trainer")]
        [HttpPost]
        public object LoginTrainer([FromBody] FormDataCollection formBody)
        {

            var username = formBody["user"];
            var password = formBody["password"];

            var userId = this.ValidateUserLoginCredentials(username, password);

            if (userId == 0)
            {
                LogUserLogin(username, false);
                return new object { };
            }

            //If user account is locked, verify this to client
            if (this.UserAcountLocked(username))
            {
                return "accountlocked";
            }

            var cookieEncryption = StringCipher.Encrypt("trainerUser", StringCipher.cookieOnlyPassPhrase);

            var adminUser = atlasDB.SystemAdminUsers.Where(systemAdminUser => systemAdminUser.UserId == userId).Count() > 0;

            if (adminUser)
            {
                var allOrganisationIds = atlasDB.Organisations
                        .Include("OrganisationManagements")
                        .Include("OrganisationDisplay")
                        .Where(x => x.OrganisationManagements.Count() == 0)
                        .Select(organisation => new
                        {
                            Id = (int?)organisation.Id,
                            Name = organisation.Name,
                            Display = organisation.OrganisationDisplay.Select(display => new
                            {
                                Name = display.DisplayName
                            })
                        });


                var checkTrainerUser = atlasDB.Trainer
                .Include("User")
                .Include("TrainerOrganisation")
                .Include("TrainerSettings")
                .Where(
                    theTrainer =>
                        theTrainer.Locked == false &&
                        theTrainer.User.Disabled == false &&
                        theTrainer.User.Id == userId
                )
                .Select(theTrainer => new
                {
                    Name = theTrainer.DisplayName,
                    TrainerId = theTrainer.Id,
                    UserId = theTrainer.User.Id,
                    OrganisationIds = allOrganisationIds,
                    PasswordChangeRequired = theTrainer.User.PasswordChangeRequired,
                    TrainerSettings = theTrainer.TrainerSettings.Select(settings => new
                    {
                        ProfileEditing = settings.ProfileEditing,
                        CourseTypeEditing = settings.CourseTypeEditing

                    }),
                    cookie = cookieEncryption
                })
                .ToList();

                if (checkTrainerUser.Count == 0)
                {
                    LogUserLogin(username, false);
                    return new object { };
                }


                // Remove all previous tokens
                tokenServices.DeleteTokenByUserId(checkTrainerUser.FirstOrDefault().UserId);

                // Create a new set of tokens
                var responseHeaders = GetAuthToken(checkTrainerUser.FirstOrDefault().UserId);

                // Add The token headers to the login request
                HttpContext.Current.Response.Headers.Add("X-Auth-Token", responseHeaders.Token);
                HttpContext.Current.Response.Headers.Add("TokenExpiry", responseHeaders.TokenExpiry);

                LogUserLogin(username, true);
                return checkTrainerUser;
            }
            else
            {
                var checkTrainerUser = atlasDB.Trainer
                .Include("User")
                .Include("TrainerOrganisation")
                .Include("TrainerSettings")
                .Where(
                    theTrainer =>
                        theTrainer.Locked == false &&
                        theTrainer.User.Disabled == false &&
                        theTrainer.User.Id == userId
                )
                .Select(theTrainer => new
                {
                    Name = theTrainer.DisplayName,
                    TrainerId = theTrainer.Id,
                    UserId = theTrainer.User.Id,
                    PasswordChangeRequired = theTrainer.User.PasswordChangeRequired,
                    OrganisationIds =
                    
                    theTrainer.TrainerOrganisation.Select(organisation => new
                    {
                        Id = organisation.OrganisationId,
                        Name = organisation.Organisation.Name,
                        Display = organisation.Organisation.OrganisationDisplay.Select(display => new
                        {
                            Name = display.DisplayName,
                            Logo = display.ImageFilePath,
                            ShowLogo = display.ShowLogo
                        })

                    }),
                    TrainerSettings = theTrainer.TrainerSettings.Select(settings => new
                    {
                        ProfileEditing = settings.ProfileEditing,
                        CourseTypeEditing = settings.CourseTypeEditing

                    }),
                    cookie = cookieEncryption
                })
                .ToList();

                if (checkTrainerUser.Count == 0)
                {
                    LogUserLogin(username, false);
                    return new object { };
                }


                // Remove all previous tokens
                tokenServices.DeleteTokenByUserId(checkTrainerUser.FirstOrDefault().UserId);

                // Create a new set of tokens
                var responseHeaders = GetAuthToken(checkTrainerUser.FirstOrDefault().UserId);

                // Add The token headers to the login request
                HttpContext.Current.Response.Headers.Add("X-Auth-Token", responseHeaders.Token);
                HttpContext.Current.Response.Headers.Add("TokenExpiry", responseHeaders.TokenExpiry);

                LogUserLogin(username, true);
                return checkTrainerUser;
            }

        }

        [Route("api/signin/client")]
        [HttpPost]
        public object LoginClient([FromBody] FormDataCollection formBody)
        {

            var username = formBody["user"];
            var password = formBody["password"];

            var userId = this.ValidateUserLoginCredentials(username, password);

            if (userId == 0)
            {
                LogUserLogin(username, false);
                return new object { };
            }

            //If user account is locked, verify this to client
            if(this.UserAcountLocked(username))
            {
                return "accountlocked";
            }
            
            var cookieEncryption = StringCipher.Encrypt("clientUser", StringCipher.cookieOnlyPassPhrase);

            var checkClientUser = atlasDB.Clients
                .Include("User_User")
                .Include("User_CreatedByUser")
                .Include("User_LockedByUser")
                .Include("User_UpdatedByUser")
                .Include("ClientOrganisations")
                .Where(
                    theClient =>
                        theClient.User_User.Disabled == false &&
                        theClient.User_User.Id == userId
                )
                .Select(
                    theClient => new
                    {
                        Name = theClient.DisplayName,
                        UserId = theClient.User_User.Id,
                        ClientId = theClient.Id,
                        passwordChanegRequired = theClient.User_User.PasswordChangeRequired,
                        OrganisationIds = theClient.ClientOrganisations
                        .Select(
                            organisation => new
                            {
                                Id = organisation.OrganisationId,
                                Name = organisation.Organisation.Name,
                                DateAdded = organisation.DateAdded,
                                // AppName = organisation.Organisation.OrganisationSelfConfigurations.FirstOrDefault().ClientApplicationDescription
                                AppName = "Test"
                            }
                        ).OrderByDescending(
                            organisation => organisation.DateAdded
                        ).ToList().FirstOrDefault(),
                        cookie = cookieEncryption
                    }
                )
                .ToList();

            if (checkClientUser.Count == 0)
            {
                LogUserLogin(username, false);
                return new object { };
            }


            // Remove all previous tokens
            tokenServices.DeleteTokenByUserId(checkClientUser.FirstOrDefault().UserId);

            // Create a new set of tokens
            var responseHeaders = GetAuthToken(checkClientUser.FirstOrDefault().UserId);

            // Add The token headers to the login request
            HttpContext.Current.Response.Headers.Add("X-Auth-Token", responseHeaders.Token);
            HttpContext.Current.Response.Headers.Add("TokenExpiry", responseHeaders.TokenExpiry);

            LogUserLogin(username, true);

            return checkClientUser;
        }

        private bool UserAcountLocked(string username)
        {
           if(atlasDB.Users.Any(x=>x.LoginId == username && x.Disabled == true))
                {
                return true;
            }
           else
            {
                return false;
            }
        }

        [Route("api/signin/checkclientlicence")]
        [HttpPost]
        public object CheckClientLicence([FromBody] FormDataCollection formBody)
        {
            //Extract licence number and organisation Id
            var formData = formBody;
            var licenceNumber = StringTools.GetString("licenceNumber", ref formData);
            var organisationId = StringTools.GetInt("organisationId", ref formData);

            var dorsWebServiceInterfaceController = new DORSWebServiceInterfaceController();
            List<ClientStatus> clientStatuses = dorsWebServiceInterfaceController
                    .GetClientStatus(licenceNumber)
                    .FindAll( delegate(ClientStatus clientStatus) { return clientStatus.AttendanceStatusId == (int)Interface.DORSAttendanceStates.BookingPending; });

            DORSLookupResult dorsLookupResult = new DORSLookupResult(); ;

            if (licenceNumber.Length > 4)
            {
                dorsLookupResult.checkResult = 0;
                dorsLookupResult.EligibleCourseSchemes = clientStatuses;
            }

            if (licenceNumber.Length > 4 && (dorsLookupResult.EligibleCourseSchemes == null || dorsLookupResult.EligibleCourseSchemes.Count == 0))
            { 
                //Check if the client exists on DB: if so inform them that they need to log in
                if (this.UserRecordAlreadyExists(licenceNumber, organisationId))//Check if they are already on the system
                {
                    dorsLookupResult.checkResult = 1;
                }
                else //They are not on the system, so display a list of organisation contact details
                {
                    dorsLookupResult.checkResult = 2;
                }
            }
            return dorsLookupResult;
        }

        [Route("api/signin/recordBookingAttempt/{licenceNumber}")]
        [HttpPost]
        public object RecordBookingAttempt(string licenceNumber)
        {
            try
            {
                var sessionDetails = HttpContext.Current.Request.Browser;
                var browser = sessionDetails.Browser + " " + sessionDetails.MajorVersion;
                var ipAddress = GetIPAddress();
                var userAgent = HttpContext.Current.Request.UserAgent;
                //var operatingSystem = sessionDetails.Platform;

                var machineName = "";
                try
                {
                    machineName = HttpContext.Current.Server.MachineName;
                }
                catch (Exception ex) { }
                var operatingSystem = GetClientOS(userAgent, sessionDetails.Platform);

                if (machineName.Length > 0)
                {
                    ipAddress = ipAddress + " (" + machineName + ")";
                }
                atlasDB.uspRecordBookingAttempt(licenceNumber, browser, operatingSystem, ipAddress);

                return true;
            } catch (Exception ex)
            {
                return false;
            }
        }

        private static string GetClientOS(string ua, string platform)
        {

            if (ua.Contains("Android"))
                return string.Format("Android {0}", GetMobileVersion(ua, "Android"));

            if (ua.Contains("iPad"))
                return string.Format("iPad OS {0}", GetMobileVersion(ua, "OS"));

            if (ua.Contains("iPhone"))
                return string.Format("iPhone OS {0}", GetMobileVersion(ua, "OS"));

            if (ua.Contains("Linux") && ua.Contains("KFAPWI"))
                return "Kindle Fire";

            if (ua.Contains("RIM Tablet") || (ua.Contains("BB") && ua.Contains("Mobile")))
                return "Black Berry";

            if (ua.Contains("Windows Phone"))
                return string.Format("Windows Phone {0}", GetMobileVersion(ua, "Windows Phone"));

            if (ua.Contains("Mac OS"))
                return "Mac OS";

            if (ua.Contains("Windows NT 5.1") || ua.Contains("Windows NT 5.2"))
                return "Windows XP";

            if (ua.Contains("Windows NT 6.0"))
                return "Windows Vista";

            if (ua.Contains("Windows NT 6.1"))
                return "Windows 7";

            if (ua.Contains("Windows NT 6.2"))
                return "Windows 8";

            if (ua.Contains("Windows NT 6.3"))
                return "Windows 8.1";

            if (ua.Contains("Windows NT 10"))
                return "Windows 10";

            return platform + (ua.Contains("Mobile") ? " Mobile " : "");
        }

        private static string GetMobileVersion(string userAgent, string device)
        {
            var temp = userAgent.Substring(userAgent.IndexOf(device, StringComparison.Ordinal) + device.Length).TrimStart();
            var version = string.Empty;

            foreach (var character in temp)
            {
                var validCharacter = false;
                int test = 0;

                if (int.TryParse(character.ToString(), out test))
                {
                    version += character;
                    validCharacter = true;
                }

                if (character == '.' || character == '_')
                {
                    version += '.';
                    validCharacter = true;
                }

                if (validCharacter == false)
                    break;
            }

            return version;
        }

        /// <summary>
        /// Check if a client has previously registered on the system: if a specific organisation id is
        /// passed in then limit the search to this organisation only, unless the organisation id is 0 
        /// in which case check across all organisations
        /// </summary>
        /// <param name="licence"></param>
        /// <param name="organisationId"></param>
        /// <returns></returns>
        private bool UserRecordAlreadyExists(string licence, int organisationId)
        {
            return atlasDB.Clients
                 .Include("ClientLicences")
                 .Include("ClientOrganisation")
                 .Where(cl => cl.ClientLicences.Any(x => x.LicenceNumber.ToUpper() == licence.ToUpper())
                 && (organisationId == 0 || cl.ClientOrganisations.Any(y => y.OrganisationId == organisationId)))
                 .Count() > 0;
        }

        public string LogUserLogin(string username, bool loginResult)
        {
            var theBrowser = HttpContext.Current.Request.Browser;
            var status = "";

            try
            {
                UserLogin userLogin = new UserLogin();
                userLogin.Ip = GetIPAddress();
                userLogin.Browser = theBrowser.Browser + " " + theBrowser.MajorVersion;
                userLogin.Os = theBrowser.Platform;
                userLogin.LoginId = username;
                userLogin.Success = loginResult;
                userLogin.DateCreated = DateTime.Now;

                atlasDB.UserLogins.Add(userLogin);
                atlasDB.SaveChanges();

                status = "Successfully recorded";

            }
            catch (DbEntityValidationException ex)
            {
                status = "Problem recording";
            }

            return status;
        }

        //// POST api/<controller>
        //public CurrentUserJSON Post([FromBody] FormDataCollection formBody)   // this type passes the JSON data to this webapi controller
        //{
        //    CurrentUserJSON userResult = new CurrentUserJSON();

        //    //Extract the username/email address and password
        //    string usernameText = formBody.Get("userName") != null ? formBody.Get("userName") : "";
        //    string password = formBody.Get("password") != null ? formBody.Get("password") : "";

        //    UserLogin userLogin = new UserLogin
        //    {
        //        Browser = formBody.Get("currentBrowser") != null ? formBody.Get("currentBrowser") : "",
        //        Os = formBody.Get("currentOS") != null ? formBody.Get("currentOS") : "",
        //        Ip = GetIPAddress()
        //    };
        //    int loginResult = 0;

        //    //Check if they are valid
        //    if (this.IsValidEmail(usernameText))
        //    {
        //        loginResult = this.AuthenticateUserCredentials(usernameText, "", password, true, userLogin, out userResult);
        //    }
        //    else
        //    {
        //        loginResult = this.AuthenticateUserCredentials("", usernameText, password, false, userLogin, out userResult);
        //    }
        //    return userResult;
        //}


        /// <summary>
        /// Private function to check an Admin/Trainer/User login
        /// </summary>
        /// <param name="id"></param>
        /// <param name="currentPass"></param>
        /// <returns> A Positive non-zero User Id if credentials match, or zero if they don't</returns>
        private int ValidateUserLoginCredentials(string loginId, string currentPass)
        {
            try
            {

                int userId = -1;
                bool validCredentials = false;

                System.Data.Entity.Core.Objects.ObjectParameter objUserId = new System.Data.Entity.Core.Objects.ObjectParameter("userId", typeof(int));
                System.Data.Entity.Core.Objects.ObjectParameter objValidCredentials = new System.Data.Entity.Core.Objects.ObjectParameter("ValidCredentials", typeof(bool));
                atlasDB.uspValidateLogin(loginId, currentPass, objUserId, objValidCredentials);

                userId = (int)objUserId.Value;
                validCredentials = (bool)objValidCredentials.Value;

                if (validCredentials == true)
                {
                    return userId;
                }
                else
                {
                    return 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        public TokenResponse GetAuthToken(int userId)
        {
            var token = tokenServices.GenerateToken(userId);
            return new TokenResponse
            {
                Token = token.AuthToken,
                TokenExpiry = tokenServices.tokenExpiry.ToString()
            };
        }

        public class DORSLookupResult
        {
            public int checkResult { get; set; }
            public List<ClientStatus> EligibleCourseSchemes { get; set; }
        }

        //public class EligibleCourse
        //{
        //    public int DoId { get; set; }
        //    public string CourseType { get; set; }
        //    public string ProviderName { get; set; }
        //}

        public class TokenResponse
        {
            public string Token { get; set; }
            public string TokenExpiry { get; set; }
        }

    }
}


