using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class RecordPaymentController : AtlasBaseController
    {


        // GET api/RecordPayment
        public object Get()
        {
            return "";
        }



        // POST api/RecordPayment
        public string Post([FromBody] FormDataCollection formBody)
        {
            var isAssignedTo = StringTools.GetString("isAssignedTo", ref formBody);

            var userId = StringTools.GetIntOrFail("userId", ref formBody, "Invalid user Id");


            // Main Payment Variables
            var mainPaymentTypeId = StringTools.GetIntOrFail("main[type][Id]", ref formBody, "Payment Type isnt valid");
            var mainPaymentMethodId = StringTools.GetIntOrFail("main[method][Id]", ref formBody, "Payment Method not valid");
            var mainAmount = StringTools.GetDecimal("main[amount]", ref formBody);
            var paymentFrom = StringTools.GetString("from", ref formBody);
            var paymentAuthCode = StringTools.GetString("authCode", ref formBody);
            var paymentReceiptNumber = StringTools.GetString("receiptNo", ref formBody);
            var paymentDate = StringTools.GetDateOrFail("date", ref formBody, "Invalid date");

            // Additional Payment Variables
            var additionalPaymentTypeId = StringTools.GetInt("additional[type][Id]", ref formBody);
            var additionalPaymentAmount = StringTools.GetDecimal("additional[amount]", ref formBody);

            // Payment note
            var paymentNote = StringTools.GetString("note", ref formBody);

            // Client Id
            var clientId = StringTools.GetInt("clientId", ref formBody);

            // Course List Array
            var courseListCount = ArrayTools.ArrayLength("courses", ref formBody);

            // Get Payment Id if exists
            var paymentId = StringTools.GetInt("paymentId", ref formBody);

            //if (paymentId != 0) // Just whilst testing
            //{
            //    throw new HttpResponseException(
            //        new HttpResponseMessage(HttpStatusCode.BadRequest)
            //        {
            //            Content = new StringContent("Getting the payment Id " + paymentId),
            //            ReasonPhrase = "We can't process your request."
            //        }
            //    );
            //}

            try
            {

                // Main Payment 
                var payment = new Payment();

                payment.DateCreated = DateTime.Now;
                payment.TransactionDate = paymentDate;
                payment.Amount = mainAmount;
                payment.PaymentTypeId = mainPaymentTypeId;
                payment.PaymentMethodId = mainPaymentMethodId;
                payment.ReceiptNumber = paymentReceiptNumber;
                payment.AuthCode = paymentAuthCode;
                payment.CreatedByUserId = userId;
                payment.UpdatedByUserId = userId;
                payment.PaymentName = paymentFrom;

                if (paymentId == 0) {
                    // Add the payment to the payment table
                    atlasDB.Payment.Add(payment);
                }
                else {
                    // update payment
                    payment.Id = paymentId;
                    var checkPaymentExists = atlasDB.Payment.Find(paymentId);
                    var paymentEntry = atlasDB.Entry(checkPaymentExists);
                    paymentEntry.CurrentValues.SetValues(payment);
                }


                // Check to see if an additional payment has been recorded
                if (additionalPaymentTypeId != 0 && additionalPaymentAmount != 0)
                {
                    // Create a separate payment
                    var additionalPayment = new Payment();

                    additionalPayment.DateCreated = DateTime.Now;
                    additionalPayment.TransactionDate = paymentDate;
                    additionalPayment.Amount = additionalPaymentAmount;
                    additionalPayment.PaymentTypeId = additionalPaymentTypeId;
                    additionalPayment.PaymentMethodId = mainPaymentMethodId;
                    additionalPayment.ReceiptNumber = paymentReceiptNumber;
                    additionalPayment.AuthCode = paymentAuthCode;
                    additionalPayment.CreatedByUserId = userId;
                    additionalPayment.UpdatedByUserId = userId;
                    additionalPayment.PaymentName = paymentFrom;

                    // Link payments
                    var paymentLink = new PaymentLink();
                    paymentLink.Payment = payment;
                    paymentLink.Payment1 = additionalPayment;
                    paymentLink.DateLinked = DateTime.Now;


                    // Add the payment link to the payment table
                    atlasDB.PaymentLinks.Add(paymentLink);


                    //If course id is known, add the additional payment to CourseClientPayment.
                    if (courseListCount > 0)
                    {
                        var additionalCourseClientPayment = new CourseClientPayment();
                        additionalCourseClientPayment.CourseId = StringTools.GetInt("courses[0][CourseId]", ref formBody);
                        additionalCourseClientPayment.ClientId = clientId;
                        additionalCourseClientPayment.Payment = additionalPayment;
                        additionalCourseClientPayment.AddedByUserId = userId;
                        atlasDB.CourseClientPayments.Add(additionalCourseClientPayment);
                    }
                }

                // Check to see if a note has been added
                if (!string.IsNullOrEmpty(paymentNote))
                {
                    var note = new Note();
                    note.Note1 = paymentNote;
                    note.DateCreated = DateTime.Now;
                    note.CreatedByUserId = userId;

                    var thePaymentNote = new PaymentNote();
                    thePaymentNote.Payment = payment;
                    thePaymentNote.Note = note;

                    // Add the payment note to the payment note table
                    atlasDB.PaymentNotes.Add(thePaymentNote);

                    // Check that the cliend id isnt 0
                    // Check that is assigned to is 'client' or 'clientCourse'
                    if (clientId != 0 && (isAssignedTo == "client" || isAssignedTo == "clientCourse"))
                    {
                        var clientNote = new ClientNote();
                        clientNote.Note = note;
                        clientNote.ClientId = clientId;

                        // Also add the note to the client note table
                        atlasDB.ClientNotes.Add(clientNote);
                    }
                }

                // If a client has been assigned 
                // 
                if (clientId != 0 && (isAssignedTo == "client" || isAssignedTo == "clientCourse"))
                {
                    var clientPayment = new ClientPayment();
                    clientPayment.ClientId = clientId;
                    clientPayment.Payment = payment;
                    clientPayment.AddedByUserId = userId;

                    if (paymentId == 0) {
                        // Add the payment to the client payment table
                        atlasDB.ClientPayment.Add(clientPayment);
                    }
                    else {
                        // update client payment
                        var checkClientPaymentExists = atlasDB.ClientPayment
                            .Where(
                                theClientPayment => 
                                theClientPayment.PaymentId == paymentId
                            ).FirstOrDefault();

                        //Check to see if a client exists
                        // If it doesnt then add it to the db
                        if (checkClientPaymentExists == null) {
                            atlasDB.ClientPayment.Add(clientPayment);
                        }
                        else {
                            var clientPaymentEntry = atlasDB.Entry(checkClientPaymentExists);
                            clientPaymentEntry.CurrentValues.SetValues(clientPayment);
                        }

                    }

                }

                // If a course has been assigned to a client
                if (courseListCount != 0 && isAssignedTo == "clientCourse")
                {
                    for (int i = 0; i < courseListCount; i++)
                    {
                        var courseId = StringTools.GetIntOrFail("courses[" + i + "][CourseId]", ref formBody, "Invalid Course Id");
                        var courseClientPayment = new CourseClientPayment();
                        courseClientPayment.ClientId = clientId;
                        courseClientPayment.Payment = payment;
                        courseClientPayment.CourseId = courseId;

                        if (paymentId == 0)
                        {
                            // Add to the CourseClientPayment table
                            atlasDB.CourseClientPayments.Add(courseClientPayment);
                        }
                        else {
                            // update course
                            var checkCourseClientPaymentExists = atlasDB.ClientPayment
                                .Where(
                                    theCourseClientPayment =>
                                    theCourseClientPayment.PaymentId == paymentId
                                ).FirstOrDefault();

                            //Check to see if a client exists
                            // If it doesnt then add it to the db
                            if (checkCourseClientPaymentExists == null)
                            {
                                atlasDB.CourseClientPayments.Add(courseClientPayment);
                            }
                            else {
                                var courseClientPaymentEntry = atlasDB.Entry(checkCourseClientPaymentExists);
                                courseClientPaymentEntry.CurrentValues.SetValues(courseClientPayment);
                            }
                        }
                    }
                }

                atlasDB.SaveChanges();
                return "Payment recorded successfully!";

            } catch (DbEntityValidationException ex) {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }


        }





    }
}