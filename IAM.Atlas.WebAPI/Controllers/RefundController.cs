using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Web.Http.ModelBinding;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class RefundController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/Refund/GetRefundMethods/{organisationId}")]
        public List<RefundMethod> GetRefundMethods(int organisationId)
        {
            var methods = atlasDB.RefundMethods.Where(rm => rm.OrganisationId == organisationId).ToList();
            return methods;
        }

        [HttpGet]
        [Route("api/Refund/GetRefundTypes/{organisationId}")]
        public List<RefundType> GetRefundTypes(int organisationId)
        {
            var types = atlasDB.RefundTypes.Where(rt => rt.OrganisationId == organisationId).ToList();
            return types;
        }

        [HttpGet]
        [Route("api/Refund/{Id}")]
        public Refund Get(int Id)
        {
            var refund = atlasDB.Refunds.Where(r => r.Id == Id).FirstOrDefault();
            return refund;
        }

        [HttpGet]
        [Route("api/Refund/GetRefundsByPayment/{PaymentId}")]
        public List<Refund> GetRefundsByPayment(int PaymentId)
        {
            // @TODO: create a view for this refund calculation (ie how much has been refunded etc)
            var refunds = atlasDB.Refunds
                                    .Include(r => r.RefundPayments)
                                    .Where(r => r.RefundPayments.Any(rp => rp.PaymentId == PaymentId))
                                    //.Select(r => new {

                                    //})
                                    .ToList();
            return refunds;
        }

        [HttpGet]
        [Route("api/Refund/GetRefundsByClient/{ClientId}")]
        public List<Refund> GetRefundsByClient(int ClientId)
        {
            // @TODO: create a view for this refund calculation (ie how much has been refunded etc)
            var refunds = atlasDB.Refunds
                                    .Include(r => r.RefundPayments)
                                    .Include(r => r.RefundPayments.Select(rp => rp.Payment))
                                    .Include(r => r.RefundPayments.Select(rp => rp.Payment).Select(p => p.ClientPayment))
                                    .Where(r => r.RefundPayments.Any(rp => rp.Payment.ClientPayment.Any(cp => cp.ClientId == ClientId)))
                                    .ToList();
            return refunds;
        }

        [HttpGet]
        [Route("api/Refund/GetPaymentRefundedAmount/{PaymentId}")]
        public decimal GetPaymentRefundedAmount(int PaymentId)
        {
            // @TODO: create a view for this refund calculation (ie how much has been refunded etc)
            decimal refundedAmount = 0;
            var refunds = GetRefundsByPayment(PaymentId);
            foreach(var refund in refunds)
            {
                if(refund.Amount != null)
                {
                    refundedAmount += (decimal)refund.Amount;
                }
            }
            return refundedAmount;
        }

        [HttpGet]
        [Route("api/Refund/Cancel/{RefundPaymentId}/{CancelledByUserId}")]
        public bool Cancel(int RefundPaymentId, int CancelledByUserId)
        {
            var cancelled = false;
            var refundPayment = atlasDB.RefundPayments.Where(rp => rp.RefundPaymentId == RefundPaymentId).FirstOrDefault();
            if(refundPayment != null)
            {
                var cancelledRefund = new CancelledRefund();
                cancelledRefund.CancelledByUserId = CancelledByUserId;
                cancelledRefund.DateCancelled = DateTime.Now;
                cancelledRefund.RefundId = refundPayment.RefundId;
                // add to the database
                atlasDB.CancelledRefunds.Add(cancelledRefund);
                atlasDB.SaveChanges();
                cancelled = true;
            }
            return cancelled;
        }

        [HttpGet]
        [Route("api/Refund/CancelRequest/{RefundId}/{CancelledByUserId}")]
        public bool CancelRequest(int refundId, int cancelledByUserId)
        {
            var cancelled = false;

            try
            {

                var refundRequest = atlasDB.RefundRequests.Where(rr => rr.Id == refundId).FirstOrDefault();
                if (refundRequest != null)
                {
                    var cancelledRefundRequest = new CancelledRefundRequest();
                    cancelledRefundRequest.CancelledByUserId = cancelledByUserId;
                    cancelledRefundRequest.DateCancelled = DateTime.Now;
                    cancelledRefundRequest.RefundRequestId = refundId;

                    // add to the database
                    atlasDB.CancelledRefundRequests.Add(cancelledRefundRequest);
                    atlasDB.SaveChanges();
                    cancelled = true;
                }
            } catch (Exception ex) {
                cancelled = false;
            }
            return cancelled;
        }

        [HttpPost]
        public bool Post([FromBody] FormDataCollection formBody)
        {
            bool success = false;
            var refundForm = formBody.ReadAs<RefundPaymentForm>();
            var refFormBody = formBody;
            // TODO: get the transactionDate to deserialize into the RefundPaymentForm
            var transactionDate = StringTools.GetDate("TransactionDate", "dd/MM/yyyy", ref refFormBody);
            refundForm.TransactionDate = transactionDate == null ? DateTime.Now : (DateTime) transactionDate;

            // TODO: do i create a payment for the refund?
            //var paymentForRefund = new Payment();
            //paymentForRefund.Amount = refundForm.Amount;
            //paymentForRefund.CreatedByUserId = refundForm.CreatedByUserId;
            //paymentForRefund.DateCreated = DateTime.Now;
            //paymentForRefund.Refund = true;
            //paymentForRefund.TransactionDate = refundForm.TransactionDate;
            //paymentForRefund.Reference = refundForm.Reference;           

            // save the refund
            var refund = new Refund();
            refund.Amount = refundForm.Amount;
            refund.DateCreated = DateTime.Now;
            refund.CreatedByUserId = refundForm.CreatedByUserId;
            refund.OrganisationId = refundForm.OrganisationId;
            refund.PaymentName = refundForm.PaymentName;
            refund.Reference = refundForm.Reference;
            refund.RefundMethodId = refundForm.RefundMethodId;
            refund.RefundTypeId = refundForm.RefundTypeId;
            refund.TransactionDate = refundForm.TransactionDate;
            if (!string.IsNullOrEmpty(refundForm.Notes))
            {
                var note = new Note();
                note.CreatedByUserId = refundForm.CreatedByUserId;
                note.DateCreated = DateTime.Now;
                note.Note1 = refundForm.Notes;

                var refundNote = new RefundNote();
                refundNote.Note = note;

                refund.RefundNotes.Add(refundNote);
            }
                
            // create a refundPayment
            var refundPayment = new RefundPayment();
            refundPayment.Refund = refund;
            refundPayment.PaymentId = refundForm.PaymentId;
            atlasDB.RefundPayments.Add(refundPayment);

            //Check to see if there is a RefundRequest
            var refundRequest = atlasDB.RefundRequests
                    .Where(rr => rr.RelatedPaymentId == refundForm.PaymentId && rr.RequestDone == false)
                    .FirstOrDefault();

            //Set refund request to done if we have one
            if (refundRequest != null)
            {
                refundRequest.RequestDone = true;
                atlasDB.Entry(refundRequest).Property("RequestDone").IsModified = true;

                refundRequest.DateRequestDone = DateTime.Now;
                atlasDB.Entry(refundRequest).Property("DateRequestDone").IsModified = true;

                refundRequest.RequestDoneByUserId = refundForm.CreatedByUserId;
                atlasDB.Entry(refundRequest).Property("RequestDoneByUserId").IsModified = true;
            }

            atlasDB.SaveChanges();

            RevertDORSClientToBooked(refundForm.PaymentId);
            
            success = true;
            return success;
        }

        /// <summary>
        /// Checks to see if there is a DORS client at "booked and paid" status, if yes revert to booked.
        /// </summary>
        /// <param name="paymentId"></param>
        void RevertDORSClientToBooked(int paymentId)
        {
            var courseClientPayment = atlasDB.CourseClientPayments
                                                .Include(ccp => ccp.Client)
                                                .Include(ccp => ccp.Client.CourseDORSClients)
                                                .Include(ccp => ccp.Client.ClientDORSDatas)
                                                .Include(ccp => ccp.Client.ClientDORSDatas.Select(cdd => cdd.DORSAttendanceState))
                                                .Where(ccp => ccp.PaymentId == paymentId)
                                                .FirstOrDefault();
            if(courseClientPayment != null)
            {
                var courseDORSClient = courseClientPayment.Client
                                            .CourseDORSClients
                                                .Where(cdc => cdc.CourseId == courseClientPayment.CourseId && cdc.ClientId == courseClientPayment.ClientId)
                                                .FirstOrDefault();
                if(courseDORSClient != null)
                {
                    if (!ClientFullyPaidForCourse(courseDORSClient))
                    {
                        courseDORSClient.PaidInFull = false;
                        courseDORSClient.DateDORSNotified = null;
                        courseDORSClient.DORSNotified = false;

                        var dbEntry = atlasDB.Entry(courseDORSClient);
                        dbEntry.State = EntityState.Modified;
                        atlasDB.SaveChanges();
                    }
                }
            }
        }

        bool ClientFullyPaidForCourse(CourseDORSClient courseDORSClient)
        {
            var fullyPaid = false;
            
            // find out how much money has been paid for this course
            var totalPaid = atlasDB.CourseClientPayments.Where(ccp => ccp.ClientId == courseDORSClient.ClientId && ccp.CourseId == courseDORSClient.CourseId).Sum(ccp => ccp.Payment.Amount);

            // @TODO: find out how much money has been refunded for this course 
            // currently refunds are not entered into course client payments... should this be changed?

            // How much does the course cost?
            var courseClient = atlasDB.CourseClients.Where(cc => cc.CourseId == courseDORSClient.CourseId && cc.ClientId == courseDORSClient.ClientId).FirstOrDefault();

            if (courseClient != null)
            {
                fullyPaid = courseClient.TotalPaymentDue - totalPaid <= 0;
            }

            // @TODO: not sure what is happening with payment transfers 

            return fullyPaid;
        }

        [HttpPost]
        [Route("api/Refund/SaveRefundRequest/")]
        public bool SaveRefundRequest([FromBody] FormDataCollection formBody)
        {
            bool success = false;
            var refundRequestForm = formBody.ReadAs<RequestRefundPaymentForm>();
            var refFormBody = formBody;
            // TODO: get the transactionDate to deserialize into the RefundPaymentForm
            var transactionDate = StringTools.GetDate("TransactionDate", "dd/MM/yyyy", ref refFormBody);
            refundRequestForm.TransactionDate = transactionDate == null ? DateTime.Now : (DateTime)transactionDate;     

            // save the refund request
            var refundRequest = new RefundRequest();
            refundRequest.Amount = refundRequestForm.Amount;
            refundRequest.DateCreated = DateTime.Now;
            refundRequest.CreatedByUserId = refundRequestForm.CreatedByUserId;
            refundRequest.OrganisationId = refundRequestForm.OrganisationId;
            refundRequest.PaymentName = refundRequestForm.PaymentName;
            refundRequest.Reference = refundRequestForm.Reference;
            refundRequest.RefundMethodId = refundRequestForm.RefundMethodId;
            refundRequest.RefundTypeId = refundRequestForm.RefundTypeId;
            refundRequest.RequestDate = refundRequestForm.TransactionDate;
            refundRequest.RelatedPaymentId = refundRequestForm.PaymentId;
            if(refundRequestForm.ClientId != null)
            {
                refundRequest.RelatedClientId = refundRequestForm.ClientId;
            }
            if (refundRequestForm.CourseId != null)
            {
                refundRequest.RelatedCourseId = refundRequestForm.CourseId;
            }

            if (!string.IsNullOrEmpty(refundRequestForm.Notes))
            {
                var note = new Note();
                note.CreatedByUserId = refundRequestForm.CreatedByUserId;
                note.DateCreated = DateTime.Now;
                note.Note1 = refundRequestForm.Notes;

                var refundRequestNote = new RefundRequestNote();
                refundRequestNote.Note = note;

                refundRequest.RefundRequestNotes.Add(refundRequestNote);
            }
            atlasDB.RefundRequests.Add(refundRequest);
            atlasDB.SaveChanges();

            success = true;

            return success;
        }

        class RefundPaymentForm
        {
            public DateTime TransactionDate { get; set; }
            public Decimal Amount { get; set; }
            public int RefundMethodId { get; set; }
            public int RefundTypeId { get; set; }
            public int CreatedByUserId { get; set; }
            public string Reference { get; set; }
            public string PaymentName { get; set; }
            public int OrganisationId { get; set; }
            public int PaymentId { get; set; }
            public string Notes { get; set; }
        }

        class RequestRefundPaymentForm
        {
            public DateTime TransactionDate { get; set; }
            public Decimal Amount { get; set; }
            public int RefundMethodId { get; set; }
            public int RefundTypeId { get; set; }
            public int CreatedByUserId { get; set; }
            public string Reference { get; set; }
            public string PaymentName { get; set; }
            public int OrganisationId { get; set; }
            public int PaymentId { get; set; }
            public int? CourseId { get; set; }
            public int? ClientId { get; set; }
            public string Notes { get; set; }
        }
    }
}