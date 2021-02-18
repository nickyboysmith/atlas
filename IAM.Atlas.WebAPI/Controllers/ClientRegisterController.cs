using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Web.Http;
using System.Xml.Linq;
using System.Data.Entity;
using System.Text.RegularExpressions;
using IAM.Atlas.Tools;
using System.Web;
using System.Configuration;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ClientRegisterController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/Client/NewRegistration/Confirmation")]
        [HttpPost]
        public object Confirmation([FromBody] FormDataCollection formBody)
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration/Confirmation", 1, "Started Process");
            //}
            var confirmName = StringTools.GetBoolOrFail("ConfirmedName", ref formBody, "You haven't confirmed your name.");
            var confirmTerms = StringTools.GetBoolOrFail("ConfirmedCourseAttendance", ref formBody, "You haven't confirmed you wish to attend the course.");
            var confirmAmount = StringTools.GetBoolOrFail("ConfirmedWillPayCourseSupplier", ref formBody, "You haven't agreed to pay the supplier the confirmed amount.");

            // If the terms checkbox is false
            // Display error message
            if (confirmTerms == false)
            {
                Error.FrontendHandler(HttpStatusCode.Forbidden, "Sorry but we need you to Accept our Terms before you can continue.");
            }

            // If the name confirmation check box is false
            // Display error message
            if (confirmName == false)
            {
                Error.FrontendHandler(HttpStatusCode.Forbidden, "Please Confirm that the Name is correct.");
            }

            // If the pay course supplier check box is false
            // Display error message
            if (confirmAmount == false)
            {
                Error.FrontendHandler(HttpStatusCode.Forbidden, "Amount should be Confirmed.");
            }


            var clientObject = new ClientLoginJSON();
            var token = this.Request.Headers.GetValues("X-Auth-Token").ToList();
            var theToken = token[0];

            // Get the User Id & Client Id
            // From the Id stored against the Token
            try {

                clientObject = atlasDB.LoginSessions
                    .Include("User")
                    .Include("User.User_Clients")
                    .Where(
                        client => 
                            client.AuthToken == theToken
                    )
                    .Select(
                        theClient => new ClientLoginJSON
                        {
                            UserId = theClient.UserId,
                            ClientId = theClient.User.User_Clients.FirstOrDefault().Id
                        }
                    )
                    .First();

            } catch (DbEntityValidationException ex)
            {
                LogError("ClientRegisterController:AddClientSpecialRequirements:1", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex)
            {
                LogError("ClientRegisterController:AddClientSpecialRequirements:1", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }

            // Update the client booking state
            try {

                // Get the record
                var clientBooking = atlasDB.ClientOnlineBookingStates
                    .Where(
                        client => 
                        client.ClientId == clientObject.ClientId
                    )
                    .First();

                // Update values
                clientBooking.ConfirmedCourseAttendance = true;
                clientBooking.ConfirmedWillPayCourseSupplier = true;
                clientBooking.AgreedToTermsAndConditions = true;

                // Modify values
                var entry = atlasDB.Entry(clientBooking);
                entry.State = System.Data.Entity.EntityState.Modified;

                // Save values
                atlasDB.SaveChanges();

            } catch (DbEntityValidationException ex)
            {
                LogError("ClientRegisterController:AddClientSpecialRequirements:1", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex)
            {
                LogError("ClientRegisterController:AddClientSpecialRequirements:1", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }

            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration/Confirmation", 2, "Completed Process");
            //}
            return true;
        }

        [AuthorizationRequired]
        [Route("api/Client/NewRegistration/SpecialRequirements")]
        [HttpPost]
        public object AddClientSpecialRequirements([FromBody] FormDataCollection formBody)
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration/SpecialRequirements:AddClientSpecialRequirements", 1, "Started Process");
            //}
            // get the user id and client id from the token 
            var otherRequirementCount = ArrayTools.ArrayLength("otherRequirements", ref formBody);
            var specialRequirementCount = ArrayTools.ArrayLength("specialRequirements", ref formBody);
            var clientNote = StringTools.GetString("clientNote", ref formBody);

            // if no special requirements selected
            // no extra requirements filled out
            // no notes
            // The return bool
            if (
                otherRequirementCount == 0 && 
                specialRequirementCount == 0 && 
                string.IsNullOrEmpty(clientNote)
                )
            {
                return "You have no additional requirements! You will be taken to the next step";
            }

            // Put in method
            var clientObject = new ClientLoginJSON();
            var token = this.Request.Headers.GetValues("X-Auth-Token").ToList();
            var theToken = token[0];

            // Get the User Id & Client Id
            // From the Id stored against the Token
            try
            {

                clientObject = atlasDB.LoginSessions
                    .Include("User")
                    .Include("User.User_Clients")
                    .Where(
                        client =>
                            client.AuthToken == theToken
                    )
                    .Select(
                        theClient => new ClientLoginJSON
                        {
                            UserId = theClient.UserId,
                            ClientId = theClient.User.User_Clients.FirstOrDefault().Id
                        }
                    )
                    .First();

            } catch (DbEntityValidationException ex)
            {
                LogError("ClientRegisterController:AddClientSpecialRequirements:1", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex)
            {
                LogError("ClientRegisterController:AddClientSpecialRequirements:1", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }


            // if special requirements added
            // [then] check client special requirements
            // [if] doesnt already exist 
            // [then] add to table [ClientSpecialRequirement]
            if (specialRequirementCount > 0)
            {
                for (int i = 0; i < specialRequirementCount; i++)
                {
                    var specialRequirement = StringTools.GetIntOrFail("specialRequirements[" + i + "]", ref formBody, "Your additional requirement is not valid.");
                    var checkClientSpecialRequirement = 0;

                    // Check that the special requirement doesnt already exist
                    try
                    {
                        checkClientSpecialRequirement = atlasDB.ClientSpecialRequirements
                            .Where(
                                checkClient =>
                                    checkClient.ClientId == clientObject.ClientId &&
                                    checkClient.SpecialRequirementId == specialRequirement
                            )
                            .Count();
                    } catch (DbEntityValidationException ex)
                    {
                        LogError("ClientRegisterController:AddClientSpecialRequirements:2", ex);
                        Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                    } catch (Exception ex)
                    {
                        LogError("ClientRegisterController:AddClientSpecialRequirements:2", ex);
                        Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                    }



                    // If this special requirement isn't associated with this client
                    // Then + only then add it
                    if (checkClientSpecialRequirement == 0)
                    {
                        var clientSpecial = new ClientSpecialRequirement();
                        clientSpecial.SpecialRequirementId = specialRequirement;
                        clientSpecial.ClientId = clientObject.ClientId;
                        clientSpecial.AddByUserId = clientObject.UserId;
                        clientSpecial.DateAdded = DateTime.Now;
                        atlasDB.ClientSpecialRequirements.Add(clientSpecial);
                    }
                }
            }

            // if extra requirements added
            // [then] loop through checking that item hasn't already been added
            // if doesn't exist
            // [then] add to table [ClientOtherRequirement]
            if (otherRequirementCount > 0)
            {
                for (int i = 0; i < otherRequirementCount; i++)
                {
                    var otherRequirement = StringTools.GetString("otherRequirements[" + i + "]", ref formBody);
                    var checkClientOtherRequirement = 0;

                    // Check that the special requirement doesn't already exist
                    try
                    {
                        checkClientOtherRequirement = atlasDB.ClientOtherRequirements
                            .Where(
                                checkClient =>
                                    checkClient.ClientId == clientObject.ClientId &&
                                    checkClient.Name == otherRequirement
                            )
                            .Count();
                    } catch (DbEntityValidationException ex)
                    {
                        LogError("ClientRegisterController:AddClientSpecialRequirements:3", ex);
                        Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                    } catch (Exception ex)
                    {
                        LogError("ClientRegisterController:AddClientSpecialRequirements:3", ex);
                        Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                    }

                    // If this other requirement isn't associated with this client
                    // Then + only then add it
                    if (checkClientOtherRequirement == 0)
                    {
                        var clientOther = new ClientOtherRequirement();
                        clientOther.Name = otherRequirement;
                        clientOther.ClientId = clientObject.ClientId;
                        clientOther.AddByUserId = clientObject.UserId;
                        clientOther.DateAdded = DateTime.Now;
                        atlasDB.ClientOtherRequirements.Add(clientOther);
                    }
                }
            }

            // If note added
            // save to note
            // then save to client note
            if (!string.IsNullOrEmpty(clientNote))
            {
                var checkClientNote = 0;

                // Check to see if an exact match of the note 
                // Already exists
                try
                {
                    checkClientNote = atlasDB.ClientNotes
                    .Where(
                        checkNote =>
                            checkNote.ClientId == clientObject.ClientId &&
                            checkNote.Note.Note1 == clientNote
                    )
                    .Count();
                } catch (DbEntityValidationException ex) {
                    LogError("ClientRegisterController:AddClientSpecialRequirements:5", ex);
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                } catch (Exception ex) {
                    LogError("ClientRegisterController:AddClientSpecialRequirements:5", ex);
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                }

                //If it doesn't add it
                if (checkClientNote == 0)
                {
                    var theNote = new Note();
                    theNote.DateCreated = DateTime.Now;
                    theNote.CreatedByUserId = clientObject.UserId;
                    theNote.Note1 = clientNote;

                    var theClientNote = new ClientNote();
                    theClientNote.ClientId = clientObject.ClientId;
                    theClientNote.Note = theNote;


                    atlasDB.ClientNotes.Add(theClientNote);
                }
            }

            // save the changes
            try {
                atlasDB.SaveChanges();
            } catch (DbEntityValidationException ex) {
                LogError("ClientRegisterController:AddClientSpecialRequirements:6", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex) {
                LogError("ClientRegisterController:AddClientSpecialRequirements:6", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }


            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration/SpecialRequirements:AddClientSpecialRequirements", 2, "Completed Process");
            //}
            return "Requirements have been saved successfully";
        }

        [HttpPost]
        [AllowCrossDomainAccess]
        [Route("api/Client/NewRegistration")]
        public object NewRegistration([FromBody] FormDataCollection formBody)
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration:NewRegistration", 1, "Started Process");
            //}
            string status = "";
            FormDataCollection formData = formBody;

            //Create the client and user objects
            Client client = new Client();
            User user = new User();

            //Extract and populate the client details
            var OrganisationId = StringTools.GetInt("organisationId", ref formData);
            var Title = StringTools.GetString("title", ref formData);
            var FirstName = StringTools.GetString("firstName", ref formData).Trim();
            var OtherNames = StringTools.GetString("otherNames", ref formData).Trim();
            var OtherTitle = StringTools.GetString("otherTitle", ref formData).Trim();
            var Surname = StringTools.GetString("Surname", ref formData).Trim();
            var DisplayName = StringTools.GetString("displayName", ref formData).Trim();
            var Email = StringTools.GetString("email", ref formData);
            var ConfirmEmail = StringTools.GetString("confirmEmail", ref formData);

            var Address = StringTools.GetString("Address[Address]", ref formData);
            var Postcode = StringTools.GetString("Address[Postcode]", ref formData).ToUpper();
            var Country = StringTools.GetString("Country", ref formData);

            var LicenceNumber = StringTools.GetString("LicenceNumber", ref formData);
            var UkLicence = StringTools.GetBool("ukLicence", ref formData);
            var LicenceTypeId = StringTools.GetInt("LicenceTypeId", ref formData);
            var CourseTypeId = StringTools.GetIntOrFail("courseTypeId", ref formData, "Please select a valid course");
            var RegionId = StringTools.GetIntOrFail("regionId", ref formData, "Please select a region");

            var LicenceExpiryDate = StringTools.GetDate("LicenceExpiryDate", "dd/MM/yyyy", ref formData);
            var PhotoCardExpiryDate = StringTools.GetDate("LicencePhotoCardExpiryDate", "dd/MM/yyyy", ref formData);

            //DORS Client Data
            var DORSExpiryDate = StringTools.GetDate("clientDORSData[ExpiryDate]", ref formData);
            if (DORSExpiryDate != null)
            {
                DORSExpiryDate = DORSExpiryDate.Value.Date;
                DORSExpiryDate = DORSExpiryDate.Value.AddHours(23).AddMinutes(59).AddSeconds(59).AddMilliseconds(59);
            }
            var DORSAttendanceReference = StringTools.GetIntOrNull("clientDORSData[AttendanceID]", ref formData);
            var DORSSchemeIdentifier = StringTools.GetInt("clientDORSData[SchemeID]", ref formData);
            var dorsScheme = atlasDB.DORSSchemes.Where(ds => ds.DORSSchemeIdentifier == DORSSchemeIdentifier).FirstOrDefault();
            var DORSSchemeId = -1;

            if (dorsScheme != null)
            {
                DORSSchemeId = dorsScheme.Id;
            }
            else
            {
                //There should always be a corresponding DORS Scheme Id, if not - log.
                var systemTrappedError = new SystemTrappedError();
                systemTrappedError.DateRecorded = DateTime.Now;
                systemTrappedError.FeatureName = "Register New Client - in Web API";
                systemTrappedError.Message = "No Corresponding DORSSchemeId for DORSSchemeIdentifier. Please check table DORSScheme";

                atlasDB.SystemTrappedErrors.Add(systemTrappedError);
                atlasDB.SaveChanges();

                throw new Exception(systemTrappedError.Message);
            }

            // Set the Self Registration
            client.SelfRegistration = true;

            if (!IsValidName(FirstName) || !IsValidName(Surname))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.BadRequest)
                    {
                        Content = new StringContent("Name format incorrect."),
                        ReasonPhrase = "First Name and Surname must be longer than 2 characters and cannot contain numbers"
                    }
                );
            }

            if(!IsValidPostCodeFormat(Postcode))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.BadRequest)
                    {
                        Content = new StringContent("Please enter a valid postcode"),
                        ReasonPhrase = "The supplied postcode does not appear to be in a valid format."
                    }
                );
            }   
            
            if(Address.Length < 5)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.BadRequest)
                    {
                        Content = new StringContent("Please enter a valid address"),
                        ReasonPhrase = "The supplied address does not appear to be in a valid format."
                    }
                );
            }         

            if (!string.IsNullOrEmpty(Title))
            {
                if (Title.ToLower() == "other")
                {
                    client.Title = OtherTitle;
                }
                else
                {
                    client.Title = Title;
                }
            }
            if (!string.IsNullOrEmpty(FirstName))
                client.FirstName = FirstName;

            client.OtherNames = OtherNames;

            if (!string.IsNullOrEmpty(Surname))
                client.Surname = Surname;

            if (!string.IsNullOrEmpty(DisplayName))
                client.DisplayName = DisplayName;
            
            client.DateCreated = DateTime.Now;
            client.DateUpdated = DateTime.Now;


            // add a location
            if (!string.IsNullOrEmpty(Address) && !string.IsNullOrEmpty(Postcode))
            {
                // the input address was not found so add a new client location to the client
                var location = new Location();
                var clientLocation = new ClientLocation();

                location.Address = Address;
                location.PostCode = Postcode;

                clientLocation.Location = location;
                client.ClientLocations.Add(clientLocation);
            }

            // add the licence
            if (string.IsNullOrEmpty(LicenceNumber) == false)
            {
                var clientLicence = new ClientLicence();
                clientLicence.ClientId = client.Id;
                clientLicence.LicenceExpiryDate = LicenceExpiryDate;
                clientLicence.LicenceNumber = LicenceNumber;
                clientLicence.DriverLicenceTypeId = LicenceTypeId  > 0 ? LicenceTypeId : new  Nullable<int>();
                clientLicence.LicencePhotoCardExpiryDate = PhotoCardExpiryDate;
                client.ClientLicences.Add(clientLicence);
            }

            //Client DORS Data
            var clientDorsData = new ClientDORSData();
            clientDorsData.ClientId = client.Id;
            clientDorsData.DORSAttendanceRef = DORSAttendanceReference;
            clientDorsData.DataValidatedAgainstDORS = true;
            clientDorsData.DateCreated = DateTime.Now;
            clientDorsData.DORSSchemeId = DORSSchemeId;
            clientDorsData.ExpiryDate = DORSExpiryDate;
            client.ClientDORSDatas.Add(clientDorsData);

            
            // add the phone numbers
            List<PhoneType> phoneTypes = atlasDB.PhoneTypes.ToList();
            var phoneNumberCount = ArrayTools.ArrayLength("phoneNumbers", ref formData);
            for (int i = 0; i < phoneNumberCount; i++)
            {
                var phoneTypeId = StringTools.GetInt("phoneNumbers[" + i + "][typeId]", ref formData);
                var phoneNumber = StringTools.GetString("phoneNumbers[" + i + "][number]", ref formData);
                var phoneType = StringTools.GetString("phoneNumbers[" + i + "][type]", ref formData);

                if (phoneTypeId == 0 && !string.IsNullOrEmpty(phoneType))
                {
                    phoneTypeId = getPhoneTypeId(phoneType, phoneTypes);
                }
                var clientPhone = new ClientPhone();
                clientPhone.PhoneTypeId = phoneTypeId;
                clientPhone.PhoneNumber = phoneNumber;
                clientPhone.DateAdded = DateTime.Now;

                client.ClientPhones.Add(clientPhone);
            }

            // add the email address if it isn't in the client emails
            // first delete emails that aren't the same as the form's email
            var emailsToDelete = new List<ClientEmail>();
            if (Email == ConfirmEmail)
            {
                if (!client.ClientEmails.Any(ce => ce.Email != null ? ce.Email.Address == Email : false))
                {
                    var addClientEmail = new ClientEmail();
                    var addEmail = new Email();
                    addEmail.Address = Email;
                    addClientEmail.Email = addEmail;
                    client.ClientEmails.Add(addClientEmail);
                }
            }
            var emailCount = ArrayTools.ArrayLength("ClientEmails", ref formData);
            for (int j = 0; j < emailCount; j++)
            {
                var emailAddress = StringTools.GetString("ClientEmails[" + j + "][Email][Address]", ref formData);

                if (!client.ClientEmails.Any(ce => ce.Email != null ? ce.Email.Address == emailAddress : false))
                {
                    var email = new Email();
                    var clientEmail = new ClientEmail();
                    email.Address = emailAddress;
                    clientEmail.Email = email;

                    client.ClientEmails.Add(clientEmail);
                }
            }

            //create populate the user object
            //user.LoginId = this.GetUserLogin(client); - do not populate here. done via triggers/sp's
            //user.Password = System.Web.Security.Membership.GeneratePassword(12, 1);
            user.PasswordChangeRequired = true;
            user.Disabled = false;
            if (string.IsNullOrEmpty(client.OtherNames) == true)
            {
                user.Name = client.FirstName + " " + client.Surname;
            }
            else
            {
                user.Name = client.FirstName + " " + client.OtherNames + " " + client.Surname;
            }
            user.CreationTime = DateTime.Now;
            user.DateUpdated = DateTime.Now;
            user.Email = Email;

            //add user to the database
            client.User_User = user;

            // add client to the database
            atlasDB.Clients.Add(client);
            
            //assign the user to an organisation
            atlasDB.ClientOrganisations.Add(new ClientOrganisation
            {
                Client = client,
                DateAdded = DateTime.Now,
                OrganisationId = OrganisationId
            });

            atlasDB.SaveChanges();

            // Check to see if it's the first time recording details
            var firstRecord = FirstTimeRecordingDetails(client.Id, client.ClientOnlineBookingStates);


            // Get the client login object
            var clientLoginObject = new
            {
                Login = ClientLogin(client.Id, user.Id, user.LoginId),
                BookingState = GetClientBookingState(client.Id),
                BookingDetails = GetBookingDetails(CourseTypeId),
                Region = GetRegionDetails(RegionId),
                ClientId = client.Id
            };

            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration:NewRegistration", 2, "Completed Process");
            //}
            return clientLoginObject;
        }

        [AuthorizationRequired]
        [Route("api/Client/NewRegistration/getCourses")]
        [HttpPost]
        public object GetCourses([FromBody] FormDataCollection formBody)
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration/getCourses:GetCourses", 1, "Started Process");
            //}
            var courseTypeId = StringTools.GetIntOrFail("courseTypeId", ref formBody, "Invalid course type Id");
            var clientId = StringTools.GetIntOrFail("clientId", ref formBody, "Invalid client Id");
            var regionId = StringTools.GetIntOrFail("regionId", ref formBody, "Invalid region Id");
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Invalid Organisation Id");
            var dateSearchType = StringTools.GetStringOrFail("date[is]", ref formBody, "Invalid date selection");
            var startDate = DateTime.Now;
            var endDate = DateTime.Now;

            // If start the start date from right now
            // Add the end date that is only one year in advance
            if (dateSearchType == "present")
            {
                endDate = startDate.Date.AddYears(1);
            }

            // If the start date is between
            // create query between two dates
            if (dateSearchType == "between")
            {
                startDate = StringTools.GetDateOrFail("date[startDate]", ref formBody, "Invalid search date.");
                startDate = startDate.Date;
                endDate = StringTools.GetDateOrFail("date[endDate]", ref formBody, "Invalid search date.");
                endDate = endDate.Date.AddTicks(-1).AddDays(1);
            }

            var courses = new object { };
            var clientRegistrationMaxCourses = StringTools.GetInt(ConfigurationManager.AppSettings["ClientRegistrationMaxCourses"]);
            clientRegistrationMaxCourses = clientRegistrationMaxCourses == 0 ? 100 : clientRegistrationMaxCourses;

            try
            {
                ///Finds the last day that the client can book a course
                // if the passed through parameter endDate exceeds the 
                // last booking date, it replaces endDate with lastBookingDate
                var clientDetailInfo = atlasDBViews.vwClientDetailMinimals.Where(x => x.ClientId == clientId).FirstOrDefault();
                DateTime? lastBookingDate;

                if (clientDetailInfo != null)
                {
                    lastBookingDate = clientDetailInfo.LastDateForCourseBooking;
                    if (endDate > lastBookingDate)
                    {
                        endDate = (DateTime)lastBookingDate;
                    }
                }


                courses = atlasDBViews.vwDORSCoursesWithPlacesForOnlineBookings
                .Where(
                    theCourse =>
                        theCourse.CourseTypeId == courseTypeId &&
                        theCourse.StartDate >= startDate && theCourse.StartDate <= endDate &&
                        theCourse.OrganisationId == organisationId &&
                        theCourse.RegionId == regionId
                )
                .Select(
                    theCourses => new
                    {
                        StartDate = theCourses.StartDate,
                        EndDate = theCourses.EndDate,
                        StartDateFormated = theCourses.StartDateFormated,
                        EndDateFormated = theCourses.EndDateFormated,
                        MaxPlaces = (theCourses.NumberofClientsonCourse == 0) ? 0 : theCourses.OnlinePlacesRemaining,
                        Booked = theCourses.NumberofClientsonCourse,
                        Location = theCourses.VenueName,
                        VenueId = theCourses.VenueId,
                        CourseId = theCourses.CourseId,
                        CourseTypeId = theCourses.CourseTypeId,
                        theCourses.HasInterpreter,
                        RebookingFee = theCourses.CourseRebookingFee
                    }
                )
                .Take(clientRegistrationMaxCourses) //limit rows returned as UI blows up. In reality should never exceed 100 anyways
                .OrderBy(x => x.StartDate)
                .ToList();
            } catch (DbEntityValidationException ex) {
                LogError("ClientRegisterController:GetCourses", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex) {
                LogError("ClientRegisterController:GetCourses", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }


            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("api/Client/NewRegistration/getCourses:GetCourses", 2, "Completed Process");
            //}
            return courses;
        }

        private object ClientLogin(int ClientId, int UserId, string LoginId)
        {
            
            var cookieEncryption = StringCipher.Encrypt("clientUser", StringCipher.cookieOnlyPassPhrase);
            var clientLoginObject = new object { };

            try
            {
                clientLoginObject = atlasDB.Clients
                    .Include("User_User")
                    .Include("User_CreatedByUser")
                    .Include("User_LockedByUser")
                    .Include("User_UpdatedByUser")
                    .Include("ClientOrganisations")
                    .Include("ClientLocation")
                    .Include("Location")
                    .Where(
                        theClient =>
                            theClient.Id == ClientId &&
                            theClient.User_User.Id == UserId
                    )
                    .Select(
                        theClient => new
                        {
                            FullName = theClient.FirstName + " " + theClient.Surname,
                            Name = theClient.DisplayName,
                            PostCode = theClient.ClientLocations.FirstOrDefault().Location.PostCode,
                            UserId = theClient.User_User.Id,
                            ClientId = theClient.Id,
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
                            )
                            .ToList()
                            .FirstOrDefault(),
                            cookie = cookieEncryption
                        }
                    )
                    .ToList();


                var SignIn = new SignInController();
                var tokenServices = new TokenServices();

                // Remove all previous tokens
                tokenServices.DeleteTokenByUserId(UserId);

                // Create a new set of tokens
                var responseHeaders = SignIn.GetAuthToken(UserId);

                // Add The token headers to the login request
                HttpContext.Current.Response.Headers.Add("X-Auth-Token", responseHeaders.Token);
                HttpContext.Current.Response.Headers.Add("TokenExpiry", responseHeaders.TokenExpiry);

                // Log the login attempt
                // SignIn.LogUserLogin(LoginId, true);

                

            } catch (DbEntityValidationException ex) {
                LogError("ClientRegisterController:ClientLogin", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex)
            {
                LogError("ClientRegisterController:ClientLogin", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please retry!");
            }

            return clientLoginObject;
        }


        private object GetClientBookingState (int ClientId)
        {
            var clientBookingState = new object { };

            try
            {
                clientBookingState = atlasDB.ClientOnlineBookingStates
                .Where(
                    theClient =>
                        theClient.ClientId == ClientId
                )
                .Select(
                    theState => new
                    {
                        theState.ConfirmedName,
                        theState.ConfirmedCourseAttendance,
                        theState.ConfirmedWillPayCourseSupplier
                    }
                )
                .ToList();

            } catch (DbEntityValidationException ex)
            {
                LogError("GetClientBookingState", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            } catch (Exception ex)
            {
                LogError("ClientRegisterController:GetClientBookingState", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }

            return clientBookingState;
        }

        private object GetBookingDetails(int CourseTypeId)
        {
            var bookingDetailObject = new object { };

            try
            {
                bookingDetailObject = atlasDB.DORSSchemeCourseTypes
                    .Include("CourseType")
                    .Include("CourseType.CourseTypeFees")
                    .Include("DORSSchemeCourseType")
                    .Include("DORSScheme")
                    .Where(
                        dorsSchemeCourseType => dorsSchemeCourseType.CourseTypeId == CourseTypeId
                        )
                    .Select(
                        dorsSchemeCourseType => new
                        {
                            Id = dorsSchemeCourseType.CourseType.Id,
                            Title = dorsSchemeCourseType.DORSScheme.Name,
                            CourseFee = dorsSchemeCourseType.CourseType.CourseTypeFees
                                                                        .Where(ctf => ctf.Disabled == false && ctf.EffectiveDate <= DateTime.Now)
                                                                        .OrderByDescending(ctf => ctf.EffectiveDate)
                                                                        .FirstOrDefault().CourseFee
                        }
                    )
                    .ToList();
            }
            catch (DbEntityValidationException ex)
            {
                LogError("ClientRegisterController:GetBookingDetails", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }
            catch (Exception ex)
            {
                LogError("ClientRegisterController:GetBookingDetails", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }
            return bookingDetailObject;
        }

        private object GetRegionDetails(int RegionId)
        {
            var regionDetailObject = new object { };

            try
            {
                regionDetailObject = atlasDB.Region
                   .Where(x => x.Id == RegionId)
                    .ToList();

            }
            catch (DbEntityValidationException ex)
            {
                LogError("ClientRegisterController:GetRegionDetails", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }
            catch (Exception ex)
            {
                LogError("ClientRegisterController:GetRegionDetails", ex);
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
            }
            return regionDetailObject;
        }

        private object FirstTimeRecordingDetails(int ClientId, ICollection<ClientOnlineBookingState> ClientBookingState)
        {
            var hasOnlineBookingState = ClientBookingState.Count;
            var isNewRecord = false;
            if (hasOnlineBookingState == 0)
            {
                // Doesn't already have an entry in the DB
                try
                {
                    var bookingState = new ClientOnlineBookingState();
                    bookingState.ClientId = ClientId;
                    bookingState.DetailsRecorded = true;

                    atlasDB.ClientOnlineBookingStates.Add(bookingState);
                    atlasDB.SaveChanges();

                    isNewRecord = true;

                } catch (DbEntityValidationException ex )
                {
                    LogError("ClientRegisterController:FirstTimeRecordingDetails", ex);
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                } catch (Exception ex)
                {
                    LogError("ClientRegisterController:FirstTimeRecordingDetails", ex);
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "Oops! Something is not quite right. Please Retry.");
                }
            } else {
                // Has an entry in the DB
                isNewRecord = false;
            }
            return isNewRecord;
        }

        private string GetUserLogin(Client client)
        {
            var userController = new UserController();
            return userController.getUserLoginId(client.FirstName, client.Surname, client.OtherNames);
        }

        private int getPhoneTypeId(string phoneTypeName, List<PhoneType> phoneTypes)
        {
            int phoneTypeId = -1;
            foreach (PhoneType phoneType in phoneTypes)
            {
                if (phoneType.Type == phoneTypeName)
                {
                    phoneTypeId = phoneType.Id;
                    break;
                }
            }
            return phoneTypeId;
        }

        private bool IsValidName(string name)
        {
            if(name.Replace(" ", "").Length > 1  && !Regex.IsMatch(name, @"\d"))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        private bool IsValidPostCodeFormat(string postCode)
        {
            if (Regex.IsMatch(postCode.ToUpper().Replace(" ", ""), @"(?:[A-Za-z]\d ?\d[A-Za-z]{2})|(?:[A-Za-z][A-Za-z\d]\d ?\d[A-Za-z]{2})|(?:[A-Za-z]{2}\d{2} ?\d[A-Za-z]{2})|(?:[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]{2})|(?:[A-Za-z]{2}\d[A-Za-z] ?\d[A-Za-z]{2})"))
            {
                return true;
            }
            else
            {
                return false;
            }
        }



        

        private string FormatAddress(FormDataCollection formBody)
        {
            StringBuilder addressSB = new StringBuilder("");
            if (!string.IsNullOrEmpty((string)formBody.Get("company"))) addressSB.AppendLine((string)formBody.Get("company"));
            if (!string.IsNullOrEmpty((string)formBody.Get("address1"))) addressSB.AppendLine((string)formBody.Get("address1"));
            if (!string.IsNullOrEmpty((string)formBody.Get("address2"))) addressSB.AppendLine((string)formBody.Get("address2"));
            if (!string.IsNullOrEmpty((string)formBody.Get("town"))) addressSB.AppendLine((string)formBody.Get("town"));
            if (!string.IsNullOrEmpty((string)formBody.Get("county"))) addressSB.AppendLine((string)formBody.Get("county"));
            if (!string.IsNullOrEmpty((string)formBody.Get("postcode"))) addressSB.AppendLine((string)formBody.Get("postcode"));
            if (!string.IsNullOrEmpty((string)formBody.Get("country"))) addressSB.AppendLine((string)formBody.Get("country"));
            return addressSB.ToString();
        }

        // public ClientLoginObject


    }
}
