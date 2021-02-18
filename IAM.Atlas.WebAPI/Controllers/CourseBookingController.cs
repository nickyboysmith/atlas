using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models.Payment;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseBookingController : AtlasBaseController
    {

        [Route("api/coursebooking")]
        [AuthorizationRequired]
        // POST api/<controller>
        public bool Post([FromBody] FormDataCollection formBody)
        {
            var booked = false;
            var courseId = StringTools.GetIntOrFail("courseId", ref formBody, "Invalid course Id");
            var clientId = StringTools.GetIntOrFail("clientId", ref formBody, "Invalid client Id");
            var userId = StringTools.GetIntOrFail("userId", ref formBody, "Invalid user Id");
            var amount = StringTools.GetDecimal("amount", ref formBody);

            var courseController = new CourseController();
            var dorsController = new DORSWebServiceInterfaceController();

            // perform a DORS lookup, to prepare the client's records for booking a course (creating an entry in ClientDORSData).
            var clientLicence = atlasDB.ClientLicence
                                        .Where(cl => cl.ClientId == clientId)
                                        .OrderByDescending(cl => cl.Id)
                                        .FirstOrDefault();
            if(clientLicence != null)
            {
                if (!string.IsNullOrEmpty(clientLicence.LicenceNumber))
                {
                    try
                    {
                        var dorsOffers = dorsController.PerformDORSCheck(clientId, clientLicence.LicenceNumber);
                    } catch(Exception ex)
                    {
                        LogError("api/coursebooking - PerformDORSCheck(" + clientId.ToString() + "," + clientLicence.LicenceNumber, ex);
                    }
                    // book the client on the course
                    booked = courseController.Book(clientId, courseId, userId);
                }
            }

            return booked;

            //var courseId = StringTools.GetIntOrFail("courseId", ref formBody, "Invalid course Id");
            //var clientId = StringTools.GetIntOrFail("clientId", ref formBody, "Invalid client Id");
            //var userId = StringTools.GetIntOrFail("userId", ref formBody, "Invalid user Id");
            //var amount = StringTools.GetDecimal("amount", ref formBody);

            //var maximumBookableCoursePlaces = 0;
            //var bookedCoursePlaces = 0;

            //try
            //{
            //    // Course client count
            //    // check that the max places is less than course client count
            //    var checkCourseClient = atlasDB.Course
            //        .Include("CourseClients")
            //        .Include("CourseVenue")
            //        .Where(
            //            theCourse =>
            //                theCourse.Id == courseId
            //        )
            //        .FirstOrDefault();

            //    maximumBookableCoursePlaces = checkCourseClient.CourseVenue.FirstOrDefault().MaximumPlaces;
            //    bookedCoursePlaces = checkCourseClient.CourseClients.Count;

            //    if (bookedCoursePlaces < maximumBookableCoursePlaces)
            //    {

            //        //check if the course client record already exists as this can be called many times if the client goes back in the browser durning client registartion
            //        var existingCourseClient = atlasDB.CourseClients
            //            .Where(x => x.ClientId == clientId && x.CourseId == courseId).FirstOrDefault();


            //        if (existingCourseClient == null)
            //        {
            //            var courseClient = new CourseClient();
            //            courseClient.ClientId = clientId;
            //            courseClient.CourseId = courseId;
            //            courseClient.DateAdded = DateTime.Now;
            //            courseClient.AddedByUserId = userId;
            //            courseClient.TotalPaymentDue = amount;
            //            courseClient.UpdatedByUserId = userId;

            //            atlasDB.CourseClients.Add(courseClient);
            //        }

            //        // get client booking state
            //        var theCurrentClientOnlineBookingState = atlasDB.ClientOnlineBookingStates
            //            .Where(
            //                bookingState =>
            //                    bookingState.ClientId == clientId
            //            )
            //            .FirstOrDefault();

            //        // Create object
            //        theCurrentClientOnlineBookingState.CourseBooked = true;
            //        theCurrentClientOnlineBookingState.CourseId = courseId;
            //        theCurrentClientOnlineBookingState.DateTimeCourseBooked = DateTime.Now;
            //        theCurrentClientOnlineBookingState.AgreedToTermsAndConditions = true;
            //        theCurrentClientOnlineBookingState.DateTimeAgreedToTermsAndConditions = DateTime.Now;


            //        // Update object
            //        var onlineBookingStateEntry = atlasDB.Entry(theCurrentClientOnlineBookingState);
            //        onlineBookingStateEntry.State = System.Data.Entity.EntityState.Modified;


            //        // Save the changes
            //        // update the client online booking state table

            //        atlasDB.SaveChanges();


            //    }
            //    else
            //    {
            //        // no spaces left
            //        Error.FrontendHandler(HttpStatusCode.Forbidden, "CourseFullyBooked");
            //    }

            //}
            //catch (Exception ex)
            //{

            //    throw (ex);
            //    Error.FrontendHandler(HttpStatusCode.Forbidden, "There has been an error processing your request");

            //}

            //return true;
        }

        [AuthorizationRequired]
        [Route("api/coursebooking/payment")]
        [HttpPost]
        public PaymentFrontendStructure PayCourseBooking([FromBody] FormDataCollection formBody)
        {

            // Get the client Id
            var clientId = StringTools.GetInt("clientId", ref formBody);

            // Get the token
            var token = this.Request.Headers.GetValues("X-Auth-Token").ToList();
            var theToken = token[0];

            // Get the Client IP
            var clientIP = GetIPAddress();

            // Instantiate the payment controller class
            // Passing the token & ip
            var payment = new PaymentController(theToken, clientIP);
            var paymentResult = payment.Post(formBody);

            // Check to see that we are getting the correct structure back
            if (paymentResult.GetType().Name == "PaymentFrontendStructure")
            {

                // Update the client booking state
                try
                {

                    // If the pament is not a 3d secure auth
                    if (paymentResult.Is3DSecureRequest == false)
                    {
                        // Get the record
                        var clientBooking = atlasDB.ClientOnlineBookingStates
                            .Where(
                                client =>
                                client.ClientId == clientId
                            )
                            .FirstOrDefault();

                        // Update values
                        clientBooking.FullPaymentRecieved = true;
                        clientBooking.DateTimePaymentRecieved = DateTime.Now;

                        // Modify values
                        var entry = atlasDB.Entry(clientBooking);
                        entry.State = System.Data.Entity.EntityState.Modified;

                        // Save values
                        atlasDB.SaveChanges();
                    }



                }
                catch (DbEntityValidationException ex)
                {
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "We're having issues on our end. Please retry!");
                }
                catch (Exception ex)
                {
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "There has been an issue. Please retry!");
                }

            }
            else
            {
                Error.FrontendHandler(HttpStatusCode.Forbidden, "There was an issue with your payment. If this issue persists please contact support.");
            }

            return paymentResult;
        }

        [AuthorizationRequired]
        [Route("api/coursebooking/payment/AuthorizationCompletion")]
        [HttpPost]
        public PaymentFrontendStructure CompleteAuth([FromBody] FormDataCollection formBody)
        {

            // Get the client Id
            var clientId = StringTools.GetInt("clientId", ref formBody);

            // Instantiate the payment controller class
            var payment = new PaymentController();
            var paymentResult = payment.CompleteAuthorization(formBody);

            // Check to see that we are getting the correct structure back
            if (paymentResult.GetType().Name == "PaymentFrontendStructure")
            {

                // Update the client booking state
                try
                {

                    // Get the record
                    var clientBooking = atlasDB.ClientOnlineBookingStates
                        .Where(
                            client =>
                            client.ClientId == clientId
                        )
                        .First();

                    // Update values
                    clientBooking.FullPaymentRecieved = true;
                    clientBooking.DateTimePaymentRecieved = DateTime.Now;

                    // Modify values
                    var entry = atlasDB.Entry(clientBooking);
                    entry.State = System.Data.Entity.EntityState.Modified;

                    // Save values
                    atlasDB.SaveChanges();

                }
                catch (DbEntityValidationException ex)
                {
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "We're having issues on our end. Please retry!");
                }
                catch (Exception ex)
                {
                    Error.FrontendHandler(HttpStatusCode.InternalServerError, "There has been an issue. Please retry!");
                }

            }
            else
            {
                Error.FrontendHandler(HttpStatusCode.Forbidden, "There was an issue with your payment. If this issue persists please contact support.");
            }

            return paymentResult;
        }

    }
}