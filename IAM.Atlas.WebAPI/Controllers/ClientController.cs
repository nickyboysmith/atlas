using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
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
using System.Web.Script.Serialization;

using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Web.Http.ModelBinding;


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ClientController : AtlasBaseController
    {
        public enum DORSAttendanceStates
        {
            BookingPending = 1,
            Booked = 2,
            BookedAndPaid = 3,
            AttendedandCompleted = 4,
            AttendedAndNotCompleted = 4,
            DidNotAttend = 6,
            OfferWithdrawn = 7
        }

        // GET: api/Client
        public IEnumerable<ClientJSON> Get()
        {
            List<ClientJSON> clientJSONList = atlasDB.Clients
                .Include("ClientLicences")
                .Include("ClientEmails")
                .Include("ClientEmails.Email")
                .Include("ClientPhones")
                .Include("ClientPhones.PhoneType")
                .Include("ClientLicences")
                .AsEnumerable()
                .Select(c => new ClientJSON
                {
                    Id = c.Id,
                    Title = c.Title,
                    DisplayName = c.DisplayName,
                    Emails = ClientJSON.TransformEmails(c.ClientEmails),
                    PhoneNumbers = ClientJSON.TransformPhones(c.ClientPhones),
                    Licences = ClientJSON.TransformLicences(c.ClientLicences)
                })
                .ToList();
            return clientJSONList;
        }

        // GET: api/Client/GetTitles
        public class Titles
        {
            public int Id { get; set; }
            public string StringId { get; set; }
            public string Title { get; set; }
        }
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/Client/GetTitles")]
        public object GetTitles()
        {
            IList<Titles> TitleList = new List<Titles>() {
                new Titles(){ Id=1, StringId="", Title=""},
                new Titles(){ Id=2, StringId="Dr", Title="Dr"},
                new Titles(){ Id=3, StringId="Miss", Title="Miss"},
                new Titles(){ Id=4, StringId="Mr", Title="Mr"},
                new Titles(){ Id=5, StringId="Mrs", Title="Mrs"},
                new Titles(){ Id=6, StringId="Ms", Title="Ms"},
                new Titles(){ Id=7, StringId="Rev", Title="Rev"},
                new Titles(){ Id=8, StringId="Other", Title="Other"}
            };
            return TitleList;
        }
        

        [AuthorizationRequired]
        [Route("api/Client/Address/{ClientId}")]
        [HttpGet]
        public object GetClientAddress(int ClientId)
        {


            // TODO: Check if organisation user system admin etc, 
            // if the case use the client Id
            // If not then get the client id from the user id




            var address = new Object();

            try
            {
                address = atlasDB.ClientLocations
                    .Include("Location")
                    .Where(
                        clientLocation => clientLocation.ClientId == ClientId
                    )
                    .Select(
                        clientAddress => new
                        {
                            clientAddress.Location.Address,
                            clientAddress.Location.PostCode
                        }
                    )
                    .ToList();

            }
            catch (Exception ex)
            {

                throw (ex);

                Error.FrontendHandler(HttpStatusCode.Forbidden, "There has been an error retrieving your address.");
            }

            return address;
        }

        // GET: api/Client/5
        [HttpGet]
        [AuthorizationRequired]
        public object Get(int id)
        {
            var client = atlasDB.Clients
                .Include("ClientLicence")
                .Include("ClientLicence.DriverLicenceType")
                .Include("ClientEmails")
                .Include("ClientEmails.Email")
                .Include("ClientLocations")
                .Include("ClientLocations.Location")
                .Include("ClientPhones")
                .Include("ClientPhones.PhoneType")
                .Include("CourseClient")
                .Include("ClientMarkedForDeletes")
                .Include("CourseClient.Course")
                .Include("CourseClient.Course.CourseType")
                .Include("CourseClient.Course.CourseClientRemoveds")
                .Include("ReferringAuthorityClients.ReferringAuthority")
                .Include(c => c.ClientPreviousIds)
                .Include(c => c.ClientIdentifiers)
                .Include("User_LockedByUser")
                .Include("ClientMysteryShopper")
                .Where(
                    theClient => theClient.Id == id
                )
                .Select(
                    theClient => new
                    {
                        Id = theClient.Id,
                        Title = theClient.Title,
                        IsMysteryShopper = theClient.ClientMysteryShoppers.Any(cms => cms.ClientId == id),
                        FirstName = theClient.FirstName,
                        OtherNames = theClient.OtherNames,
                        Surname = theClient.Surname,
                        DisplayName = theClient.DisplayName,
                        theClient.DateOfBirth,
                        theClient.LockedByUserId,
                        LockedByUserName = theClient.User_LockedByUser.Name,
                        ReferringAuthority = theClient.ReferringAuthorityClients.OrderByDescending(x => x.Id).FirstOrDefault() != null ? theClient.ReferringAuthorityClients.OrderByDescending(x => x.Id).FirstOrDefault().ReferringAuthority.Name : "",
                        ClientMarkedForDeletions = theClient.ClientMarkedForDeletes,
                        ClientPreviousIds = theClient.ClientPreviousIds,
                        ClientUniqueIdentifier = theClient.ClientIdentifiers,
                        CourseInformation = theClient.CourseClients.Select(
                            theCourse => new
                            {
                                Id = theCourse.CourseId,

                                theCourse.Course.Reference,
                                CourseReference = theCourse.Course.Reference,
                                CourseType = theCourse.Course.CourseType.Title,
                                CourseDate = theCourse.Course.CourseDate.FirstOrDefault().DateStart,
                                IsDORSCourse = theCourse.Course.DORSCourse,
                                ClientRemoved = theCourse.Course.CourseClientRemoveds.Any(ccr => ccr.ClientId == id && ccr.DateAddedToCourse == theCourse.DateAdded),
                                AmountPaid = theCourse.Course.CourseClientPayments.ToList().Where(x => x.ClientId == id).Count() > 0 ?
                                             theCourse.Course.CourseClientPayments.ToList().Where(x => x.ClientId == id).Sum(y => y.Payment.Amount) :
                                             0,
                                //AmountOutstanding = (theCourse.Course.CourseType.CourseTypeFees.ToList()
                                //                                                                .Where(x => x.EffectiveDate < DateTime.Now)
                                //                                                                .OrderByDescending(x => x.EffectiveDate)
                                //                                                                .FirstOrDefault()
                                //                                                                .CourseFee.HasValue ?
                                //                    (decimal)theCourse.Course.CourseType.CourseTypeFees.ToList()
                                //                                                                        .Where(x => x.EffectiveDate < DateTime.Now)
                                //                                                                        .OrderByDescending(x => x.EffectiveDate)
                                //                                                                        .FirstOrDefault().CourseFee :
                                //                    (decimal)0.00) -
                                //                    (theCourse.Course.CourseClientPayments.ToList()
                                //                                                            .Where(x => x.ClientId == id)
                                //                                                            .Count() > 0 ?
                                //                    theCourse.Course.CourseClientPayments.ToList()
                                //                                                            .Where(x => x.ClientId == id)
                                //                                                            .Sum(y => y.Payment.Amount) :
                                //                                                            0),

                                AmountOutstanding = (theCourse.Course.CourseClients.ToList()
                                                                    .OrderByDescending(cc => cc.Id)
                                                                    .FirstOrDefault()
                                                                    .TotalPaymentDue.HasValue ?
                                                    (decimal)theCourse.Course.CourseClients
                                                                                .OrderByDescending(cc => cc.Id)
                                                                                .FirstOrDefault()
                                                                                .TotalPaymentDue :
                                                    (decimal)0.00)
                                                     -
                                                    (theCourse.Course.CourseClientPayments
                                                                    .ToList()
                                                                    .Where(x => x.ClientId == id)
                                                                    .Count() > 0 ?
                                                    theCourse.Course.CourseClientPayments.ToList()
                                                                                            .Where(x => x.ClientId == id)
                                                                                            .Sum(y => y.Payment.Amount) :
                                                                                            0),
                                PaymentDueDate = theCourse.PaymentDueDate,
                                DORSDetails = theClient.ClientDORSDatas.Select(
                                    dorsDetails => new
                                    {
                                        DORSReference = dorsDetails.DORSAttendanceRef,
                                        Region = dorsDetails.ReferringAuthority,
                                        ReferringAuthority = dorsDetails.ReferringAuthority.Name,
                                        ReferralDate = dorsDetails.DateReferred,
                                        ExpiryDate = dorsDetails.ExpiryDate,
                                        DORSAttendanceStateIdentifier = dorsDetails.DORSAttendanceState.DORSAttendanceStateIdentifier,
                                        DORSSchemeIdentifier = dorsDetails.DORSScheme.DORSSchemeIdentifier
                                    }
                                )
                            }
                        ),

                        Addresses = theClient.ClientLocations.Select(
                            address => new
                            {
                                address.Location.Address,
                                address.Location.PostCode
                            }
                        ),
                        Emails = theClient.ClientEmails.Select(
                            email => new
                            {
                                email.Email.Address
                            }
                        ),
                        Licences = theClient.ClientLicences.Select(
                            licence => new
                            {
                                Type = licence.DriverLicenceTypeId,
                                TypeName = licence.DriverLicenceType.Name,
                                Number = licence.LicenceNumber,
                                ExpiryDate = licence.LicenceExpiryDate,
                                PhotocardExpiryDate = licence.LicencePhotoCardExpiryDate

                            }
                        ),
                        PhoneNumbers = theClient.ClientPhones.Select(
                            phone => new
                            {
                                Number = phone.PhoneNumber,
                                NumberType = phone.PhoneType.Type
                            }
                        ),
                        SMSConfirmed = theClient.SMSConfirmed == null ? false : (bool)theClient.SMSConfirmed,
                        EmailedConfirmed = theClient.EmailedConfirmed == null ? false : (bool)theClient.EmailedConfirmed,
                        EmailCourseReminders = theClient.EmailCourseReminders == null ? false : (bool)theClient.EmailCourseReminders,
                        SMSCourseReminders = theClient.SMSCourseReminders == null ? false : (bool)theClient.SMSCourseReminders
                    }
                )
                .FirstOrDefault();

            return client;

        }


        [Route("api/Client/GetBasicClientInfo/{id}")]
        [HttpGet]
        [AuthorizationRequired]
        public object GetBasicClientInfo(int id)
        {
            var lastDeletionAttempt = atlasDB.ClientMarkedForDeletes.Where(x => x.ClientId == id).OrderByDescending(x => x.Id).FirstOrDefault();
            var lastDeletionAttemptDate = "";
            var clientLicences = GetClientLicences(id).Count;
            var hasLicenceDetails = false;

            if (clientLicences > 0)
            {
                hasLicenceDetails = true;
            }

            if (lastDeletionAttempt != null)
            {
                lastDeletionAttemptDate = lastDeletionAttempt.DateRequested.ToString();
            }
            //var clientPrevIds = atlasDB.ClientPreviousIds.Where(x => x.ClientId == id).ToList();
            var uniqueIdentifier = atlasDB.ClientIdentifiers.Where(x => x.ClientId == id).OrderByDescending(y => y.DateCreated).FirstOrDefault();
            var clientUniqueIdentifier = "";
            if (uniqueIdentifier != null)
            {
                clientUniqueIdentifier = uniqueIdentifier.UniqueIdentifier;
            }
            //var clientLic = atlasDB.ClientLicence.Where(x => x.ClientId == id).FirstOrDefault();
            var clientX = atlasDB.Clients.Where(x => x.Id == id).FirstOrDefault();
            //var clientPhone = atlasDB.ClientPhones.Where(x => x.ClientId == id).OrderByDescending(y => y.DateAdded).FirstOrDefault();
            //var theCourseInfo = CourseInformationList(id);
            var client = atlasDBViews.vwClientDetails.Where(x => x.ClientId == id)
                        .Select(
                            theClient => new
                            {
                                Id = theClient.ClientId,
                                Title = theClient.Title,
                                IsMysteryShopper = theClient.IsMysteryShopper,
                                FirstName = theClient.FirstName,
                                OtherNames = theClient.OtherNames,
                                Surname = theClient.Surname,
                                DisplayName = theClient.DisplayName,
                                theClient.DateOfBirth,
                                theClient.LockedByUserId,
                                LockedByUserName = theClient.LockedByUserName,
                                ReferringAuthority = theClient.ReferringAuthority,
                                SMSConfirmed = clientX.SMSConfirmed,
                                EmailedConfirmed = clientX.EmailedConfirmed,
                                EmailCourseReminders = clientX.EmailCourseReminders,
                                SMSCourseReminders = clientX.SMSCourseReminders,
                                ClientMarkedForDeletion = lastDeletionAttemptDate,
                                HasLicenceDetails = hasLicenceDetails,
                                ClientUniqueIdentifer = clientUniqueIdentifier ?? "",
                                Address = theClient.Address ?? "",
                                PostCode = theClient.PostCode ?? ""
                            }
                        ).FirstOrDefault();

            return client;

        }

        [Route("api/Client/GetClientLicences/{clientId}")]
        [HttpGet]
        [AuthorizationRequired]

        public List<ClientLicence> GetClientLicences(int clientId)
        {
            var clientLic = atlasDB.ClientLicence
                                    .Include(cl => cl.DriverLicenceType)
                                    .Where(x => x.ClientId == clientId)
                                    .ToList();
            return clientLic;

        }


        [Route("api/Client/GetEntry/{id}")]
        [HttpGet]
        [AuthorizationRequired]
        public Client GetEntry(int id)
        {
            
            Client client = atlasDB.Clients
                            .Include("ClientLicences")
                            .Include("ClientOrganisations")
                            .Include("ClientOrganisations.Organisation")
                            .Include("ClientOrganisations.Organisation.OrganisationSelfConfigurations")
                            .Include("ClientEmails")
                            .Include("ClientEmails.Email")
                            .Include("ClientLocations")
                            .Include("ClientLocations.Location")
                            .Include("ClientPhones")
                            .Include("ClientPhones.PhoneType")
                            .Include("ClientMysteryShoppers")
                            .Include(c => c.ClientMarkedForDeletes)
                            .Include(c => c.ClientPreviousIds)
                            .Include(c => c.ClientIdentifiers)
                            .Include(c => c.User_User)
                            .Include(c => c.User_CreatedByUser)
                            .Include(c => c.User_LockedByUser)
                            .Include(c => c.User_UpdatedByUser)
                            .Where(c => c.Id == id).FirstOrDefault();
            return client;
        }

        [HttpGet]
        [Route("api/client/GetClientDORSData/{ClientId}")]
        public List<ClientDORSDataJSON> GetClientDORSData(int ClientId)
        {
            var clientDORSDataList = atlasDB.ClientDORSDatas
                                        .Include(cdd => cdd.Client)
                                        .Include(cdd => cdd.ReferringAuthority)
                                        .Include(cdd => cdd.DORSScheme)
                                        .Where(cdd => cdd.ClientId == ClientId)
                                        .Select(cdd => new ClientDORSDataJSON()
                                        {
                                            ClientDORSDataId = cdd.Id,
                                            ClientId = cdd.Client.Id,
                                            ClientDisplayName = cdd.Client.DisplayName,
                                            DateReferred = cdd.DateReferred,
                                            DORSAttendanceRef = cdd.DORSAttendanceRef,
                                            DORSSchemeName = cdd.DORSScheme.Name,
                                            DORSSchemeId = cdd.DORSSchemeId,
                                            ExpiryDate = cdd.ExpiryDate,
                                            ReferringAuthorityName = cdd.ReferringAuthority.Name
                                        })
                                        .ToList();
            if(clientDORSDataList.Count == 0)   // Just return client's name and Id so it will show that there are no records in DORS
            {
                var client = atlasDB.Clients.Where(c => c.Id == ClientId).FirstOrDefault();
                if(client != null)
                {
                    clientDORSDataList.Add(new ClientDORSDataJSON() { ClientId = ClientId, ClientDisplayName = client.DisplayName });
                }
            }
            return clientDORSDataList;
        }

        [AuthorizationRequired]
        [Route("api/client/GetClientNotesById/{ClientId}")]
        [HttpGet]
        public object GetClientNotesById(int ClientId)
        {

            return atlasDBViews.vwClientNotes_SubView
                    .Where(inn => inn.ClientId == ClientId);

        }


        [Route("api/client/configoptions/{id}")]
        [HttpGet]
        [AuthorizationRequired]
        public object ConfigOptions(int id)
        {
            var options = atlasDB.OrganisationSelfConfigurations
                            .Where(c => c.OrganisationId == id).FirstOrDefault();
            return options;
        }

        [AuthorizationRequired]
        [Route("api/Client/DeleteClient")]
        [HttpPost]
        public object DeleteClient([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var id = StringTools.GetInt("id", ref formData);
            var deletionNote = StringTools.GetString("deleteNotes", ref formData);
            var userId = StringTools.GetInt("userId", ref formData);

            try
            {
                var deletionRequest = atlasDB.ClientMarkedForDeletes
                                             .Where(x => x.ClientId == id)
                                             .ToList()
                                             .LastOrDefault();
                if (deletionRequest == null)
                {
                    var newDeletionRequest = new ClientMarkedForDelete
                    {
                        ClientId = id,
                        DateRequested = DateTime.Now,
                        DeleteAfterDate = DateTime.Now.AddDays(7),
                        Note = deletionNote,
                        RequestedByUserId = userId
                    };
                    atlasDB.ClientMarkedForDeletes.Add(newDeletionRequest);
                    atlasDB.SaveChanges();
                }
                else
                {
                    if (deletionRequest.CancelledByUserId.HasValue)
                    {
                        if (deletionRequest.CancelledByUserId.Value > 0)
                        {
                            //Do nothing: 
                        }
                    }
                }
                return "success";
            }
            catch (Exception ex)
            {
                return "fail";
            }
        }

        [AuthorizationRequired]
        [Route("api/Client/UndeleteClient")]
        [HttpPost]
        public object UndeleteClient([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var id = StringTools.GetInt("id", ref formData);
            var userId = StringTools.GetInt("userId", ref formData);

            try
            {
                var deletionRequestCancel = atlasDB.ClientMarkedForDeletes
                                             .Where(x => x.ClientId == id)
                                             .ToList()
                                             .LastOrDefault();
                if (deletionRequestCancel != null)
                {
                    deletionRequestCancel.CancelledByUserId = userId;
                    atlasDB.SaveChanges();
                }

                return "success";
            }
            catch (Exception ex)
            {
                return "fail";
            }
        }

        [AuthorizationRequired]
        [Route("api/Client/GetMarkedClientsByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetMarkedClientsByOrganisation(int? OrganisationId)
        {

            return atlasDB.ClientMarkedForDeletes
                    .Include(u => u.Client)
                    .Include(u => u.Client.ClientOrganisations)
                    .Where(u => u.Client.ClientOrganisations.Any(ou => ou.OrganisationId == OrganisationId));
        }

        [AuthorizationRequired]
        [Route("api/Client/DeleteMarkedClients")]
        [HttpPost]
        public object Delete([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var UserId = StringTools.GetInt("UserId", ref formData);

            //var markedClients = StringTools.GetIntArray("selectedClients", ',', ref formData);

            var markedClients = (from fb in formBody
                                 where fb.Key.Contains("selectedClients")
                                 select new { fb.Key, fb.Value });

            foreach (var client in markedClients)
            {
                ClientMarkedForDelete clientMarkedForDelete = atlasDB.ClientMarkedForDeletes.Find(Int32.Parse(client.Value));

                if (clientMarkedForDelete == null)
                {
                    //throw new HttpResponseException(
                    //    new HttpResponseMessage(HttpStatusCode.NotFound)
                    //    {
                    //        Content = new StringContent("The marked client you are tryng to delete does not exist."),
                    //        ReasonPhrase = "Cannot find marked client."
                    //    }
                    //);
                }
                else
                {
                    clientMarkedForDelete.CancelledByUserId = UserId;
                    atlasDB.ClientMarkedForDeletes.Attach(clientMarkedForDelete);
                    var entry = atlasDB.Entry(clientMarkedForDelete);
                    entry.State = System.Data.Entity.EntityState.Modified;
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
                }
            }

            return "Success";
        }

        [Route("api/Client/GetCourses/{ClientId}/{OrganisationId}")]
        [HttpGet]
        public object GetClientCourses(int ClientId, int OrganisationId)
        {
            return atlasDB.CourseClients
                .Include("Course")
                .Include("Course.CourseTypeCategory")
                .Include("Course.CourseType")
                .Include("Course.CourseDate")
                .Where(
                    clientCourse =>
                        clientCourse.Course.OrganisationId == OrganisationId &&
                        clientCourse.ClientId == ClientId
                )
                .Select(
                    client => new
                    {
                        PaymentAmount = client.TotalPaymentDue,
                        CourseTypeCategory = client.Course.CourseTypeCategory.Name,
                        CourseType = client.Course.CourseType.Title,
                        CourseId = client.CourseId,
                        StartDate = client.Course.CourseDate.FirstOrDefault().DateStart
                    }
                )
                .ToList();
        }

        [Route("api/Client/GetClientBookings/{ClientId}/{OrganisationId}")]
        [HttpGet]
        public object GetClientBookings(int ClientId, int OrganisationId)
        {
            var courseClients = atlasDBViews.vwCourseClientFeesAndPaymentSummaries
                .Where(
                    c => c.OrganisationId == OrganisationId && c.ClientId == ClientId)
                .Select(
                    course => new
                    {
                        TotalPaymentDue = course.ClientTotalPaymentDue,
                        TotalPaymentOutstanding = course.ClientTotalPaymentDue - course.ClientTotalPaymentMade,
                        CourseTypeCategory = course.CourseTypeCategory,
                        CourseType = course.CourseType,
                        CourseTypeId = course.CourseTypeId,
                        CourseId = course.CourseId,
                        StartDate = course.CourseStartDate,
                        ClientDORSExpiryDate = course.ClientDORSExpiryDate,
                        Venue = new
                        {
                            Title = course.VenueTitle,
                            Address = course.VenueAddress,
                            PostCode = course.VenuePostCode
                        },
                        RegionId = course.RegionId,
                        RebookingFee = course.CourseRebookingFee
                    }
                )
                .ToList();
                //.Select(
                //    course => new
                //)

            return courseClients;
        }

        [AuthorizationRequired]
        [Route("api/Client/CourseClientTransferRequest")]
        [HttpPost]
        public bool CourseClientTransferRequest([FromBody] FormDataCollection formBody)
        {
            try
            {
                var formData = formBody;

                var clientId = StringTools.GetInt("ClientId", ref formData);
                var transferredFromCourseId = StringTools.GetInt("TransferredFromCourseId", ref formData);
                var transferredToCourseId = StringTools.GetInt("CourseId", ref formData);
                var rebookingFeeAmount = StringTools.GetDecimal("RebookingFee", ref formData);

                var newCourseClientTransferRequest = new CourseClientTransferRequest
                {
                    RequestedByClientId = clientId,
                    TransferFromCourseId = transferredFromCourseId,
                    TransferToCourseId = transferredToCourseId,
                    RebookingFeeAmount = rebookingFeeAmount,
                    DateTimeRequested = DateTime.Now
                };

                atlasDB.CourseClientTransferRequests.Add(newCourseClientTransferRequest);
                atlasDB.SaveChanges();

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        [HttpGet]
        [AllowCrossDomainAccess]
        [Route("api/Client/GetClientsByLicence/{licenceNumber}/{organisationId}")]
        public List<Client> GetClientsByLicence(string licenceNumber, int organisationId)
        {
            List<Client> clients = atlasDB.Clients
                            .Include("ClientLicences")
                            .Include("ClientOrganisations")
                            .Include("ClientOrganisations.Organisation")
                            .Include("ClientOrganisations.Organisation.OrganisationSelfConfigurations")
                            .Include("ClientEmails")
                            .Include("ClientEmails.Email")
                            .Include("ClientLocations")
                            .Include("ClientLocations.Location")
                            .Include("ClientPhones")
                            .Include("ClientPhones.PhoneType")
                            .Include(c => c.ClientPreviousIds)
                            .Include(c => c.User_User)
                            .Include(c => c.User_CreatedByUser)
                            .Include(c => c.User_LockedByUser)
                            .Include(c => c.User_UpdatedByUser)
                            .Include(c => c.CourseClients)
                            .Include("CourseClients.Course")
                            .Include("CourseClients.Course.CourseType")
                            .Where(c => c.ClientLicences.Any(cl => cl.LicenceNumber == licenceNumber)
                                    && c.CourseClients.Any(cc => cc.Course.OrganisationId == organisationId))
                            .ToList();
            return clients;
        }

        [Route("api/Client/SaveEntry")]
        public string SaveEntry([FromBody] FormDataCollection formBody)
        {
            string status = "";
            FormDataCollection formData = formBody;
            Client client = null;

            var Id = StringTools.GetInt("Id", ref formData);
            var Title = StringTools.GetString("Title", ref formData);
            var FirstName = StringTools.GetString("FirstName", ref formData);
            var OtherNames = StringTools.GetString("OtherNames", ref formData);
            var Surname = StringTools.GetString("Surname", ref formData);
            var DisplayName = StringTools.GetString("DisplayName", ref formData);
            var DateOfBirth = StringTools.GetDateAllowEmpty("DateOfBirth", ref formData, "Invalid date of birth");
            var Email = StringTools.GetString("Email", ref formData);
            var ConfirmEmail = StringTools.GetString("ConfirmEmail", ref formData);

            var Address = StringTools.GetString("Address", ref formData);
            var Postcode = StringTools.GetString("Postcode", ref formData);
            var Country = StringTools.GetString("Country", ref formData);

            var UserId = StringTools.GetInt("UserId", ref formData);

            var CreatedByUserId = StringTools.GetInt("CreatedByUserId", ref formData);
            var UpdatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);

            var LicenceNumber = StringTools.GetString("LicenceNumber", ref formData);
            var LicenceTypeId = StringTools.GetInt("LicenceTypeId", ref formData);
            var LicenceExpiryDate = StringTools.GetDate("LicenceExpiryDate", ref formData);
            var PhotoCardExpiryDate = StringTools.GetDate("LicencePhotoCardExpiryDate", ref formData);
            var smsReminders = StringTools.GetBool("SMSCourseReminders", ref formData);
            var emailReminders = StringTools.GetBool("EmailCourseReminders", ref formData);
            var UKLicence = StringTools.GetBool("UKLicence", ref formData);
            var isMysteryShopper = StringTools.GetBool("IsMysteryShopper", ref formData);
            //var Gender = StringTools.GetInt("Ge")

            if (Id > 0)
            {
                client = this.GetEntry(Id);
                if (client == null) client = new Client();
            }

            if (client.SMSCourseReminders != null)
            {
                client.SMSCourseReminders = smsReminders;
            }
            else
            {
                client.SMSCourseReminders = smsReminders == true ? smsReminders : client.SMSCourseReminders;
            }

            if (client.EmailCourseReminders != null)
            {
                client.EmailCourseReminders = emailReminders;
            }
            else
            {
                client.EmailCourseReminders = emailReminders == true ? emailReminders : client.EmailCourseReminders;
            }

            if (!string.IsNullOrEmpty(Title)) client.Title = Title;
            if (!string.IsNullOrEmpty(FirstName)) client.FirstName = FirstName;
            if (!string.IsNullOrEmpty(OtherNames)) client.OtherNames = OtherNames;
            if (!string.IsNullOrEmpty(Surname)) client.Surname = Surname;
            if (!string.IsNullOrEmpty(DisplayName)) client.DisplayName = DisplayName;
            client.DateOfBirth = DateOfBirth;

            if (UserId > 0 && client.UserId == null)
            {
                client.UserId = UserId;
            }

            // add a location
            if (!string.IsNullOrEmpty(Address) && !string.IsNullOrEmpty(Postcode))
            {
                var clientLocationsToDelete = new List<ClientLocation>();
                // delete all the locations that aren't equal to the passed in location (currently client's can only have one Address/Location)
                foreach (var clientLocation in client.ClientLocations)
                {
                    if (clientLocation.Location != null)
                    {
                        if (clientLocation.Location.Address != Address || clientLocation.Location.PostCode != Postcode)
                        {
                            clientLocationsToDelete.Add(clientLocation);
                        }
                    }
                }
                // can't delete the instances we are traversing through so we put them in an array and traverse that array
                foreach (var clientLocation in clientLocationsToDelete)
                {
                    var locationEntry = atlasDB.Entry(clientLocation.Location);
                    locationEntry.State = EntityState.Deleted;

                    var clientLocationEntry = atlasDB.Entry(clientLocation);
                    clientLocationEntry.State = EntityState.Deleted;
                }

                if (!client.ClientLocations.Any(c => c.Location.Address == Address && c.Location.PostCode == Postcode))
                {
                    // the input address was not found so add a new client location to the client
                    var location = new Location();
                    var clientLocation = new ClientLocation();

                    location.Address = Address;
                    location.PostCode = Postcode;

                    clientLocation.Location = location;
                    client.ClientLocations.Add(clientLocation);
                }
            }

            // add the licence
            if (!string.IsNullOrEmpty(LicenceNumber) &&
                LicenceExpiryDate != null &&
                LicenceTypeId > 0 &&
                PhotoCardExpiryDate != null)
            {
                var clientLicence = client.ClientLicences.LastOrDefault() != null ? client.ClientLicences.LastOrDefault() : new ClientLicence() ;

                clientLicence.ClientId = client.Id;
                clientLicence.LicenceExpiryDate = LicenceExpiryDate;
                clientLicence.LicenceNumber = LicenceNumber;
                clientLicence.DriverLicenceTypeId = LicenceTypeId;
                clientLicence.LicencePhotoCardExpiryDate = PhotoCardExpiryDate;
                clientLicence.UKLicence = UKLicence;

                if (!(clientLicence.Id >= 1))
                {
                    client.ClientLicences.Add(clientLicence);
                }
            }

            // add the phone numbers
            List<PhoneType> phoneTypes = atlasDB.PhoneTypes.ToList();
            var phoneNumberCount = ArrayTools.ArrayLength("ClientPhones", ref formData);
            for (int i = 0; i < phoneNumberCount; i++)
            {
                var phoneNumber = StringTools.GetString("ClientPhones[" + i + "][PhoneNumber]", ref formData);
                var phoneType = StringTools.GetString("ClientPhones[" + i + "][PhoneType][Type]", ref formData);
                var phoneTypeId = getPhoneTypeId(phoneType, phoneTypes);

                // if client's phones doesn't contain this phone number add it.
                if (!client.ClientPhones.Any(cp => cp.PhoneTypeId == phoneTypeId && cp.PhoneNumber == phoneNumber))
                {
                    var clientPhone = new ClientPhone();
                    clientPhone.PhoneTypeId = phoneTypeId;
                    clientPhone.PhoneNumber = phoneNumber;
                    clientPhone.DateAdded = DateTime.Now;

                    client.ClientPhones.Add(clientPhone);
                }
            }
            // go through the client's phone numbers and delete the numbers that weren't passed in the form (ie deleted from form).
            var phonesToBeDeleted = new List<ClientPhone>();
            foreach (var clientPhone in client.ClientPhones)
            {
                bool foundPhone = false;
                for (int i = 0; i < phoneNumberCount; i++)
                {
                    var phoneNumber = StringTools.GetString("ClientPhones[" + i + "][PhoneNumber]", ref formData);
                    var phoneType = StringTools.GetString("ClientPhones[" + i + "][PhoneType][Type]", ref formData);
                    var phoneTypeId = getPhoneTypeId(phoneType, phoneTypes);

                    if (phoneTypeId == 0 && !string.IsNullOrEmpty(phoneType))
                    {
                        phoneTypeId = getPhoneTypeId(phoneType, phoneTypes);
                    }

                    if (phoneTypeId == clientPhone.PhoneTypeId && phoneNumber == clientPhone.PhoneNumber || clientPhone.Id == 0)
                    {
                        foundPhone = true;
                        break;
                    }
                }
                if (!foundPhone)
                {
                    // we can't delete the client phones straight from the client as we are traversing the list
                    phonesToBeDeleted.Add(clientPhone);
                }
            }
            // remove all the deleted numbers from the client
            foreach (var clientPhone in phonesToBeDeleted)
            {
                //client.ClientPhones.Remove(clientPhone);
                var phoneEntry = atlasDB.Entry(clientPhone);
                phoneEntry.State = EntityState.Deleted;
            }

            // add the email address if it isn't in the client emails
            // first delete emails that aren't the same as the form's email
            var emailsToDelete = new List<ClientEmail>();

            foreach (var clientEmail in client.ClientEmails)
            {
                if (clientEmail.Email.Address != Email)
                {
                    emailsToDelete.Add(clientEmail);
                }
            }

            foreach (var clientEmail in emailsToDelete)
            {
                // delete the entry in the db
                var emailEntry = atlasDB.Entry(clientEmail.Email);
                emailEntry.State = EntityState.Deleted;

                var clientEmailEntry = atlasDB.Entry(clientEmail);
                clientEmailEntry.State = EntityState.Deleted;
            }

            if (!String.IsNullOrEmpty(Email))
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

            var clientMysteryShopper = atlasDB.ClientMysteryShoppers.Where(cms => cms.ClientId == client.Id).FirstOrDefault();

            if (isMysteryShopper == true && clientMysteryShopper == null)
            {

                var newClientMysteryShopper = new ClientMysteryShopper();
                newClientMysteryShopper.ClientId = client.Id;
                newClientMysteryShopper.AddedByUserId = UpdatedByUserId;
                newClientMysteryShopper.DateAdded = DateTime.Now;
                client.ClientMysteryShoppers.Add(newClientMysteryShopper);

            }
            else if (isMysteryShopper == false && clientMysteryShopper != null)
            {
                atlasDB.Entry(clientMysteryShopper).State = EntityState.Deleted;
            }

            if (client.Id > 0)   // do a database update
            {
                client.UpdatedByUserId = UpdatedByUserId;
                atlasDB.Clients.Attach(client);
                var entry = atlasDB.Entry(client);
                entry.State = System.Data.Entity.EntityState.Modified;
            }
            else    // add to the database
            {
                client.CreatedByUserId = CreatedByUserId;
                atlasDB.Clients.Add(client);
            }


            atlasDB.SaveChanges();
            status = "success";

            return status;
        }


        [Route("api/Client/SaveProfileEntry")]
        public string SaveProfileEntry([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;
            
            var ClientId = StringTools.GetInt("ClientId", ref formData);

            var UserId = StringTools.GetInt("UserId", ref formData);
            var UpdatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);

            var Title = StringTools.GetString("Title", ref formData);
            var FirstName = StringTools.GetString("FirstName", ref formData);
            var OtherNames = StringTools.GetString("OtherNames", ref formData);
            var Surname = StringTools.GetString("Surname", ref formData);
            var DisplayName = StringTools.GetString("DisplayName", ref formData);
            var DateOfBirth = StringTools.GetDateAllowEmpty("DateOfBirth", ref formData, "Invalid date of birth");

            var EmailId = StringTools.GetInt("EmailId", ref formData);
            var Email = StringTools.GetString("Email", ref formData);
            
            var AddressId = StringTools.GetInt("AddressId", ref formData);
            var Address = StringTools.GetString("Address", ref formData);

            var PhoneId = StringTools.GetInt("PhoneId", ref formData);
            var Phone = StringTools.GetString("Phone", ref formData);

            var GenderId = StringTools.GetInt("GenderId", ref formData);

            string status = "";

            try
            {

                // Get the Client
                Client client = atlasDB.Clients.Find(ClientId);

                if (client != null)
                {

                    // update Client
                    atlasDB.Clients.Attach(client);

                    client.UpdatedByUserId = UpdatedByUserId;
                    atlasDB.Entry(client).Property("UpdatedByUserId").IsModified = true;

                    client.GenderId = GenderId;
                    atlasDB.Entry(client).Property("GenderId").IsModified = true;

                    //if (!string.IsNullOrEmpty(Title))
                    //{
                    client.Title = Title;
                    atlasDB.Entry(client).Property("Title").IsModified = true;
                    //}

                    if (!string.IsNullOrEmpty(FirstName))
                    {
                        client.FirstName = FirstName;
                        atlasDB.Entry(client).Property("FirstName").IsModified = true;
                    }

                    //if (!string.IsNullOrEmpty(OtherNames)) {
                    client.OtherNames = OtherNames;
                    atlasDB.Entry(client).Property("OtherNames").IsModified = true;
                    //}

                    if (!string.IsNullOrEmpty(Surname))
                    {
                        client.Surname = Surname;
                        atlasDB.Entry(client).Property("Surname").IsModified = true;
                    }

                    if (!string.IsNullOrEmpty(DisplayName))
                    {
                        client.DisplayName = DisplayName;
                        atlasDB.Entry(client).Property("DisplayName").IsModified = true;
                    }

                    client.DateOfBirth = DateOfBirth;

                    atlasDB.Entry(client).Property("DateOfBirth").IsModified = true;

                    // update Address
                    if (!string.IsNullOrEmpty(Address))
                    {
                        Location location = atlasDB.Locations.Find(AddressId);

                        if (location != null)
                        {

                            atlasDB.Locations.Attach(location);

                            location.Address = Address;
                            location.DateUpdated = DateTime.Now;

                            atlasDB.Entry(location).Property("Address").IsModified = true;
                            atlasDB.Entry(location).Property("DateUpdated").IsModified = true;
                        }
                    }

                    // update Email
                    if (!string.IsNullOrEmpty(Email))
                    {
                        Email email = atlasDB.Emails.Find(EmailId);

                        if (email != null)
                        {

                            atlasDB.Emails.Attach(email);

                            email.Address = Email;

                            atlasDB.Entry(email).Property("Address").IsModified = true;
                        }
                    }

                    // update Phone
                    if (!string.IsNullOrEmpty(Phone))
                    {
                        ClientPhone clientPhone = atlasDB.ClientPhones.Find(PhoneId);

                        if (clientPhone != null)
                        {

                            atlasDB.ClientPhones.Attach(clientPhone);

                            clientPhone.PhoneNumber = Phone;

                            atlasDB.Entry(clientPhone).Property("PhoneNumber").IsModified = true;
                        }
                    }
                }

                atlasDB.SaveChanges();

                status = "Client Profile Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }


        // POST: api/Client
        [Route("api/Client/ClientReturnData")]
        public ClientReturnData Post([FromBody] FormDataCollection formBody)
        {
            var clientId = 0;
            var formData = formBody;
            var clientReturnData = new ClientReturnData();

            // Try parse the trainer Id
            if (Int32.TryParse(formBody["Id"], out clientId))
            {
            }
            else
            {
                // return "There was an error verifying your trainer information. Please retry.";
            }

            string status = "";

            if (formBody.Count() > 0)
            {
                try
                {
                    Client client = new Client();

                    var title = formBody.Get("title");
                    var DateOfBirth = StringTools.GetDateAllowEmpty("DateOfBirth", ref formData, "Invalid date of birth");
                    var isMysteryShopper = StringTools.GetBool("isMysteryShopper", ref formData);
                    var genderId = StringTools.GetInt("ClientGenders", ref formData);

                    if (clientId != 0)
                    {
                        client = atlasDB.Clients.Find(clientId);
                    }
                    else
                    {
                        ClientOrganisation clientOrganisation = new ClientOrganisation();
                        clientOrganisation.DateAdded = DateTime.Now;
                        clientOrganisation.OrganisationId = StringTools.GetInt("organisationId", ref formData);
                        client.ClientOrganisations.Add(clientOrganisation);
                    }

                    if (formBody.Get("title") == "other")
                    {
                        client.Title = formBody.Get("otherTitle");
                    }
                    else
                    {
                        client.Title = formBody.Get("title");
                    }

                    client.FirstName = formBody.Get("firstName");
                    client.OtherNames = formBody.Get("otherNames");
                    client.Surname = formBody.Get("surname");
                    client.DisplayName = formBody.Get("displayName");
                    client.DateOfBirth = DateOfBirth;
                    client.GenderId = genderId;
                    
                    var userId = StringTools.GetInt("userId", ref formData);

                    var addClientToCourseId = StringTools.GetInt("addClientToCourseId", ref formData);
                    var addedByUserId = StringTools.GetInt("addedByUserId", ref formData);
                    var updatedByUserId = StringTools.GetInt("updatedByUserId", ref formData);
                    var courseTypeId = StringTools.GetInt("courseTypeId", ref formData);
                    var UKLicence = StringTools.GetBool("UKLicence", ref formData);
                    var smsReminders = StringTools.GetBool("SMSCourseReminders", ref formData);
                    var emailReminders = StringTools.GetBool("EmailCourseReminders", ref formData);

                    var emailAddress = StringTools.GetString("email", ref formData);
                    var confirmEmailAddress = StringTools.GetString("confirmEmail", ref formData);
           
                    // DORS Data
                    var DORSAttendanceReference = StringTools.GetInt("DORSAttendanceReference", ref formData);
                    var DORSSchemeId = StringTools.GetInt("DORSSchemeId", ref formData);
                    var DORSExpiryDate = StringTools.GetDate("DORSExpiryDate", "dd/MM/yyyy", ref formData);
                    if (DORSExpiryDate != null)
                    {
                        DORSExpiryDate = DORSExpiryDate.Value.Date;
                        DORSExpiryDate = DORSExpiryDate.Value.AddHours(23).AddMinutes(59).AddSeconds(59).AddMilliseconds(59);
                    }

                    var DataValidatedAgainstDORS = StringTools.GetBool("DataValidatedAgainstDORS", ref formData);
                    var isDORSClient = StringTools.GetBool("isDORSClient", ref formData);
                    var DORSAttendanceIdentifier = StringTools.GetInt("DORSAttendanceStatusIdentifier", ref formData);

                    client.SMSCourseReminders = smsReminders;
                    client.EmailCourseReminders = emailReminders;

                    if (userId > 0)
                    {
                        client.UserId = userId;
                    }

                    if (clientId == 0)
                    {
                        client.DateCreated = DateTime.Now;
                        
                        client.CreatedByUserId = addedByUserId;
                        atlasDB.Clients.Add(client);
                    }
                    else
                    {
                        client.UpdatedByUserId = updatedByUserId;
                    }

                    if (!String.IsNullOrEmpty(emailAddress)) { 
                        if (emailAddress == confirmEmailAddress) {
                            Email email = new Email();
                            email.Address = emailAddress;

                            ClientEmail clientEmail = new ClientEmail();
                            clientEmail.Client = client;
                            clientEmail.Email = email;

                            client.ClientEmails.Add(clientEmail);
                        }
                        else
                        {
                            throw new Exception("Emails don't match");
                        }
                    }
                    
                    Location location = new Location();
                    location.Address = FormatAddress(formBody);
                    location.PostCode = formBody.Get("postcode");

                    if (!string.IsNullOrEmpty(location.PostCode)) location.PostCode = location.PostCode.ToUpper();

                    atlasDB.Locations.Add(location);

                    ClientLocation clientLocation = new ClientLocation();
                    clientLocation.Location = location;
                    clientLocation.Client = client;

                    atlasDB.ClientLocations.Add(clientLocation);

                    string licenceTypeId = formBody.Get("licenceTypeId");
                    string licenceNo = formBody.Get("licenceNo");

                    //string licenceExpiryDate = formBody.Get("licenceExpiryDate");
                    if (licenceNo != null)
                    {
                        ClientLicence clientLicence = new ClientLicence();
                        clientLicence.Client = client;
                        clientLicence.LicenceNumber = formBody.Get("licenceNo");

                        if (!string.IsNullOrEmpty(licenceTypeId))
                        {
                            clientLicence.DriverLicenceTypeId = Int32.Parse(licenceTypeId);
                        }

                        //DateTime photocardExpiry = DateTime.Parse(formBody["licencePhotocardExpiryDate"]);
                        //clientLicence.LicencePhotoCardExpiryDate = photocardExpiry.Date;

                        clientLicence.LicenceExpiryDate = StringTools.GetDate("licenceExpiryDate", "dd-MMM-yyyy", ref formData);
                        clientLicence.LicencePhotoCardExpiryDate = StringTools.GetDate("licencePhotocardExpiryDate", "dd-MMM-yyyy", ref formData);

                        //CultureInfo uk = new CultureInfo("en-GB");
                        //if(licenceExpiryDate != null)
                        //{
                        //    string[] licenceExpiryDateArray = licenceExpiryDate.Split("/".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
                        //    int year, month, day;

                        //    if (licenceExpiryDateArray.Length == 3)
                        //    {
                        //        year = Int32.Parse(licenceExpiryDateArray[2]);
                        //        month = Int32.Parse(licenceExpiryDateArray[1]);
                        //        day = Int32.Parse(licenceExpiryDateArray[0]);
                        //        // doing this to get around IE passing the client browser's culture as well
                        //        DateTime expiryDate = new DateTime(year, month, day);
                        //        clientLicence.LicenceExpiryDate = expiryDate;
                        //    }
                        //}

                        clientLicence.UKLicence = UKLicence;
                        client.ClientLicences.Add(clientLicence);
                    }

                    List<PhoneType> phoneTypes = atlasDB.PhoneTypes.ToList();

                    int i = 0;
                    while (phoneNumberExists(formBody, i))
                    {
                        string phoneNumberKey = "phoneNumbers[" + i + "][number]";
                        string phoneTypeKey = "phoneNumbers[" + i + "][type]";
                        ClientPhone clientPhone = new ClientPhone();
                        clientPhone.PhoneNumber = formBody.Get(phoneNumberKey);
                        clientPhone.PhoneTypeId = getPhoneTypeId((string)formBody.Get(phoneTypeKey), phoneTypes);
                        client.ClientPhones.Add(clientPhone);
                        i++;
                    }

                    // if we have a value for the form parameter "addClientToCourseId" then add the client to the course
                    if (addClientToCourseId > 0 && addedByUserId > 0)
                    {
                        CourseClient courseClient = new CourseClient();
                        courseClient.CourseId = addClientToCourseId;
                        courseClient.AddedByUserId = addedByUserId;
                        courseClient.DateAdded = DateTime.Now;

                        var courseTypeFeeController = new CourseTypeFeeController();
                        var courseTypeFee = courseTypeFeeController.GetCurrentCourseTypeFee(courseTypeId);

                        courseClient.TotalPaymentDue = courseTypeFee;
                        courseClient.UpdatedByUserId = addedByUserId;

                        client.CourseClients.Add(courseClient);
                        status = "addedToCourse";
                    }

                    // save client DORS data
                    if (isDORSClient && DORSSchemeId > 0)
                    {
                        var dorsAttendanceState = getDORSAttendanceState(DORSAttendanceIdentifier);
                        var clientDorsData = new ClientDORSData();
                        clientDorsData.DORSAttendanceRef = DORSAttendanceReference;
                        clientDorsData.DataValidatedAgainstDORS = DataValidatedAgainstDORS;
                        clientDorsData.DateCreated = DateTime.Now;
                        clientDorsData.DORSSchemeId = DORSSchemeId;
                        clientDorsData.ExpiryDate = DORSExpiryDate;
                        clientDorsData.IsMysteryShopper = isMysteryShopper;
                        if (dorsAttendanceState != null)
                        {
                            clientDorsData.DORSAttendanceStateId = dorsAttendanceState.Id;
                        }
                        client.ClientDORSDatas.Add(clientDorsData);
                    }

                    if (isMysteryShopper == true)
                    {
                        var clientMysteryShopper = new ClientMysteryShopper();
                        clientMysteryShopper.ClientId = clientId;
                        clientMysteryShopper.AddedByUserId = addedByUserId;
                        clientMysteryShopper.DateAdded = DateTime.Now;
                        client.ClientMysteryShoppers.Add(clientMysteryShopper);
                    }

                    //client.DateCreated = DateTime.Now;
                    client.DateUpdated = DateTime.Now;

                    atlasDB.SaveChanges();
                    clientReturnData.ClientId = client.Id;


                    if (string.IsNullOrEmpty(status))
                    {
                        clientReturnData.Status = "success";
                    }
                    else
                    {
                        clientReturnData.Status = status;
                    }
                }
                catch (DbEntityValidationException ex)
                {
                    clientReturnData.Status = "error: data validation error";
                }
                catch (Exception ex)
                {
                    clientReturnData.ClientId = null;
                    clientReturnData.Status = "An error occurred: " + ex.Message + "::: Inner Exception: " + ex.InnerException + "::: Stack Trace: " + ex.StackTrace;
                }
            }
            else
            {
                clientReturnData.ClientId = null;
                clientReturnData.Status = "error: JSON not sent.";
            }
            return clientReturnData;
        }

        private DORSAttendanceState getDORSAttendanceState(int dorsAttendanceIdentifier)
        {
            var dorsAttendanceState = atlasDB.DORSAttendanceStates
                                                .Where(das => das.DORSAttendanceStateIdentifier == dorsAttendanceIdentifier)
                                                .FirstOrDefault();
            return dorsAttendanceState;
        }

        /// <summary>
        /// This function handles the tolerances in the new DORS+ V2 system.
        /// The tolerance dictates how many clients are allowed on a course with no trainer.
        /// </summary>
        /// <param name="courseId"></param>
        /// <returns>true if there is space on the course, false if there isn't space</returns>
        bool spaceAvailableOnCourse(int courseId)
        {
            var spaceAvailable = false;
            var course = atlasDB.Course
                                .Include(c => c.CourseTrainer)
                                .Where(c => c.Id == courseId).FirstOrDefault();

            // find out how many trainers on the course
            var howManyTrainers = course.CourseTrainer.Count;

            // find out the maximum allowed clients with this number of trainers
            // var maximumClientsWithXTrainers = TODO: integrate w rob's db fn

            // is there room for one more client?

            return spaceAvailable;
        }

        [AuthorizationRequired]
        [Route("api/client/createEmailReference")]
        [HttpPost]
        public object CreateEmailReference([FromBody] FormDataCollection formBody)
        {

            var clientId = 0;
            var organisationId = 0;
            var clientName = formBody["clientName"];
            var clientEmail = formBody["emailAddress"];

            if (Int32.TryParse(formBody["clientId"], out clientId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("We can't verify your client Id."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }


            if (Int32.TryParse(formBody["organisationId"], out organisationId))
            {
            }
            else
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("We can't verify your organisation Id."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            var random = new Random();
            var URL = System.Configuration.ConfigurationManager.AppSettings["frontendUrl"].ToString();
            var reference = random.Next(10000, 99999) + DateTime.Now.ToString("yyyyMMddHHmmss");
            var confirmationURL = URL + "/clientemailconfirm/reference/" + reference;
            var messageContent = "Can you please confirm your email by clicking the link below" + System.Environment.NewLine + "< a href='" + confirmationURL + "'>" + confirmationURL + "</a>";

            try
            {

                // Update the client record
                var _client = atlasDB.Clients
                    .Include("ClientLicence")
                    .Include("ClientEmails")
                    .Include("ClientEmails.Email")
                    .Include("ClientLocations")
                    .Include("ClientLocations.Location")
                    .Include("ClientPhones")
                    .Include("ClientPhones.PhoneType")
                    .Include(c => c.ClientPreviousIds)
                    .Include(c => c.User_User)
                    .Include(c => c.User_CreatedByUser)
                    .Include(c => c.User_LockedByUser)
                    .Include(c => c.User_UpdatedByUser)
                    .Where(c => c.Id == clientId)
                    .FirstOrDefault();

                _client.EmailConfirmReference = reference;
                _client.EmailedConfirmed = true;
                var entry = atlasDB.Entry(_client);
                entry.State = System.Data.Entity.EntityState.Modified;

                // Get the FROM Name & Email
                var organisationSystemConfiguration = atlasDB.OrganisationSystemConfigurations
                    .Where(
                        org => org.OrganisationId == organisationId
                    )
                    .FirstOrDefault();





                // Send email - put in method
                ScheduledEmail scheduledEmail = new ScheduledEmail();
                scheduledEmail.FromName = organisationSystemConfiguration.FromName;
                scheduledEmail.FromEmail = organisationSystemConfiguration.FromEmail;
                scheduledEmail.Content = messageContent;
                scheduledEmail.Subject = "Email Confirmation";
                scheduledEmail.DateCreated = DateTime.Now;
                scheduledEmail.Disabled = false;
                scheduledEmail.ASAP = true;
                scheduledEmail.ScheduledEmailStateId = 1;
                scheduledEmail.SendAtempts = 0;
                scheduledEmail.SendAfter = DateTime.Now;
                scheduledEmail.DateScheduledEmailStateUpdated = DateTime.Now;

                ScheduledEmailTo scheduledEmailTo = new ScheduledEmailTo();
                scheduledEmailTo.ScheduledEmail = scheduledEmail;
                scheduledEmailTo.Name = clientName;
                scheduledEmailTo.Email = clientEmail;
                scheduledEmailTo.BCC = false;
                scheduledEmailTo.CC = false;

                OrganisationScheduledEmail organisationScheduledEmail = new OrganisationScheduledEmail();
                organisationScheduledEmail.ScheduledEmail = scheduledEmail;
                organisationScheduledEmail.OrganisationId = organisationId;

                atlasDB.ScheduledEmailTo.Add(scheduledEmailTo);
                atlasDB.OrganisationScheduledEmails.Add(organisationScheduledEmail);

                atlasDB.SaveChanges();

                return _client;

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

        }

        [Route("api/Client/ConfirmEmail")]
        [HttpPost]
        public object ConfirmEmail([FromBody] FormDataCollection formBody)
        {
            string status = string.Empty;

            if (formBody.Count() > 0)
            {
                FormDataCollection formData = formBody;

                var confirmEmailRefNo = StringTools.GetString("reference", ref formData);

                if (atlasDB.Clients.Any(c => c.EmailConfirmReference == confirmEmailRefNo))
                {
                    var query = atlasDB.Clients.Where(c => c.EmailConfirmReference == confirmEmailRefNo).FirstOrDefault();
                    query.EmailedConfirmed = true;

                    try
                    {
                        atlasDB.SaveChanges();
                        status = "success";
                    }
                    catch (DbEntityValidationException ex)
                    {
                        throw new HttpResponseException(
                            new HttpResponseMessage(HttpStatusCode.InternalServerError)
                            {
                                Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                                ReasonPhrase = "We can't process your request."
                            }
                        );
                    }
                }

                else
                {

                    throw new HttpResponseException(
                            new HttpResponseMessage(HttpStatusCode.InternalServerError)
                            {
                                Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                                ReasonPhrase = "We can't process your request."
                            }
                        );

                }
            }
            return status;
        }


        [HttpPost]
        [Route("api/client/removeFromCourse/")]
        public bool removeFromCourse([FromBody] FormDataCollection formBody)
        {
            bool removed = false;
            var removeFromCourseParameters = formBody.ReadAs<RemoveFromCourseParameters>();
            int clientId = removeFromCourseParameters.clientId;
            int courseId = removeFromCourseParameters.courseId;
            int userId = removeFromCourseParameters.userId;
            string notes = removeFromCourseParameters.notes;
            bool isAdmin = false;
            var message = "";
            var course = atlasDB.Course
                                .Include(c => c.CourseClients)
                                .Include(c => c.DORSCourses)
                                .Include(c => c.Organisation)
                                .Include(c => c.Organisation.OrganisationAdminUsers)
                                .Include(c => c.CourseType)
                                .Include(c => c.CourseType.DORSSchemeCourseTypes)
                                .Where(c => c.Id == courseId)
                                .FirstOrDefault();

            var courseClient = atlasDB.CourseClients
                                    .Where(cc => cc.ClientId == clientId && cc.CourseId == courseId)
                                    .OrderByDescending(ccr => ccr.Id)
                                    .FirstOrDefault();

            if (course != null && courseClient != null)
            {
                // does the user have permission to remove this client?
                if (course.Organisation != null && course.Organisation.OrganisationAdminUsers.Count(oau => oau.UserId == userId) > 0)
                {
                    isAdmin = true;
                }
                else
                {
                    var systemAdminUser = atlasDB.SystemAdminUsers.Where(sau => sau.UserId == userId).FirstOrDefault();
                    if (systemAdminUser != null) isAdmin = true;
                }
                
                // If this is a DORS Course then create a new row on table "DORSClientCourseRemoval"
                if (course.DORSCourses.Count() > 0)
                {
                    var dorsClientCourseRemoval = new DORSClientCourseRemoval();
                    dorsClientCourseRemoval.ClientId = clientId;
                    dorsClientCourseRemoval.CourseId = courseId;
                    dorsClientCourseRemoval.DORSNotified = false;
                    dorsClientCourseRemoval.Notes = notes;
                    dorsClientCourseRemoval.DateRequested = DateTime.Now;

                    atlasDB.DORSClientCourseRemovals.Add(dorsClientCourseRemoval);
                }

                // Remove the Client from the Course by adding a new row in the table "CourseClientRemoved"
                var courseClientRemoved = new CourseClientRemoved();
                courseClientRemoved.ClientId = clientId;
                courseClientRemoved.CourseId = courseId;
                courseClientRemoved.RemovedByUserId = userId;
                courseClientRemoved.DateRemoved = DateTime.Now;
                courseClientRemoved.DateAddedToCourse = courseClient.DateAdded;
                courseClientRemoved.CourseClientId = courseClient.Id;
                courseClientRemoved.PartOfDorsCourseTransfer = false;

                atlasDB.CourseClientRemoveds.Add(courseClientRemoved);

                // Add the Notes to the Client Notes(ClientNote Table)
                if (!string.IsNullOrEmpty(notes))
                {
                    var note = new Note();
                    note.CreatedByUserId = userId;
                    note.DateCreated = DateTime.Now;
                    note.Note1 = notes;
                    // find the General NoteType
                    var generalNoteType= atlasDB.NoteType.Where(nt => nt.Name == "General").FirstOrDefault();
                    if(generalNoteType != null)
                    {
                        note.NoteTypeId = generalNoteType.Id;
                    }
                    else
                    {
                        // this shouldn't happen but if it does...
                        message = "General Note Type not found.";
                    }

                    var clientNote = new ClientNote();
                    clientNote.ClientId = clientId;
                    clientNote.Note = note;
                    atlasDB.ClientNotes.Add(clientNote);
                }
                atlasDB.SaveChanges();
                

                // notify DORS of the client's course removal
                if (course.DORSCourses.Count() > 0)
                {
                    if (course.CourseType != null)
                    {
                        if (course.CourseType.DORSSchemeCourseTypes.Count() > 0)
                        {
                            var dorsSchemeId = course.CourseType.DORSSchemeCourseTypes.First().DORSSchemeId;
                            var clientDORSData = atlasDB.ClientDORSDatas
                                                        .Include(cdd => cdd.Client)
                                                        .Include(cdd => cdd.Client.ClientLicences)
                                                        .Where(cdd => cdd.ClientId == clientId && cdd.DORSSchemeId == dorsSchemeId)
                                                        .FirstOrDefault();
                            var dorsWebService = new DORSWebServiceInterfaceController();
                            if(clientDORSData != null)
                            {
                                if (clientDORSData.DORSAttendanceRef != null && clientDORSData.DORSAttendanceRef > 0)
                                {
                                    // log the dors request in the DORSCLientCourseRemoval table
                                    var dorsClientCourseRemoval = atlasDB.DORSClientCourseRemovals
                                                                            .Where(dccr => dccr.ClientId == clientId && dccr.CourseId == courseId)
                                                                            .FirstOrDefault();
                                    if (dorsClientCourseRemoval == null)
                                    {
                                        dorsClientCourseRemoval = new DORSClientCourseRemoval();
                                        dorsClientCourseRemoval.CourseId = courseId;
                                        dorsClientCourseRemoval.ClientId = clientId;
                                        dorsClientCourseRemoval.DateDORSNotificationAttempted = DateTime.Now;
                                        dorsClientCourseRemoval.DateRequested = DateTime.Now;
                                        dorsClientCourseRemoval.IsMysteryShopper = false;
                                        dorsClientCourseRemoval.NumberOfDORSNotificationAttempts = 1;
                                    }
                                    else
                                    {
                                        dorsClientCourseRemoval.DateDORSNotificationAttempted = DateTime.Now;
                                        var numberOfAttempts = dorsClientCourseRemoval.NumberOfDORSNotificationAttempts;
                                        if (numberOfAttempts == null) numberOfAttempts = 0;
                                        dorsClientCourseRemoval.NumberOfDORSNotificationAttempts = numberOfAttempts++;
                                    }

                                    // notify DORS of the cancelled booking
                                    removed = dorsWebService.CancelBooking((int) clientDORSData.DORSAttendanceRef, course.Organisation.Id);

                                    if (!removed)
                                    {
                                        message = "DORS Course booking not cancelled.";
                                    }
                                    else
                                    {
                                        dorsClientCourseRemoval.DORSNotified = true;
                                        dorsClientCourseRemoval.DateTimeDORSNotified = DateTime.Now;

                                        // get the client back to "booking pending"
                                        var dorsTools = new DORSTools();
                                        clientDORSData.DORSAttendanceStateId = dorsTools.GetDORSAttendanceStateId((int)DORSAttendanceStates.BookingPending, atlasDB);
                                        clientDORSData.DataValidatedAgainstDORS = false;
                                        
                                        var dbEntry = atlasDB.Entry(clientDORSData);
                                        dbEntry.State = EntityState.Modified;

                                        // set the CourseDORSCLient entry to have dorsnotified to true so no previous commands get executed
                                        var courseDORSClients = atlasDB.CourseDORSClients.Where(cdc => cdc.ClientId == clientId).ToList();
                                        foreach(var courseDORSClient in courseDORSClients)
                                        {
                                            courseDORSClient.DORSNotified = true;
                                            courseDORSClient.DateDORSNotified = DateTime.Now;

                                            var entry = atlasDB.Entry(courseDORSClient);
                                            entry.State = EntityState.Modified;
                                        }

                                        //if (clientDORSData.Client != null)
                                        //{
                                        //    // perform dors check to inform our database record of the latest DORS action
                                        //    if(clientDORSData.Client.ClientLicences.Where(cl => cl.LicenceExpiryDate > DateTime.Now).Count() > 0)
                                        //    {
                                        //        var clientLicenceNumber = clientDORSData.Client.ClientLicences
                                        //                                                        .Where(cl => cl.LicenceExpiryDate > DateTime.Now)
                                        //                                                        .First()
                                        //                                                        .LicenceNumber;
                                        //        dorsWebService.PerformDORSCheck(clientId, clientLicenceNumber);
                                        //    }
                                        //}

                                    }
                                    if(dorsClientCourseRemoval.Id > 0)
                                    {
                                        var entry = atlasDB.Entry(dorsClientCourseRemoval);
                                        entry.State = EntityState.Modified;
                                    }
                                    else
                                    {
                                        atlasDB.DORSClientCourseRemovals.Add(dorsClientCourseRemoval);
                                    }
                                    atlasDB.SaveChanges();
                                }
                                else
                                {
                                    message = "Couldn't find client's DORS attendance ref, DORS Course booking not cancelled.";
                                }
                            }
                            else
                            {
                                message = "Couldn't find client's DORS data, DORS Course booking not cancelled.";
                            }
                        }
                        else
                        {
                            message = "CourseType is null, DORS Course booking not cancelled.";
                        }
                    }
                    else
                    {
                        message = "CourseType is null, DORS Course booking not cancelled.";
                    }
                }
                else
                {
                    removed = true;
                }
            }
            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return removed;
        }

        [HttpGet]
        [Route("api/client/transferToNewCourse/{clientId}/{fromCourseId}/{toCourseId}/{userId}")]
        public bool transferToNewCourse(int clientId, int fromCourseId, int toCourseId, int userId)
        {
            return transferToNewCourse(clientId, fromCourseId, toCourseId, userId, "");
        }

        [HttpGet]
        [Route("api/client/transferToNewCourse/{clientId}/{fromCourseId}/{toCourseId}/{userId}/{notes}")]
        public bool transferToNewCourse(int clientId, int fromCourseId, int toCourseId, int userId, string notes)
        {
            var message = "";
            var transferred = false;
            try
            {
                // check to see if the client is a dors client 
                // if they are, check to see that their DORS status is at "course booked"
                // check that the new course is a DORS course
                var isDORSClient = false;
                var dorsStatusAtCourseBooked = false;
                var isDORSCourse = false;
                var validDORSExpiryDate = false;
                var client = atlasDB.Clients
                                    .Include(c => c.ClientDORSDatas)
                                    .Include(c => c.ClientLicences)
                                    .Where(c => c.Id == clientId).FirstOrDefault();
                
                if(client.ClientDORSDatas.Count() > 0)  // a dors client
                {
                    isDORSClient = true;
                    var dorsWebService = new DORSWebServiceInterfaceController();
                    var clientLicence = client.ClientLicences.FirstOrDefault();
                    if(clientLicence != null)
                    {
                        var dorsClientCourseAttendances = dorsWebService.PerformDORSCheck(clientId, clientLicence.LicenceNumber);
                        // refresh the client to see the latest dors status.
                        client = atlasDB.Clients
                                        .Include(c => c.ClientDORSDatas)
                                        .Include(c => c.ClientDORSDatas.Select(cdd => cdd.DORSAttendanceState))
                                        .Where(c => c.Id == clientId).FirstOrDefault();
                        var course = atlasDB.Course
                                            .Include(c => c.DORSCourses)
                                            .Include(c => c.CourseType)
                                            .Include(c => c.CourseType.DORSSchemeCourseTypes)
                                            .Include(c => c.CourseVenue)
                                            .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                                            .Include(c => c.CourseDORSForceContracts)
                                            .Include(c => c.CourseDate)
                                            .Where(c => c.Id == toCourseId).FirstOrDefault();
                        var dorsSchemeCourseType = course.CourseType.DORSSchemeCourseTypes.FirstOrDefault();
                        if(dorsSchemeCourseType != null)
                        {
                            var dorsOffer = client.ClientDORSDatas
                                                    .Where(cdd => cdd.DORSSchemeId == dorsSchemeCourseType.DORSSchemeId).FirstOrDefault();
                            if(dorsOffer != null)
                            {
                                // there was a strange bug where the dorsattendancestate entity wasn't being attached by the linq
                                // this if statement gets around that.
                                if(dorsOffer.DORSAttendanceState == null && (dorsOffer.DORSAttendanceStateId == null ? false : ((int)dorsOffer.DORSAttendanceStateId > 0)))
                                {
                                    var dorsAttendanceState = atlasDB.DORSAttendanceStates.Where(das => das.Id == (int)dorsOffer.DORSAttendanceStateId).FirstOrDefault();
                                    if(dorsAttendanceState != null)
                                    {
                                        dorsStatusAtCourseBooked = dorsAttendanceState.Name.Contains("Booked");
                                    }
                                }
                                if (dorsOffer.DORSAttendanceState != null && dorsStatusAtCourseBooked == false)
                                {
                                    dorsStatusAtCourseBooked = dorsOffer.DORSAttendanceState.Name.Contains("Booked");
                                }
                            }
                            // check to see if the offer expiry date won't expire before the course's start date
                            var courseStartDate = course.CourseDate.Where(cd => cd.DateStart != null).OrderBy(cd => cd.DateStart).FirstOrDefault();
                            if(courseStartDate != null)
                            {
                                if (courseStartDate.DateStart <= dorsOffer.ExpiryDate)
                                {
                                    validDORSExpiryDate = true;
                                }
                            }
                        }
                        
                        // check CourseType, Venue and ForceContract to see that this is a DORS Course
                        if(course.CourseType != null)
                        {
                            if (course.CourseType.DORSOnly == null ? false : (bool)course.CourseType.DORSOnly)
                            {
                                if(course.CourseVenue.Count() > 0)
                                {
                                    if(course.CourseVenue.First().Venue != null)
                                    {
                                        if (course.CourseVenue.First().Venue.DORSVenue)
                                        {
                                            if (course.CourseDORSForceContracts.Count() > 0)
                                            {
                                                isDORSCourse = true;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        message = "Course doesn't have a venue.";
                                    }
                                }
                                else
                                {
                                    message = "Course doesn't have a venue.";
                                }
                            }
                        }
                        else
                        {
                            message = "Error: CourseType is null.";
                        }
                    }
                }
                if (!isDORSClient || (isDORSClient && isDORSCourse && dorsStatusAtCourseBooked && validDORSExpiryDate))
                {
                    atlasDB.uspCourseTransferClientWithNotes(fromCourseId, toCourseId, clientId, clientId, "Manual Transfer Request", userId, notes);
                    transferred = true;
                }
                else
                {
                    if (!isDORSCourse)
                    {
                        message = "Error: Trying to transfer a DORS client to a non DORS course.";
                    }
                    else
                    {
                        if (!dorsStatusAtCourseBooked)
                        {
                            message = "Error: DORS client is not at 'Booked' or 'Booked and Paid' status, the transfer was not performed.";
                        }
                        else if (!validDORSExpiryDate)
                        {
                            message = "Error: Course's start date is after client's offer expiry date.";
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return transferred;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/client/downloadDocument/{Id}/{UserId}/{clientId}/{UserSelectedOrganisationId}/{DocumentName}")]
        public HttpResponseMessage downloadDocument(int Id, int UserId, int ClientId, int UserSelectedOrganisationId, string DocumentName)
        {
            HttpResponseMessage response = null;

            if (!this.UserMatchesToken(UserId, Request))
            {
                return response;
            }

            if (!this.UserAuthorisedForClient(UserId, ClientId, UserSelectedOrganisationId, UserLevel.OrganisationUser))
            {
                return response;
            }

            //Confirm that the document relates to the client
            var clientDocument = atlasDB.ClientDocuments
                                            .Include(cd => cd.Document)
                                            .Where(x => x.ClientId == ClientId && x.DocumentId == Id).FirstOrDefault();

            if (clientDocument != null)
            {
                var documentController = new DocumentController();
                var documentId = clientDocument.DocumentId;
                if (documentId != null)
                {
                    // 
                    var documentComment = "Document Id: " + clientDocument.DocumentId +" was downloaded.";
                    if (clientDocument.Document != null) {
                        documentComment = "Document '" + clientDocument.Document.Title + "' was downloaded.";
                    }

                    // log the client document download to the client history
                    var clientChangeLog = new ClientChangeLog();
                    clientChangeLog.ClientId = ClientId;
                    clientChangeLog.ChangeType = "Document Download";
                    clientChangeLog.Comment = documentComment;
                    clientChangeLog.DateCreated = DateTime.Now;
                    clientChangeLog.AssociatedUserId = UserId;

                    atlasDB.ClientChangeLogs.Add(clientChangeLog);
                    atlasDB.SaveChanges();

                    response = documentController.DownloadFileContents((int)documentId, UserId, DocumentName);
                }
            }
            return response;
        }

        [AuthorizationRequired]
        [Route("api/client/saveclientidentifier")]
        [HttpPost]
        public object SaveClientIdentifier([FromBody] FormDataCollection formBody)
        {
            try
            {
                var formData = formBody;

                var clientId = StringTools.GetInt("Id", ref formData);
                var userId = StringTools.GetInt("UserId", ref formData);
                var uniqueIdentifier = StringTools.GetString("Identifier", ref formData);

                var identifierExists = atlasDB.ClientIdentifiers.Where(x => x.UniqueIdentifier == uniqueIdentifier).Count() > 0;
                if (identifierExists)
                {
                    return "failed-notunique";
                }

                var newIdentifier = new ClientIdentifier
                {
                    ClientId = clientId,
                    CreatedByUserId = userId,
                    UniqueIdentifier = uniqueIdentifier
                };
                atlasDB.ClientIdentifiers.Add(newIdentifier);
                atlasDB.SaveChanges();
                return "success";
            }
            catch (Exception ex)
            {
                return "failed";
            }
        }

        [HttpGet]
        [Route("api/client/GetClientLock/{clientId}/{organisationId}/{userId}")]
        public ClientLockJSON GetClientLock(int clientId, int organisationId,  int userId)
        {
            var clientLock = atlasDBViews.vwClientDetails
                                .Where(c => c.ClientId == clientId && c.OrganisationId == organisationId  && c.LockedByUserId != null)
                                .Take(1)
                                .FirstOrDefault();


            var clientLockJSON = new ClientLockJSON()
            {
                ClientId = -1,
                IsReadOnly = false,
                IsLockedByCurrentUser = false,
                LockedByUserName = string.Empty
            };

            if (clientLock == null)
            {
                clientLockJSON.ClientId = -1;
                clientLockJSON.IsReadOnly = false;
                clientLockJSON.IsLockedByCurrentUser = false;
                clientLockJSON.LockedByUserName = string.Empty;
            }
            else if (clientLock.LockedByUserId == userId)
            {
                clientLockJSON.ClientId = clientLock.ClientId;
                clientLockJSON.IsReadOnly = false;
                clientLockJSON.IsLockedByCurrentUser = true;
                clientLockJSON.LockedByUserName = clientLock.LockedByUserName;
            }
            else
            {
                clientLockJSON.ClientId = clientLock.ClientId;
                clientLockJSON.IsReadOnly = true;
                clientLockJSON.IsLockedByCurrentUser = false;
                clientLockJSON.LockedByUserName = clientLock.LockedByUserName;
            }

            // JavaScriptSerializer serializer = new JavaScriptSerializer();
            //return serializer.Serialize(clientView);
            return clientLockJSON;
        }

        [HttpGet]
        [Route("api/client/AddClientLock/{clientId}/{userId}")]
        public bool AddClientLock(int clientId, int userId)
        {
            try
            {
                var newClientView = new ClientView
                {
                    ClientId = clientId,
                    ViewedByUserId = userId,
                    DateTimeViewed = DateTime.Now
                };
                var entry = atlasDB.Entry(newClientView);
                entry.State = System.Data.Entity.EntityState.Added;

                var updateClient = new Client();
                updateClient.Id = clientId;
                updateClient.Locked = true;
                updateClient.LockedByUserId = userId;
                updateClient.DateTimeLocked = DateTime.Now;

                atlasDB.Clients.Attach(updateClient);
                atlasDB.Entry(updateClient).Property("Locked").IsModified = true;
                atlasDB.Entry(updateClient).Property("LockedByUserId").IsModified = true;
                atlasDB.Entry(updateClient).Property("DateTimeLocked").IsModified = true;
                atlasDB.SaveChanges();

                //entry.State = System.Data.Entity.EntityState.Detached;

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [HttpGet]
        [Route("api/client/RemoveClientLock/{Id}")]
        public bool RemoveClientLock(int Id)
        {
            try
            {
                var updateClient = new Client();
                updateClient.Id = Id;
                updateClient.Locked = false;
                updateClient.LockedByUserId = null;
                updateClient.DateTimeLocked = null;

                atlasDB.Clients.Attach(updateClient);
                atlasDB.Entry(updateClient).Property("Locked").IsModified = true;
                atlasDB.Entry(updateClient).Property("LockedByUserId").IsModified = true;
                atlasDB.Entry(updateClient).Property("DateTimeLocked").IsModified = true;

                atlasDB.SaveChanges();

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [AuthorizationRequired]
        [Route("api/Client/GetClientOnlineEmailChangeRequest/{ClientId}")]
        [HttpGet]
        public ClientOnlineEmailChangeRequestViewJSON GetClientOnlineEmailChangeRequest(int clientId)
        {
            return atlasDB.ClientOnlineEmailChangeRequests
                .Where(u => u.ClientId == clientId && u.DateConfirmed == null)
                .Select(
                    x => new ClientOnlineEmailChangeRequestViewJSON()
                    {
                        Id = x.Id,
                        ClientId = x.ClientId,
                        PreviousEmailAddress = x.PreviousEmailAddress,
                        NewEmailAddress = x.NewEmailAddress,
                    })
                .FirstOrDefault();
        }

        [AuthorizationRequired]
        [Route("api/Client/CancelEmailChangeRequest/{clientOnlineEmailChangeRequestId}")]
        [HttpGet]
        public ClientOnlineEmailChangeRequestViewJSON CancelEmailChangeRequest(int clientOnlineEmailChangeRequestId)
        {
            var clientOnlineEmailChangeRequestJSON = new ClientOnlineEmailChangeRequestViewJSON();
            var clientOnlineEmailChangeRequest = new ClientOnlineEmailChangeRequest();

            try
            {
                clientOnlineEmailChangeRequest = atlasDB.ClientOnlineEmailChangeRequests
                    .Where(x => x.Id == clientOnlineEmailChangeRequestId)
                    .FirstOrDefault();

                atlasDB.Entry(clientOnlineEmailChangeRequest).State = EntityState.Deleted;

                atlasDB.SaveChanges();

                //succes so return only the status as now ClientOnlineEmailChangeRequest record exists
                clientOnlineEmailChangeRequestJSON.Status = "Email Change Cancelled";
            }
            catch (Exception ex)
            {
                //failure so return the original ClientOnlineEmailChangeRequestJSON plus the Status
                clientOnlineEmailChangeRequestJSON.Id = clientOnlineEmailChangeRequest.Id;
                clientOnlineEmailChangeRequestJSON.ClientId = clientOnlineEmailChangeRequest.ClientId;
                clientOnlineEmailChangeRequestJSON.PreviousEmailAddress = clientOnlineEmailChangeRequest.PreviousEmailAddress;
                clientOnlineEmailChangeRequestJSON.NewEmailAddress = clientOnlineEmailChangeRequest.NewEmailAddress;
                clientOnlineEmailChangeRequestJSON.Status = "There was an error with our service. If the problem persists please contact support";
            }

            return clientOnlineEmailChangeRequestJSON;

        }

        [AuthorizationRequired]
        [Route("api/Client/ConfirmEmailChangeRequest/{clientOnlineEmailChangeRequestId}/{confirmationCode}")]
        [HttpGet]
        public ClientOnlineEmailChangeRequestViewJSON ConfirmEmailChangeRequest(int clientOnlineEmailChangeRequestId, string confirmationCode)
        {
            var clientOnlineEmailChangeRequestJSON = new ClientOnlineEmailChangeRequestViewJSON();
            var clientOnlineEmailChangeRequest = new ClientOnlineEmailChangeRequest();

            try
            {
                clientOnlineEmailChangeRequest = atlasDB.ClientOnlineEmailChangeRequests
                    .Where(x => x.Id == clientOnlineEmailChangeRequestId)
                    .FirstOrDefault();

                if (clientOnlineEmailChangeRequest != null && clientOnlineEmailChangeRequest.ConfirmationCode == confirmationCode)
                {
                    clientOnlineEmailChangeRequest.DateConfirmed = DateTime.Now;
                    atlasDB.Entry(clientOnlineEmailChangeRequest).State = EntityState.Modified;
                    atlasDB.SaveChanges();

                    //succes so return only the status as now ClientOnlineEmailChangeRequest record exists
                    clientOnlineEmailChangeRequestJSON.EmailUpdated = true;
                    clientOnlineEmailChangeRequestJSON.NewEmailAddress = clientOnlineEmailChangeRequest.NewEmailAddress;
                    clientOnlineEmailChangeRequestJSON.Status = "Email Change Confirmed";
                }
                else
                {
                    //code do not nmatch so return the original ClientOnlineEmailChangeRequestJSON plus the Status
                    clientOnlineEmailChangeRequestJSON.Id = clientOnlineEmailChangeRequest.Id;
                    clientOnlineEmailChangeRequestJSON.ClientId = clientOnlineEmailChangeRequest.ClientId;
                    clientOnlineEmailChangeRequestJSON.PreviousEmailAddress = clientOnlineEmailChangeRequest.PreviousEmailAddress;
                    clientOnlineEmailChangeRequestJSON.NewEmailAddress = clientOnlineEmailChangeRequest.NewEmailAddress;
                    clientOnlineEmailChangeRequestJSON.Status = "Invalid Confirmation Code";

                }
            }
            catch (Exception ex)
            {
                //failure so return the oroginal ClientOnlineEmailChangeRequestJSON plus the Status
                clientOnlineEmailChangeRequestJSON.Id = clientOnlineEmailChangeRequest.Id;
                clientOnlineEmailChangeRequestJSON.ClientId = clientOnlineEmailChangeRequest.ClientId;
                clientOnlineEmailChangeRequestJSON.PreviousEmailAddress = clientOnlineEmailChangeRequest.PreviousEmailAddress;
                clientOnlineEmailChangeRequestJSON.NewEmailAddress = clientOnlineEmailChangeRequest.NewEmailAddress;
                clientOnlineEmailChangeRequestJSON.Status = "There was an error with our service. If the problem persists please contact support";
            }

            return clientOnlineEmailChangeRequestJSON;

        }

        [HttpGet]
        [Route("api/Client/getPayments/{clientId}/{organisationId}")]
        public List<vwPaymentDetail> getPayments(int clientId, int organisationId)
        {
            var payments = atlasDBViews.vwPaymentDetails
                                        .Where(pd => pd.ClientId == clientId && pd.OrganisationId == organisationId)
                                        .ToList();
            return payments;
        }

        [HttpGet]
        [Route("api/Client/ReturnBirthdateFromUkLicenceNumber/{licenceNumber}")]
        public DateTime? ReturnBirthdateFromUkLicenceNumber(string licenceNumber)
        {

            var queryText = "SELECT dbo.udfReturnBirthdateFromUkLicenceNumber(@UKLicenceNumber)";

            var objectContext = (atlasDB as IObjectContextAdapter).ObjectContext;

            var DOB = objectContext.ExecuteStoreQuery<DateTime?>(queryText, new SqlParameter("UKLicenceNumber", licenceNumber)).FirstOrDefault();

            return DOB;
        }

        private bool phoneNumberExists(FormDataCollection formBody, int phoneNumberIndex)
        {
            bool exists = false;
            string key1 = "phoneNumbers[" + phoneNumberIndex + "][number]";
            string key2 = "phoneNumbers[" + phoneNumberIndex + "][type]";
            if (!string.IsNullOrEmpty(formBody.Get(key1)) && !string.IsNullOrEmpty(formBody.Get(key2))) exists = true;
            return exists;
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

        // PUT: api/Client/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/Client/5
        public void Delete(int id)
        {
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

        [HttpGet]
        [Route("api/Client/GetSurnameFromLicenceNumber/{licenceNumber}")]
        public string GetSurnameFromLicenceNumber(string licenceNumber)
        {
            var queryText = "SELECT dbo.udfReturnSurnameFromUkLicenceNumber(@UKLicenceNumber)";

            var objectContext = (atlasDB as IObjectContextAdapter).ObjectContext;

            var surname = objectContext.ExecuteStoreQuery<string>(queryText, new SqlParameter("UKLicenceNumber", licenceNumber)).FirstOrDefault();

            surname = char.ToUpper(surname[0]) + surname.Substring(1).ToLower();

            return surname;
        }

        [HttpGet]
        [Route("api/Client/GetFirstInitialFromLicenceNumber/{licenceNumber}")]
        public string GetFirstInitialFromLicenceNumber(string licenceNumber)
        {
            var queryText = "SELECT dbo.udfReturnFirstInitialFromUkLicenceNumber(@UKLicenceNumber)";

            var objectContext = (atlasDB as IObjectContextAdapter).ObjectContext;

            var firstInitial = objectContext.ExecuteStoreQuery<string>(queryText, new SqlParameter("UKLicenceNumber", licenceNumber)).FirstOrDefault();

            return firstInitial;
        }

        public class ClientReturnData
        {
            public int? ClientId { get; set; }
            public string Status { get; set; }
        }

        [HttpGet]
        [Route("api/Client/CourseInformation/{clientId}")]
        public List<CourseInformationJSON> CourseInformation(int clientId)
        {
            var courses = atlasDB.CourseClients.Where(cc => cc.ClientId == clientId).Count();

            if (courses > 0)
            {
                var courseInformation = atlasDB.CourseClients
                                            .Include("Course")
                                            .Where(cc => cc.ClientId == clientId)
                                            .Select(
                                                theCourse => new CourseInformationJSON()
                                                {
                                                    Id = theCourse.CourseId,
                                                    Reference = theCourse.Course.Reference,
                                                    CourseType = theCourse.Course.CourseType.Title,
                                                    CourseDate = theCourse.Course.CourseDate.FirstOrDefault().DateStart,
                                                    IsDORSCourse = theCourse.Course.DORSCourse,
                                                    ClientRemoved = theCourse.Course.CourseClientRemoveds.Any(ccr => ccr.ClientId == clientId && ccr.DateAddedToCourse == theCourse.DateAdded),
                                                    AmountPaid = theCourse.Course.CourseClientPayments.ToList().Where(x => x.ClientId == clientId).Count() > 0 ?
                                                                    theCourse.Course.CourseClientPayments.ToList().Where(x => x.ClientId == clientId).Sum(y => y.Payment.Amount) :
                                                                    0,

                                                    AmountOutstanding = (theCourse.Course.CourseClients.ToList()
                                                                    .OrderByDescending(cc => cc.Id)
                                                                    .FirstOrDefault()
                                                                    .TotalPaymentDue.HasValue ?
                                                                    (decimal)theCourse.Course.CourseClients
                                                                                                .OrderByDescending(cc => cc.Id)
                                                                                                .FirstOrDefault()
                                                                                                .TotalPaymentDue :
                                                                    (decimal)0.00)
                                                                        -
                                                                    (theCourse.Course.CourseClientPayments
                                                                                    .ToList()
                                                                                    .Where(x => x.ClientId == clientId)
                                                                                    .Count() > 0 ?
                                                                    theCourse.Course.CourseClientPayments.ToList()
                                                                                                            .Where(x => x.ClientId == clientId)
                                                                                                            .Sum(y => y.Payment.Amount) :
                                                                                                            0),
                                                    PaymentDueDate = theCourse.PaymentDueDate,
                                                    DORSDetails = theCourse.Client.ClientDORSDatas.Select(
                                                                            dorsDetails => new
                                                                            {
                                                                                DORSReference = dorsDetails.DORSAttendanceRef,
                                                                                Region = dorsDetails.ReferringAuthority,
                                                                                ReferringAuthority = dorsDetails.ReferringAuthority.Name,
                                                                                ReferralDate = dorsDetails.DateReferred,
                                                                                ExpiryDate = dorsDetails.ExpiryDate,
                                                                                DORSAttendanceStateIdentifier = dorsDetails.DORSAttendanceState.DORSAttendanceStateIdentifier,
                                                                                DORSSchemeIdentifier = dorsDetails.DORSScheme.DORSSchemeIdentifier
                                                                            }
                                                                        ),
                                                }).ToList();

                return courseInformation;
            }
            else
            {
                return new List<CourseInformationJSON>();
            }
        }

        [HttpGet]
        [Route("api/Client/GetByOrganisation/{organisationId}")]
        /// <summary>
        /// Return the clients created in the last 6 months for a particular organisation
        /// </summary>
        /// <param name="organisationId"></param>
        /// <returns></returns>
        public List<ClientJSON> GetByOrganisation(int organisationId)
        {
            var sixMonthsAgo = DateTime.Now.AddMonths(-6);
            var clients = atlasDB.Clients
                                    .Include(c => c.ClientOrganisations)
                                    .Where(c => c.ClientOrganisations.Any(co => co.OrganisationId == organisationId) &&
                                            c.DateCreated > sixMonthsAgo
                                    )
                                    .Select(c => new ClientJSON {
                                        Id = c.Id,
                                        Title = c.Title,
                                        FirstName = c.FirstName,
                                        Surname = c.Surname,
                                        DisplayName = c.DisplayName,
                                        DateOfBirth = c.DateOfBirth
                                    })
                                    .ToList();
            return clients;
        }

        [HttpGet]
        [Route("api/Client/GetCourseRemovals/{clientId}/{organisationId}")]
        public List<CourseClientRemoved> GetCourseRemovals(int clientId, int organisationId)
        {
            var courseRemoveds = atlasDB.CourseClientRemoveds
                                        .Where(
                                            ccr => ccr.Course.OrganisationId == organisationId &&
                                            ccr.ClientId == clientId
                                        )
                                        .ToList();
            return courseRemoveds;
        }

        [HttpGet]
        [Route("api/Client/GetClientStatus/{clientId}")]
        public object GetClientStatus(int clientId)
        {
            var clientStatus = atlasDBViews.vwClientStates
                                            .Where(cs => cs.ClientId == clientId)
                                            .FirstOrDefault();
            return clientStatus;
        }

        [HttpGet]
        [Route("api/Client/GetClientsMarkedForDeletion/{organisationId}")]
        public object GetClientsMarkedForDeletion(int organisationId)
        {
            var clientsMarkedForDeletion = atlasDBViews.vwClientsMarkedForDeletions
                                            .Where(cmfd => cmfd.OrganisationId == organisationId)
                                            .ToList();
            return clientsMarkedForDeletion;
        }

        [HttpGet]
        [Route("api/Client/GetClientEmailAddresses/{clientId}")]
        public object GetClientEmailAddresses(int clientId)
        {
            var clientEmails = atlasDB.ClientEmails
                                        .Include(ce => ce.Email)
                                        .Where(ce => ce.ClientId == clientId)
                                        .Select(em => em.Email)
                                        .ToList();

            return clientEmails;
        }

        [HttpGet]
        [Route("api/Client/GetClientPhoneNumbers/{clientId}")]
        public object GetClientPhoneNumbers(int clientId)
        {
            var clientPhoneNumbers = atlasDB.ClientPhones
                                            .Include(cp => cp.PhoneType)
                                            .Where(cp => cp.ClientId == clientId)
                                            .Select(cp => new {
                                                Number = cp.PhoneNumber,
                                                NumberType = cp.PhoneType.Type
                                            })
                                            .ToList();

            return clientPhoneNumbers;
        }

        public class RemoveFromCourseParameters
        {
            public int clientId { get; set; }
            public int courseId { get; set; }
            public int userId { get; set; }
            public string notes { get; set; }
        }
    }
}

