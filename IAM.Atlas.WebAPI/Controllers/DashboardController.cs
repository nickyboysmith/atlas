using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Data.Entity;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Web.Http.ModelBinding;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using System.Linq.Dynamic;
using IAM.Atlas.WebAPI.Models.Dashboard;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DashboardController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/dashboard/getmetersbyorganisation/{OrganisationId}")]
        [HttpGet]
        public object GetMetersByOrganisation(int OrganisationId)
        {
            try
            {
                var organisationMeters = atlasDB.DashboardMeterExposures
                    .Include(y => y.DashboardMeter)
                    //.Include(z => z.Organisation.OrganisationDashboardMeters)
                    //.Include(u => u.DashboardMeter.UserDashboardMeters.)
                    .Where(x => x.OrganisationId == OrganisationId && x.DashboardMeter.Disabled != true)
                    .Select(
                            x => new
                            {
                                Id = x.DashboardMeter.Id,
                                Name = x.DashboardMeter.Name,
                                Title = x.DashboardMeter.Title,
                                Description = x.DashboardMeter.Description,
                                AvailableToAll = x.DashboardMeter.OrganisationDashboardMeters.Any(o => o.OrganisationId == OrganisationId),
                                RefreshRate = x.DashboardMeter.RefreshRate > 0 ? (((decimal)x.DashboardMeter.RefreshRate) / 1000).ToString() : "Not Set"
                            }
                    )
                    .ToList();

                return organisationMeters;
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

        [AuthorizationRequired]
        [Route("api/dashboard/getmeterusersbyorganisation/{MeterId}/{OrganisationId}")]
        [HttpGet]
        public object GetMeterUsersByOrganisation(int MeterId, int OrganisationId)
        {
            try
            {
                var meterUsers = atlasDB.UserDashboardMeters
                    .Include(u => u.User.OrganisationAdminUsers)
                    .Include(z => z.User.OrganisationUsers)
                    .Where(
                            x => x.DashboardMeterId == MeterId
                            &&
                            (x.User.OrganisationUsers.Any(p => p.OrganisationId == OrganisationId)
                            ||
                            x.User.OrganisationAdminUsers.Any(p => p.OrganisationId == OrganisationId)
                            )
                     )
                     .Select(
                    d => new
                    {
                        d.User.Id,
                        d.User.Name
                    }
                    )
                    .ToList();

                return meterUsers;
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


        [AuthorizationRequired]
        [Route("api/dashboard/getmeterunallocatedusersbyorganisation/{MeterId}/{OrganisationId}")]
        [HttpGet]
        public object GetMeterUnallocatedUsersByOrganisation(int MeterId, int OrganisationId)
        {
            try
            {
                var nonMeterUsers = atlasDB.Users
                                           .Include(u=>u.OrganisationAdminUsers)
                                           .Include(x=>x.OrganisationUsers)
                                           .Include(d=>d.UserDashboardMeters)
                                           .Include(c=>c.User_Clients)
                                           .Where(
                                                    x => !(x.UserDashboardMeters.Any(w=>w.DashboardMeterId == MeterId))
                                                    &&
                                                    (x.OrganisationUsers.Any(p => p.OrganisationId == OrganisationId)
                                                    ||
                                                    x.OrganisationAdminUsers.Any(p => p.OrganisationId == OrganisationId)
                                                    )
                                                    &&
                                                    !(x.User_Clients.Any())
                                             )
                                             .Select(
                                            d => new
                                            {
                                                d.Id,
                                                d.Name
                                            }
                                            )
                                            .ToList();

                return nonMeterUsers;
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

        [AuthorizationRequired]
        [Route("api/dashboard/savemeteruserupdate")]
        [HttpPost]
        public void SaveMeterUserUpdate([FromBody] FormDataCollection formBody)
        {

            var action = StringTools.GetString("action", ref formBody);
            var meterId = StringTools.GetInt("meterId", ref formBody);
            var userId = StringTools.GetInt("userId", ref formBody);
            var organisationId = StringTools.GetInt("organisationId", ref formBody);
            var requestingUserId = this.GetUserIdFromToken(Request);
            if(!requestingUserId.HasValue)
            {
                return;
            }

            if(!this.UserAuthorisedForOrganisation(requestingUserId.Value, organisationId, UserLevel.OrganisationAdministrator))
            {
                return;
            }

            if (action == "add")
            {

                var userDashBoardMeter = new UserDashboardMeter();
                userDashBoardMeter.DashboardMeterId = meterId;
                userDashBoardMeter.UserId = userId;

                atlasDB.UserDashboardMeters.Add(userDashBoardMeter);

            }
            else if (action == "remove")
            {
                var userDashBoardMeterToRemove = new UserDashboardMeter();

                userDashBoardMeterToRemove = atlasDB.UserDashboardMeters.Where(dme => dme.DashboardMeterId == meterId
                                                                                            && dme.UserId == userId).FirstOrDefault();
                
                if (userDashBoardMeterToRemove != null)
                {
                    atlasDB.UserDashboardMeters.Remove(userDashBoardMeterToRemove);
                }
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
        }


        //Atlas Documents
        [AuthorizationRequired]
        [Route("api/dashboard/updateorganisationmeter")]
        [HttpPost]
        public object UpdateOrganisationMeter([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            var id = StringTools.GetInt("Id", ref formData);
            var organisationId = StringTools.GetInt("OrganisationId", ref formData);
            var availableToAll = StringTools.GetBool("AvailableToAll", ref formData);
            var userId = StringTools.GetInt("userId", ref formBody);

            if (!this.UserAuthorisedForOrganisation(userId, organisationId, UserLevel.OrganisationAdministrator))
            {
                return "failed";
            }

            if (availableToAll)
            {
                if (!atlasDB.OrganisationDashboardMeters.Any(x => x.DashboardMeterId == id && x.OrganisationId == organisationId))
                {
                    atlasDB.OrganisationDashboardMeters.Add(
                                new OrganisationDashboardMeter
                                {
                                    OrganisationId = organisationId,
                                    DashboardMeterId = id
                                }
                        );
                }
            }
            else
            {
                var meters = atlasDB.OrganisationDashboardMeters.Where(x => x.DashboardMeterId == id && x.OrganisationId == organisationId).ToList();
                foreach (var meter in meters)
                {
                    atlasDB.OrganisationDashboardMeters.Remove(meter);
                }
            }

            atlasDB.SaveChanges();
            return "success";
        }



        [AuthorizationRequired]
        [Route("api/dashboard/getmeters/{OrganisationId}/{UserId}")]
        [HttpGet]
        public object GetMeter(int OrganisationId, int UserId)
        {
            try
            {
                return atlasDBViews
                    .vwDashboardMeter_UserAccess
                    .Where(
                        ua => ua.UserId == UserId
                    )
                    .Select(
                        dashboard => new
                        {
                            Title = dashboard.DashboardMeterTitle
                            , Name = dashboard.DashboardMeterName
                            , Description = dashboard.DashboardMeterDescription
                            , Refresh = (dashboard.DashboardMeterRefreshRate * 1000)
                            , Picture = dashboard.DashboardMeterCategoryPicture
                            , Category = dashboard.DashboardMeterCategory
                            , Id = dashboard.DashboardMeterId
                        }
                    )
                    .ToList();

                
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

        [AuthorizationRequired]
        [Route("api/dashboard/payments/{OrganisationId}")]
        [HttpGet]
        public object GetPayments(int OrganisationId)
        {
            try
            {

                return atlasDBViews.vwDashboardMeter_Payments
                    .Where(
                        paymentMeter => paymentMeter.OrganisationId == OrganisationId
                    )
                    .ToList()
                    .Select(
                        payment => new
                        {
                            //payment.NumberOfPayments,
                            //SumOfPayments = "£" + payment.SumOfPayments,
                            //payment.NumberOfUnpaidBookedCourses,
                            //payment.NumberPaymentsUnallocated,
                            payment.NumberOfOnlinePaymentsTakenToday,
                            payment.NumberOfPhonePaymentsTakenToday,
                            payment.NumberOfRefundedPaymentsTakenToday,
                            payment.NumberOfUnallocatedPaymentsTakenToday,
                            payment.NumberOfPaymentsTakenToday,
                            payment.PaymentSumTakenToday,
                            payment.NumberOfRefundedPaymentsTakenYesterday,
                            payment.NumberOfOnlinePaymentsTakenYesterday,
                            payment.NumberOfPhonePaymentsTakenYesterday,
                            payment.NumberOfUnallocatedPaymentsTakenYesterday,
                            payment.NumberOfPaymentsTakenYesterday,
                            payment.PaymentSumTakenYesterday,
                            payment.NumberOfRefundedPaymentsTakenThisWeek,
                            payment.NumberOfOnlinePaymentsTakenThisWeek,
                            payment.NumberOfPhonePaymentsTakenThisWeek,
                            payment.NumberOfUnallocatedPaymentsTakenThisWeek,
                            payment.NumberOfPaymentsTakenThisWeek,
                            payment.PaymentSumTakenThisWeek,
                            payment.NumberOfRefundedPaymentsTakenThisMonth,
                            payment.NumberOfOnlinePaymentsTakenThisMonth,
                            payment.NumberOfPhonePaymentsTakenThisMonth,
                            payment.NumberOfUnallocatedPaymentsTakenThisMonth,
                            payment.NumberOfPaymentsTakenThisMonth,
                            payment.PaymentSumTakenThisMonth,
                            payment.NumberOfRefundedPaymentsTakenPreviousMonth,
                            payment.NumberOfOnlinePaymentsTakenPreviousMonth,
                            payment.NumberOfPhonePaymentsTakenPreviousMonth,
                            payment.NumberOfUnallocatedPaymentsTakenPreviousMonth,
                            payment.NumberOfPaymentsTakenPreviousMonth,
                            payment.PaymentSumTakenPreviousMonth,
                            payment.NumberOfRefundedPaymentsTakenThisYear,
                            payment.NumberOfOnlinePaymentsTakenThisYear,
                            payment.NumberOfPhonePaymentsTakenThisYear,
                            payment.NumberOfUnallocatedPaymentsTakenThisYear,
                            payment.NumberOfPaymentsTakenThisYear,
                            payment.PaymentSumTakenThisYear,
                            payment.NumberOfRefundedPaymentsTakenPreviousYear,
                            payment.NumberOfOnlinePaymentsTakenPreviousYear,
                            payment.NumberOfPhonePaymentsTakenPreviousYear,
                            payment.NumberOfUnallocatedPaymentsTakenPreviousYear,
                            payment.NumberOfPaymentsTakenPreviousYear,
                            payment.PaymentSumTakenPreviousYear,
                            lastUpdated = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString(),
                            meterOrgName = payment.OrganisationName
                        }
                    )
                    .FirstOrDefault();

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

        [AuthorizationRequired]
        [Route("api/dashboard/courses/{OrganisationId}")]
        [HttpGet]
        public object GetCourses(int OrganisationId)
        {

            try
            {

         return atlasDBViews.vwDashboardMeter_Courses
                    .Where(
                        courseMeter => courseMeter.OrganisationId == OrganisationId
                    )
                    .ToList()
                    .Select(
                        course => new
                        {
                            NumberOfAttendanceUpdatesDue = course.CoursesWithoutAttendance,
                            NumberOfAttendanceVerificationsDue = course.CoursesWithoutAttendanceVerfication,
                            SumOfOutstandingBalances = String.Format("{0:C}", course.TotalAmountUnpaid),
                            NumberOfPaymentsDue = course.NumberOfUnpaidCourses,
                            lastUpdated = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString(),
                            meterOrgName = ""
                        }
                    )
                    .FirstOrDefault();

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

        [AuthorizationRequired]
        [Route("api/dashboard/clients/{OrganisationId}")]
        [HttpGet]
        public object GetClients(int OrganisationId)
        {

            try
            {
                var data = atlasDBViews.vwDashboardMeter_Clients
                    .Where(
                        clientMeter => clientMeter.OrganisationId == OrganisationId
                    )
                    .ToList()
                    .Select(
                        clients => new
                        {
                            clients.TotalClients,
                            clients.RegisteredOnlineToday,
                            clients.RegisteredToday,
                            clients.NumberOfUnpaidCourses,
                            TotalAmountUnpaid = String.Format("{0:C}", clients.TotalAmountUnpaid),
                            ClientsRegisterOnlineTodayWithAdditionalRequirements = clients.ClientsWithRequirementsRegisteredOnlineToday,
                            ClientsRegisterOnlineAdditionalRequirements = clients.TotalUpcomingClientsWithRequirements,
                            UnableToUpdateInDORS = clients.UnableToUpdateInDORS,
                            AttendanceNotUploadedToDORS = clients.AttendanceNotUploadedToDORS,
                            ClientsWithMissingReferringAuthorityCreatedThisWeek = clients.ClientsWithMissingReferringAuthorityCreatedThisWeek,
                            ClientsWithMissingReferringAuthorityCreatedThisMonth = clients.ClientsWithMissingReferringAuthorityCreatedThisMonth,
                            ClientsWithMissingReferringAuthorityCreatedLastMonth = clients.ClientsWithMissingReferringAuthorityCreatedLastMonth,
                            lastUpdated = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString(),
                            meterOrgName = ""
                        }
                    )
                    .FirstOrDefault();

                return data;
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

        [AuthorizationRequired]
        [Route("api/dashboard/email/{OrganisationId}")]
        [HttpGet]
        public object GetEmail(int OrganisationId)
        {
            try
            {
                return atlasDBViews.vwDashboardMeter_Email
                    .Where(
                        emailMeter => emailMeter.OrganisationId == OrganisationId
                    )
                    .ToList()
                    .Select(
                        emails => new
                        {
                            emails.EmailsSentToday,
                            emails.EmailsSentYesterday,
                            emails.EmailsSentThisMonth,
                            emails.EmailsSentLastMonth,
                            emails.ScheduledEmails,
                            lastUpdated = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString(),
                            meterOrgName = ""
                        }
                    )
                    .FirstOrDefault();

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

        //Organisation Documents
        //[AuthorizationRequired]
        [Route("api/dashboard/documents/{OrganisationId}")]
        [HttpGet]
        public object GetDocuments(int OrganisationId)
        {
            try
            {
                var organisation = atlasDB.Organisations
                    .Where(x => x.Id == OrganisationId)
                    .FirstOrDefault();
                var organisationName = "";
                if (organisation != null) organisationName = organisation.Name;
                var lastUpdated = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString();

                var documentStats = atlasDBViews.vwDashboardMeter_DocumentStats
                    .Where(
                        courseMeter => courseMeter.OrganisationId == OrganisationId
                    )
                    .Select(
                        documents => new
                        {//TODO Use a dictionary to return dynamically created names that reference actual years
                            DocumentsInSystem = documents.NumberOfDocuments,
                            DocumentsAddedThisMonth = documents.NumberOfDocumentsThisMonth,
                            DocumentsAddedLastMonth = documents.NumberOfDocumentsPreviousMonth,
                            DocumentsAddedThisYear = documents.NumberOfDocumentsThisYear,
                            DocumentsAdded_1_YearAgo = documents.NumberOfDocumentsPreviousYear,
                            DocumentsAdded_2_YearsAgo = documents.NumberOfDocumentsPreviousTwoYears,
                            DocumentsAdded_3_YearsAgo = documents.NumberOfDocumentsPreviousThreeYears,
                            TotalSize = documents.TotalSize == null ? 0 : (long)documents.TotalSize,
                            TotalSizeOfDocumentsThisMonth = documents.TotalSizeOfDocumentsThisMonth == null ? 0 : (long)documents.TotalSizeOfDocumentsThisMonth,
                            TotalSizeOfDocumentsPreviousMonth = documents.TotalSizeOfDocumentsPreviousMonth == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousMonth,
                            TotalSizeOfDocumentsThisYear = documents.TotalSizeOfDocumentsThisYear == null ? 0 : (long)documents.TotalSizeOfDocumentsThisYear,
                            TotalSizeOfDocumentsPreviousYear = documents.TotalSizeOfDocumentsPreviousYear == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousYear,
                            TotalSizeOfDocumentsPreviousTwoYears = documents.TotalSizeOfDocumentsPreviousTwoYears == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousTwoYears,
                            TotalSizeOfDocumentsPreviousThreeYears = documents.TotalSizeOfDocumentsPreviousThreeYears == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousThreeYears,
                            lastUpdated = lastUpdated,
                            meterOrgName = organisationName + " "
                        }
                    )
                    .FirstOrDefault();

                if (documentStats == null)
                {
                    documentStats = new
                    {
                        DocumentsInSystem = (long?)0,
                        DocumentsAddedThisMonth = (long?)0,
                        DocumentsAddedLastMonth = (long?)0,
                        DocumentsAddedThisYear = (long?)0,
                        DocumentsAdded_1_YearAgo = (long?)0,
                        DocumentsAdded_2_YearsAgo = (long?)0,
                        DocumentsAdded_3_YearsAgo = (long?)0,
                        TotalSize = (long)0,
                        TotalSizeOfDocumentsThisMonth = (long)0,
                        TotalSizeOfDocumentsPreviousMonth = (long)0,
                        TotalSizeOfDocumentsThisYear = (long)0,
                        TotalSizeOfDocumentsPreviousYear = (long)0,
                        TotalSizeOfDocumentsPreviousTwoYears = (long)0,
                        TotalSizeOfDocumentsPreviousThreeYears = (long)0,
                        lastUpdated = lastUpdated,
                        meterOrgName = organisationName + " "
                    };
                }
                return documentStats;
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists please contact Support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }
        
        //[AuthorizationRequired]
        [Route("api/dashboard/DORSOfferWithdrawn/{OrganisationId}")]
        [HttpGet]
        /// <summary>
        /// Used by a dashboard meter this function shows all the Clients that have had their offer withdrawn for 
        /// a particular organisation
        /// </summary>
        /// <param name="OrganisationId">The organisation in question</param>
        /// <returns></returns>
        public DORSOfferWithdrawnMeterJSON DORSOfferWithdrawn(int OrganisationId)
        {
            var data = atlasDBViews.vwDashboardMeter_DORSOfferWithdrawn
                                .Where(dow => dow.OrganisationId == OrganisationId)
                                .Select(
                                    offersWithdrawn => new DORSOfferWithdrawnMeterJSON
                                    {
                                        // TODO: someone coded it such that the column names of the returned object get 
                                        // parsed into the front end label... this needs to be refactored.
                                        NumberOfOffersWithdrawnToday = offersWithdrawn.TotalCreatedToday == null ? 0 : (int)offersWithdrawn.TotalCreatedToday,
                                        NumberOfOffersWithdrawnThisWeek = offersWithdrawn.TotalCreatedThisWeek == null ? 0 : (int)offersWithdrawn.TotalCreatedThisWeek,
                                        NumberOfOffersWithdrawnThisMonth = offersWithdrawn.TotalCreatedThisMonth == null ? 0 : (int)offersWithdrawn.TotalCreatedThisMonth,
                                        NumberOfOffersWithdrawnPreviousMonth = offersWithdrawn.TotalCreatedPreviousMonth == null ? 0 : (int)offersWithdrawn.TotalCreatedPreviousMonth,
                                    })
                                .FirstOrDefault();
            if(data == null)
            {
                data = new DORSOfferWithdrawnMeterJSON();
            }
            if(data != null) data.lastUpdated = DateTime.Now.ToString("dd/MM/yyyy hh:mm");
            // /*mock data below */
            //var data = new DORSOfferWithdrawnMeterJSON
            //{
            //    // TODO: someone coded it such that the column names of the returned object get 
            //    // parsed into the front end label... this needs to be refactored.
            //    NumberOfOffersWithdrawnToday = 10,
            //    NumberOfOffersWithdrawnThisWeek = 10,
            //    NumberOfOffersWithdrawnThisMonth = 10,
            //    NumberOfOffersWithdrawnPreviousMonth = 20,
            //    lastUpdated = DateTime.Now.ToString("dd/MM/yyyy hh:mm")
            //};
            return data;
        }

        //Atlas Documents
        [AuthorizationRequired]
        [Route("api/dashboard/systemdocuments/{OrganisationId}")]
        [HttpGet]
        public object SystemDocuments(int OrganisationId)
        {
            return GetAtlasDocuments();
        }

        //Atlas Documents
        [AuthorizationRequired]
        [Route("api/dashboard/systemdocuments/")]
        [HttpGet]
        public object GetAtlasDocuments()
        {
            try
            {
                var data = atlasDBViews.vwDashboardMeter_DocumentStats
                    .Select(
                        documents => new
                        {
                            DocumentsInSystem = (long)documents.NumberOfDocuments,
                            DocumentsAddedThisMonth = (long)documents.NumberOfDocumentsThisMonth,
                            DocumentsAddedLastMonth = (long)documents.NumberOfDocumentsPreviousMonth,
                            DocumentsAddedThisYear = (long)documents.NumberOfDocumentsThisYear,
                            DocumentsAdded1YearAgo = (long)documents.NumberOfDocumentsPreviousYear,
                            DocumentsAdded2YearsAgo = (long)documents.NumberOfDocumentsPreviousTwoYears,
                            DocumentsAdded3YearsAgo = (long)documents.NumberOfDocumentsPreviousThreeYears,
                            TotalSize = documents.TotalSize == null ? 0 : (long)documents.TotalSize,
                            TotalSizeOfDocumentsThisMonth = documents.TotalSizeOfDocumentsThisMonth == null ? 0 : (long)documents.TotalSizeOfDocumentsThisMonth,
                            TotalSizeOfDocumentsPreviousMonth = documents.TotalSizeOfDocumentsPreviousMonth == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousMonth,
                            TotalSizeOfDocumentsThisYear = documents.TotalSizeOfDocumentsThisYear == null ? 0 : (long)documents.TotalSizeOfDocumentsThisYear,
                            TotalSizeOfDocumentsPreviousYear = documents.TotalSizeOfDocumentsPreviousYear == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousYear,
                            TotalSizeOfDocumentsPreviousTwoYears = documents.TotalSizeOfDocumentsPreviousTwoYears == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousTwoYears,
                            TotalSizeOfDocumentsPreviousThreeYears = documents.TotalSizeOfDocumentsPreviousThreeYears == null ? 0 : (long)documents.TotalSizeOfDocumentsPreviousThreeYears
                        }
                    ).ToList();

                long DocumentsInSystem = 0;
                long DocumentsAddedThisMonth = 0;
                long DocumentsAddedLastMonth = 0;
                long DocumentsAddedThisYear = 0;
                long DocumentsAdded_1_YearAgo = 0;
                long DocumentsAdded_2_YearsAgo = 0;
                long DocumentsAdded_3_YearsAgo = 0;
                long TotalSize = 0;
                long TotalSizeOfDocumentsThisMonth = 0;
                long TotalSizeOfDocumentsPreviousMonth = 0;
                long TotalSizeOfDocumentsThisYear = 0;
                long TotalSizeOfDocumentsPreviousYear = 0;
                long TotalSizeOfDocumentsPreviousTwoYears = 0;
                long TotalSizeOfDocumentsPreviousThreeYears = 0;

                foreach (var record in data)
                {
                    DocumentsInSystem += record.DocumentsInSystem;
                    DocumentsAddedThisMonth += record.DocumentsAddedThisMonth;
                    DocumentsAddedLastMonth += record.DocumentsAddedLastMonth;
                    DocumentsAddedThisYear += record.DocumentsAddedThisYear;
                    DocumentsAdded_1_YearAgo += record.DocumentsAdded1YearAgo;
                    DocumentsAdded_2_YearsAgo += record.DocumentsAdded2YearsAgo;
                    DocumentsAdded_3_YearsAgo += record.DocumentsAdded3YearsAgo;
                    TotalSize += record.TotalSize;
                    TotalSizeOfDocumentsThisMonth += record.TotalSizeOfDocumentsThisMonth;
                    TotalSizeOfDocumentsPreviousMonth += record.TotalSizeOfDocumentsPreviousMonth;
                    TotalSizeOfDocumentsThisYear += record.TotalSizeOfDocumentsThisYear;
                    TotalSizeOfDocumentsPreviousYear += record.TotalSizeOfDocumentsPreviousYear;
                    TotalSizeOfDocumentsPreviousTwoYears += record.TotalSizeOfDocumentsPreviousTwoYears;
                    TotalSizeOfDocumentsPreviousThreeYears += record.TotalSizeOfDocumentsPreviousThreeYears;
                }

                return new
                {
                    DocumentsInSystem,
                    DocumentsAddedThisMonth,
                    DocumentsAddedLastMonth,
                    DocumentsAddedThisYear,
                    DocumentsAdded_1_YearAgo,
                    DocumentsAdded_2_YearsAgo,
                    DocumentsAdded_3_YearsAgo,
                    TotalSize,
                    TotalSizeOfDocumentsThisMonth,
                    TotalSizeOfDocumentsPreviousMonth,
                    TotalSizeOfDocumentsThisYear,
                    TotalSizeOfDocumentsPreviousYear,
                    TotalSizeOfDocumentsPreviousTwoYears,
                    TotalSizeOfDocumentsPreviousThreeYears,
                    lastUpdated = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString(),
                    meterOrgName = ""
                };
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

        [Route("api/dashboard/getInformation")]
        [HttpPost]
        public object GetExtraInformation([FromBody] FormDataCollection formBody)
        {
            var meterName = StringTools.GetStringOrFail("meterName", ref formBody, "Please select a valid meter.");
            var parameterName = StringTools.GetStringOrFail("parameter", ref formBody, "Please select a valid parameter.");
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Please select a valid organisation");
            var userId = StringTools.GetIntOrFail("userId", ref formBody, "Please select a valid user");


            // Only valid for the clients meter
            if (meterName == "Clients")
            {
                if (parameterName == "RegisteredToday" || parameterName == "RegisteredOnlineToday")
                {
                    var online = (parameterName == "RegisteredOnlineToday") ? true : false;
                    return GetClientHoverTodayRegistrations(organisationId, online);
                }
                else if (parameterName == "NumberOfUnpaidCourses" || parameterName == "TotalAmountUnpaid")
                {
                    return GetClientHoverUnpaidCourses(organisationId);
                }
                else if (parameterName == "ClientsRegisterOnlineTodayWithAdditionalRequirements")
                {
                    return GetClientsRegisteredOnlineWithAdditionalRequirements(organisationId, true);
                }
                else if (parameterName == "ClientsRegisterOnlineAdditionalRequirements")
                {
                    return GetClientsRegisteredOnlineWithAdditionalRequirements(organisationId, false);
                }
                else if (parameterName == "UnableToUpdateInDORS")
                {
                    return GetClientsUnableToUpdateInDORS(organisationId);
                }
                else if (parameterName == "AttendanceNotUploadedToDORS")
                {
                    return GetAttendanceNotUploadedToDORS(organisationId);
                }
                else if (parameterName == "ClientsWithMissingReferringAuthorityCreatedThisWeek")
                {
                    return GetClientsWithMissingReferringAuthority(organisationId, "ThisWeek");
                }
                else if (parameterName == "ClientsWithMissingReferringAuthorityCreatedThisMonth")
                {
                    return GetClientsWithMissingReferringAuthority(organisationId, "ThisMonth");
                }
                else if (parameterName == "ClientsWithMissingReferringAuthorityCreatedLastMonth")
                {
                    return GetClientsWithMissingReferringAuthority(organisationId, "LastMonth");
                }
            }

            // Only valid for the courses meter
            if (meterName == "Courses")
            {
                if (parameterName == "NumberOfAttendanceUpdatesDue")
                {
                    //var online = (parameterName == "RegisteredOnlineToday") ? true : false;
                    return GetCourseAttendanceUpdatesDueNumber(organisationId);
                }
                else if (parameterName == "NumberOfAttendanceVerificationsDue")
                {
                    return GetCourseAttendanceVerificationsDueNumber(organisationId);
                }
                else if (parameterName == "SumOfOutstandingBalances" || parameterName == "NumberOfPaymentsDue")
                {
                    return GetCourseOutstandingCoursePayments(organisationId);
                }
            }

            if(meterName == "DORSOfferWithdrawn")
            {
                if (parameterName == "OffersWithdrawnToday")
                {
                    return GetDORSOffersWithdrawn(organisationId, "Today");
                }
                else if (parameterName == "OffersWithdrawnThisWeek")
                {
                    return GetDORSOffersWithdrawn(organisationId, "ThisWeek");
                }
                else if (parameterName == "OffersWithdrawnThisMonth")
                {
                    return GetDORSOffersWithdrawn(organisationId, "ThisMonth");
                }
                else if (parameterName == "OffersWithdrawnPreviousMonth")
                {
                    return GetDORSOffersWithdrawn(organisationId, "PreviousMonth");
                }
            }

            if (meterName == "Payments")
            {
                var splitParameter = parameterName.Split('|');
                var timeFrame = splitParameter[0]; // @TODO escape string for sql injection
                var type = splitParameter[1];

                var selectedTimeFrame = SelectTimeFrame(timeFrame) + " == true";

                return atlasDBViews.vwPaymentsLinksDetails
                    .Where(
                        paymentLink => 
                        paymentLink.OrganisationId == organisationId &&
                        (type != "Refunded" || paymentLink.RefundPayment == true) &&
                        (type != "Unallocated" || paymentLink.PaymentUnallocatedToClient == true) &&
                        (type != "OnLine" || paymentLink.OnLinePayment == true) &&
                        (type != "Phone" || paymentLink.OnLinePayment == false)
                    )
                    .Where(selectedTimeFrame)
                    .Select(
                        payment => new PaymentExtraInformation
                        {
                            DateCreated = payment.DateCreated.ToString(),
                            Amount = payment.PaymentAmount,
                            Info = payment.PaymentAdditionalInfo,
                            PaymentId = payment.PaymentId,
                            ClientId = (payment.ClientId == null) ? 0 : (int)payment.ClientId,
                            Name = payment.ClientName,
                            CourseId = (payment.CourseId == null) ? 0 : (int) payment.CourseId,
                            StartDate = payment.CourseStartDate,
                            CourseTypeName = payment.CourseType
                        }
                    )
                    .ToList();
            }

            return new string[] { };
        }

        private string SelectTimeFrame(string TimeFrame)
        {
            var validatedTimeFrame = "CreatedToday";

            if (TimeFrame == "Yesterday's Payments") {
                validatedTimeFrame = "CreatedYesterday";
            } else if (TimeFrame == "This Week's Payments") {
                validatedTimeFrame = "CreatedThisWeek";
            } else if (TimeFrame == "This Month's Payments") {
                validatedTimeFrame = "CreatedThisMonth";
            } else if (TimeFrame == "The Previous Month's Payments") {
                validatedTimeFrame = "CreatedPreviousMonth";
            } else if (TimeFrame == "This Year's Payments") {
                validatedTimeFrame = "CreatedThisYear";
            } else if (TimeFrame == "The Previous Year's Payments") {
                validatedTimeFrame = "CreatedPreviousYear";
            }

            return validatedTimeFrame;

        }

        private List<DORSOfferWithdrawnJSON> GetDORSOffersWithdrawn(int organisationId, string timeframe)
        {
            List<DORSOfferWithdrawnJSON> offersWithdrawn = new List<DORSOfferWithdrawnJSON>();
           
            switch (timeframe)
            {
                case "Today":
                    offersWithdrawn = atlasDBViews.vwDORSOfferWithdrawns
                                                .Where(ow => ow.OrganisationId == organisationId && ow.CreatedToday == true)
                                                .Select(ow => new DORSOfferWithdrawnJSON
                                                {
                                                    ClientId = ow.ClientId == null ? 0 : (int)ow.ClientId,
                                                    CourseId = ow.CourseId == null ? 0 : (int)ow.CourseId,
                                                    CourseTypeName = ow.CourseType,
                                                    DORSAttendanceRef = ow.DORSAttendanceRef == null ? 0 : (int)ow.DORSAttendanceRef,
                                                    DORSSchemeName = ow.DORSSchemeName,
                                                    Licence = ow.LicenceNumber,
                                                    Name = ow.ClientName,
                                                    StartDate = ow.CourseStartDate,
                                                    CourseAdditionalInfo = ow.CourseAdditionalInfo
                                                })
                                                .ToList();
                    break;
                case "ThisWeek":
                    offersWithdrawn = atlasDBViews.vwDORSOfferWithdrawns
                            .Where(ow => ow.OrganisationId == organisationId && ow.CreatedThisWeek == true)
                            .Select(ow => new DORSOfferWithdrawnJSON
                            {
                                ClientId = ow.ClientId == null ? 0 : (int)ow.ClientId,
                                CourseId = ow.CourseId == null ? 0 : (int)ow.CourseId,
                                CourseTypeName = ow.CourseType,
                                DORSAttendanceRef = ow.DORSAttendanceRef == null ? 0 : (int)ow.DORSAttendanceRef,
                                DORSSchemeName = ow.DORSSchemeName,
                                Licence = ow.LicenceNumber,
                                Name = ow.ClientName,
                                StartDate = ow.CourseStartDate,
                                CourseAdditionalInfo = ow.CourseAdditionalInfo
                            })
                            .ToList();
                    break;
                case "ThisMonth":
                    offersWithdrawn = atlasDBViews.vwDORSOfferWithdrawns
                            .Where(ow => ow.OrganisationId == organisationId && ow.CreatedThisMonth == true)
                            .Select(ow => new DORSOfferWithdrawnJSON
                            {
                                ClientId = ow.ClientId == null ? 0 : (int)ow.ClientId,
                                CourseId = ow.CourseId == null ? 0 : (int)ow.CourseId,
                                CourseTypeName = ow.CourseType,
                                DORSAttendanceRef = ow.DORSAttendanceRef == null ? 0 : (int)ow.DORSAttendanceRef,
                                DORSSchemeName = ow.DORSSchemeName,
                                Licence = ow.LicenceNumber,
                                Name = ow.ClientName,
                                StartDate = ow.CourseStartDate,
                                CourseAdditionalInfo = ow.CourseAdditionalInfo
                            })
                            .ToList();
                    break;
                case "PreviousMonth":
                    offersWithdrawn = atlasDBViews.vwDORSOfferWithdrawns
                            .Where(ow => ow.OrganisationId == organisationId && ow.CreatedPreviousMonth == true)
                            .Select(ow => new DORSOfferWithdrawnJSON
                            {
                                ClientId = ow.ClientId == null ? 0 : (int)ow.ClientId,
                                CourseId = ow.CourseId == null ? 0 : (int)ow.CourseId,
                                CourseTypeName = ow.CourseType,
                                DORSAttendanceRef = ow.DORSAttendanceRef == null ? 0 : (int)ow.DORSAttendanceRef,
                                DORSSchemeName = ow.DORSSchemeName,
                                Licence = ow.LicenceNumber,
                                Name = ow.ClientName,
                                StartDate = ow.CourseStartDate,
                                CourseAdditionalInfo = ow.CourseAdditionalInfo
                            })
                            .ToList();
                    break;
            }

            // /* mock data below */
            //var offerWithdrawn = new DORSOfferWithdrawnJSON()
            //{
            //    ClientId = 3867196,
            //    CourseId = 546816,
            //    CourseTypeName = "Paul",
            //    DORSAttendanceRef = 12345,
            //    DORSSchemeName = "PaulScheme",
            //    Licence = "MYLICENCE",
            //    Name = "Paul Test",
            //    StartDate = DateTime.Now,
            //    CourseAdditionalInfo = ""
            //};
            //offersWithdrawn.Add(offerWithdrawn);

            return offersWithdrawn;
        }

        private object GetClientHoverTodayRegistrations(int OrganisationId, bool online)
        {
            var todayRegistration = new Object();
            try
            {
                todayRegistration = atlasDBViews.vwClientsCreatedTodays
                    .Where(
                        today =>
                            today.OrganisationId == OrganisationId &&
                            ((online == false) || today.SelfRegistration == true)
                    )
                    .Select(theTodayRegistrations => new
                    {
                        ClientId = theTodayRegistrations.ClientSystemId,
                        Name = theTodayRegistrations.ClientName,
                        DateOfBirth = theTodayRegistrations.DateOfBirth,
                        theTodayRegistrations.LicenceNumber,
                        theTodayRegistrations.PhoneNumber
                    })
                    .ToList()
                    .Select(row => new
                    {
                        row.ClientId,
                        row.Name,
                        DateOfBirth = row.DateOfBirth == null ? " " : row.DateOfBirth.Value.ToString("dd-MMM-yyyy"),
                        row.LicenceNumber,
                        row.PhoneNumber
                    })
                    .ToList();
            }
            catch (Exception ex) {
                Error.FrontendHandler(HttpStatusCode.ServiceUnavailable, "We've been unable to process your request.");
            }
            return todayRegistration;
        }

        private object GetClientHoverYesterdayRegistrations(int OrganisationId, bool online)
        {
            var yesterdayRegistration = new Object();
            try
            {
                yesterdayRegistration = atlasDBViews.vwClientsCreatedYesterdays
                    .Where(
                        yesterday =>
                            yesterday.OrganisationId == OrganisationId &&
                            ((online == false) || yesterday.SelfRegistration == true)
                    )
                    .Select(theYesterdayRegistrations => new
                    {
                        ClientId = theYesterdayRegistrations.ClientSystemId,
                        Name = theYesterdayRegistrations.ClientName,
                        DateOfBirth = theYesterdayRegistrations.DateOfBirth,
                        theYesterdayRegistrations.LicenceNumber,
                        theYesterdayRegistrations.PhoneNumber
                    })
                    .ToList()
                    .Select(row => new
                    {
                        row.ClientId,
                        row.Name,
                        DateOfBirth = row.DateOfBirth == null ? " " : row.DateOfBirth.Value.ToString("dd-MMM-yyyy"),
                        row.LicenceNumber,
                        row.PhoneNumber
                    })
                    .ToList();

            }
            catch (Exception ex) {
                Error.FrontendHandler(HttpStatusCode.ServiceUnavailable, "We've been unable to process your request.");
            }
            return yesterdayRegistration;
        }

        private object GetClientHoverUnpaidCourses(int OrganisationId)
        {
            var unpaid = new Object();

            try
            {
                unpaid = atlasDBViews.vwUnpaidCourseClients
                    .Where(
                        theUnpaid => theUnpaid.OrganisationId == OrganisationId
                    )
                    .Select(theUnpaidCourse => new
                    {
                        ClientId = theUnpaidCourse.ClientSystemId,
                        Name = theUnpaidCourse.ClientName,
                        DateOfBirth = theUnpaidCourse.DateOfBirth,
                        theUnpaidCourse.LicenceNumber,
                        theUnpaidCourse.PhoneNumber,
                        CourseId = theUnpaidCourse.CourseId,
                        CourseStartDate = theUnpaidCourse.CourseStartDate,
                        CourseTypeTitle = theUnpaidCourse.CourseTypeTitle,
                    })
                    .ToList()
                    .Select(row => new
                     {
                        row.ClientId,
                        row.Name,
                        DateOfBirth = row.DateOfBirth == null ? " " : row.DateOfBirth.Value.ToString("dd-MMM-yyyy"),
                        row.LicenceNumber,
                        row.PhoneNumber,
                        Course = String.Format("{0} : {1} : {2}", row.CourseId.ToString(), (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                     })
                    .ToList();

            }
            catch (Exception ex) {
                Error.FrontendHandler(HttpStatusCode.ServiceUnavailable, "We've been unable to process your request.");
            }
            return unpaid;
        }

        private object GetCourseAttendanceUpdatesDueNumber(int OrganisationId)
        {

            //var list = Enumerable.Range(0, 1).Select(e => new { Course = "228970 : " + DateTime.Now.ToShortDateString().ToString() + " :  Type Title 1", Trainer ="Trainer 1", TrainerID = "1", Email = "Email1@blah.com", Mobile = "M 111", Home = "H 111", Work = "W 111"}).ToList();
            //list.Add(new { Course = "228969 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 2", Trainer = "Trainer 2", TrainerID = "2", Email = "Email2@blah.com", Mobile = "M 222", Home = "H 222", Work = "W 222" });
            //list.Add(new { Course = "228968 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 3", Trainer = "Trainer 3", TrainerID = "3", Email = "Email3@blah.com", Mobile = "M 333", Home = "H 333", Work = "W 333" });
            //list.Add(new { Course = "228967 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 4", Trainer = "Trainer 4", TrainerID = "4", Email = "Email4@blah.com", Mobile = "M 444", Home = "H 444", Work = "W 444" });
            //list.Add(new { Course = "228966 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 5", Trainer = "Trainer 5", TrainerID = "5", Email = "Email5@blah.com", Mobile = "M 555", Home = "H 555", Work = "W 555" });
            //list.Add(new { Course = "228965 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 6", Trainer = "Trainer 6", TrainerID = "6", Email = "Email6@blah.com", Mobile = "M 666", Home = "H 666", Work = "W 666" });
            //return list;

            var attendanceUpdatesDueNumber = new Object();
            try
            {
                attendanceUpdatesDueNumber = atlasDBViews.vwCoursesWithMissingAttendances
                    .Where(
                        today =>
                            today.OrganisationId == OrganisationId
                    )
                    .Select(theAttendanceUpdatesDueNumbers => new
                    {
                        CourseId = theAttendanceUpdatesDueNumbers.CourseId,
                        CourseStartDate = theAttendanceUpdatesDueNumbers.CourseStartDate,
                        CourseTypeTitle = theAttendanceUpdatesDueNumbers.CourseTypeTitle,
                        Trainer = theAttendanceUpdatesDueNumbers.TrainerName,
                        TrainerId = theAttendanceUpdatesDueNumbers.TrainerId,
                        Email = theAttendanceUpdatesDueNumbers.TrainerEmail,
                        Mobile = theAttendanceUpdatesDueNumbers.TrainerMobileNumber,
                        Home = theAttendanceUpdatesDueNumbers.TrainerHomeNumber,
                        Work = theAttendanceUpdatesDueNumbers.TrainerWorkNumber
                    })
                    .ToList()
                    .Select(row => new
                     {
                         Course = String.Format("{0} : {1} : {2}",  row.CourseId.ToString(), (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                         row.Trainer,
                         row.TrainerId,
                         row.Email,
                         row.Mobile,
                         row.Home,
                         row.Work
                     })
                    .ToList();
            }
            catch (Exception ex)
            {
                Error.FrontendHandler(HttpStatusCode.ServiceUnavailable, "We've been unable to process your request.");
            }
            return attendanceUpdatesDueNumber;
        }

        private object GetCourseAttendanceVerificationsDueNumber(int OrganisationId)
        {
            //var list = Enumerable.Range(0, 1).Select(e => new { Course = "228969 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 1" }).ToList();
            //list.Add(new { Course = "228970 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 2" });
            //return list;

            var attendanceVerificationsDueNumber = new Object();
            try
            {
                attendanceVerificationsDueNumber = atlasDBViews.vwCoursesWithMissingAttendanceVerifications
                    .Where(
                        today =>
                            today.OrganisationId == OrganisationId
                    )
                    .Select(theAttendanceVerificationsDueNumber => new
                    {
                        CourseId = theAttendanceVerificationsDueNumber.CourseId,
                        CourseStartDate = theAttendanceVerificationsDueNumber.CourseStartDate,
                        CourseTypeTitle = theAttendanceVerificationsDueNumber.CourseTypeTitle,
                    })
                    .ToList()
                    .Select(row => new
                    {
                        Course = String.Format("{0} : {1} : {2}", row.CourseId.ToString(), (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                    })
                    .ToList();
            }
            catch (Exception ex)
            {
                Error.FrontendHandler(HttpStatusCode.ServiceUnavailable, "We've been unable to process your request.");
            }
            return attendanceVerificationsDueNumber;
        }

        private object GetCourseOutstandingCoursePayments(int OrganisationId)
        {

            //var list = Enumerable.Range(0, 1).Select(e => new { ClientId = 3009109, Name = "Client Name 1", DateOfBirth = DateTime.Now.AddYears(-33), Licence = "Lic No. 1", PhoneNumber = "Phone Number 1", Course = "22 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 1" }).ToList();
            //list.Add(new { ClientId = 2692586, Name = "Client Name 2", DateOfBirth = DateTime.Now.AddYears(-52), Licence = "Lic No. 2", PhoneNumber = "Phone Number21", Course = "306 : " + DateTime.Now.ToShortDateString().ToString() + " : Type Title 2" });
            //return list;


            var outstandingCoursePayments = new Object();
            try
            {
                outstandingCoursePayments = atlasDBViews.vwUnpaidCourseClients
                    .Where(
                        today =>
                            today.OrganisationId == OrganisationId
                    )
                    .Select(theOutstandingCoursePayments => new
                    {
                        ClientId = theOutstandingCoursePayments.ClientSystemId,
                        Name = theOutstandingCoursePayments.ClientName,
                        DateOfBirth = theOutstandingCoursePayments.DateOfBirth,
                        Licence = theOutstandingCoursePayments.LicenceNumber,
                        theOutstandingCoursePayments.PhoneNumber,
                        CourseId = theOutstandingCoursePayments.CourseId,
                        CourseStartDate = theOutstandingCoursePayments.CourseStartDate,
                        CourseTypeTitle = theOutstandingCoursePayments.CourseTypeTitle,
                    })
                    .ToList()
                    .Select(row => new
                    {
                        row.ClientId,
                        row.Name,
                        DateOfBirth = row.DateOfBirth == null ? " " : row.DateOfBirth.Value.ToString("dd-MMM-yyyy"),
                        row.Licence,
                        row.PhoneNumber,
                        Course = String.Format("{0} : {1} : {2}", row.CourseId.ToString(), (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                    })
                    .ToList();
            }
            catch (Exception ex)
            {
                Error.FrontendHandler(HttpStatusCode.ServiceUnavailable, "We've been unable to process your request.");
            }
            return outstandingCoursePayments;
        }

        object GetClientsRegisteredOnlineWithAdditionalRequirements(int organisationId, bool today)
        {
            var clients = atlasDBViews.vwClientsBookedOnlineWithSpecialRequirements
                                    .Where(c => c.OrganisationId == organisationId &&
                                            (today ? (c.RegisteredOnlineToday == 1) : true))
                                    .ToList()
                                    .Select(row => new
                                    {
                                        row.ClientId,
                                        Name = row.ClientName,
                                        DateOfBirth = row.DateOfBirth == null ? " " : row.DateOfBirth.Value.ToString("dd-MMM-yyyy"),
                                        row.LicenceNumber,
                                        row.PhoneNumber,
                                        Course = String.Format("{0} : {1} : {2}", row.CourseId.ToString(), (row.coursestartdate != null ? row.coursestartdate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                                    });

            return clients;
        }

        object GetClientsUnableToUpdateInDORS(int organisationId)
        {
            var clients = atlasDBViews.vwClientsUnableToUpdateInDORS
                                    .Where(c => c.OrganisationId == organisationId)
                                    .ToList()
                                    .Select(row => new
                                    {
                                        ClientId = row.ClientId,
                                        Name = row.ClientName,
                                        LicenceNumber = row.LicenceNumber,
                                        TransferringFromCourse = row.TransferredFromCourseId,
                                        CourseId = row.CourseId,
                                        Course = String.Format("{0} : {1} : {2}", row.Reference, (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                                        CourseStartDate = (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("yyyyMMdd") : ""),
                                        PossibleReason = row.PossibleReason 
                                    });

            return clients;
        }

        object GetAttendanceNotUploadedToDORS(int organisationId)
        {
            var clients = atlasDBViews.vwAttendanceNotUploadedToDORS
                                    .Where(c => c.OrganisationId == organisationId)
                                    .ToList()
                                    .Select(row => new
                                    {
                                        ClientId = row.ClientId,
                                        Name = row.ClientName,
                                        LicenceNumber = row.LicenceNumber,
                                        CourseId = row.CourseId,
                                        Course = String.Format("{0} : {1} : {2} : {3}", row.Reference, row.CourseId.ToString(), (row.CourseStartDate != null ? row.CourseStartDate.Value.ToString("dd-MMM-yyyy") : " "), row.CourseTypeTitle),
                                        DORSClientIdentifier = row.DORSClientIdentifier,
                                        DORSCourseIdentifier = row.DORSCourseIdentifier
                                    });

            return clients;
        }

        object GetClientsWithMissingReferringAuthority(int organisationId, string timeframe)
        {
            // Default to created this week, change if other timeframe. 
            // Anonymous type restricts instantiation

            var clients = atlasDBViews.vwClientsWithMissingDORSDatas
                                        .Where(x => x.OrganisationId == organisationId && x.CreatedThisWeek == true)
                                        .ToList()
                                        .Select(row => new
                                        {
                                            ClientId = row.ClientId,
                                            Name = row.ClientName,
                                            LicenceNumber = row.ClientLicenceNumber,
                                            DORSScheme = row.DORSSchemeIdentifierName
                                        });

            if (timeframe == "ThisMonth")
            {
                clients = atlasDBViews.vwClientsWithMissingDORSDatas
                                        .Where(x => x.OrganisationId == organisationId && x.CreatedThisMonth == true)
                                        .ToList()
                                        .Select(row => new
                                        {
                                            ClientId = row.ClientId,
                                            Name = row.ClientName,
                                            LicenceNumber = row.ClientLicenceNumber,
                                            DORSScheme = row.DORSSchemeIdentifierName
                                        });
            }
            else if (timeframe == "LastMonth")
            {
                clients = atlasDBViews.vwClientsWithMissingDORSDatas
                                        .Where(x => x.OrganisationId == organisationId && x.CreatedLastMonth == true)
                                        .ToList()
                                        .Select(row => new
                                        {
                                            ClientId = row.ClientId,
                                            Name = row.ClientName,
                                            LicenceNumber = row.ClientLicenceNumber,
                                            DORSScheme = row.DORSSchemeIdentifierName
                                        });
            }

            return clients;
        }
    }
}