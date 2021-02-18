using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ClientPaymentController : AtlasBaseController
    {
        // GET api/<controller>
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/<controller>/5
        public string Get(int id)
        {
            return "value";
        }

       

       
        [Route("api/ClientPayment/GetPaymentTypes")]
        public List<PaymentTypeView> GetPaymentTypes()
        {

            var paymenttype = from pt in atlasDB.PaymentType
                          select new PaymentTypeView
                          {
                              Id = pt.Id,
                              Name = pt.Name
                          };

            return paymenttype.ToList();
        }

        [Route("api/ClientPayment/GetOrganisationPaymentTypes/{OrganisationId}")]
        [HttpGet]
        public object GetOrganisationPaymentTypes(int OrganisationId)
        {
            return atlasDB.OrganisationPaymentType
                .Include("PaymentType")
                .Where(
                    orgPaymentType =>
                        orgPaymentType.OrganisationId == OrganisationId
                )
                .Select(
                    thePaymentType =>  new
                    {
                        thePaymentType.Id,
                        thePaymentType.PaymentType.Name
                    }
                )
                .ToList();
        }
       
        
        [Route("api/ClientPayment/GetPaymentMethods/{OrganisationId}")]
        [HttpGet]
        public object GetPaymentMethods(int OrganisationId)
        {
            return atlasDB.PaymentMethod
                .Where(
                    paymentMethod =>
                        paymentMethod.OrganisationId == OrganisationId
                )
                .Select(
                    thePayment => new
                    {
                        thePayment.Id,
                        thePayment.Name
                    }
                )
                .ToList();
        }

        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formBody)
        {
            string status = "";
            if (formBody.Count() > 0)
            {

                var formUserId = formBody.Get("UserId");
                var formClientId = formBody.Get("ClientId");
                var formPaymentTypeId = formBody.Get("selectedPaymentType");
                var formTransactionDate = formBody.Get("TransactionDate");
                var formPaymentMethodId = formBody.Get("selectedPaymentMethod");
                var formAmount = formBody.Get("Amount");
                var formAuthCode = formBody.Get("AuthCode");
                var formReceiptNumber = formBody.Get("ReceiptNumber");
                var formPaymentNote = formBody.Get("Note");
                var formPaymentAdditionalId = formBody.Get("selectedAdditionalPaymentMethod");
                var formAdditionalAmount = formBody.Get("AdditionalAmount");

                try
                {
                    if (formClientId != null && formAmount != null && formUserId != null)
                    {


                        int paymentTypeId = 0;
                        int paymentMethodId = 0;
                        int paymentAdditionalId = 0;

                        string authCode = null;
                        string receiptNumber = null;
                        string paymentNote = null;

                        decimal amount = 0;
                        decimal additionalAmount = 0;
                        
                            
                        int userId = Int32.Parse(formUserId.ToString());
                        int clientId = Int32.Parse(formClientId.ToString());
                        paymentTypeId = Int32.Parse(formPaymentTypeId.ToString());
                        DateTime transactionDate = DateTime.Parse(formTransactionDate);
                        paymentMethodId = Int32.Parse(formPaymentMethodId.ToString());
                        amount = Decimal.Parse(formAmount.ToString());
                        if (!string.IsNullOrEmpty(formAuthCode)) { authCode = formAuthCode.ToString(); }
                        if (!string.IsNullOrEmpty(formReceiptNumber)) { receiptNumber = formReceiptNumber.ToString(); }
                        if (!string.IsNullOrEmpty(formPaymentNote)) { paymentNote = formPaymentNote.ToString(); }
                        paymentAdditionalId = Int32.Parse(formPaymentAdditionalId.ToString());
                        additionalAmount = Decimal.Parse(formAdditionalAmount.ToString());

                        Client client = atlasDB.Clients.Where(c => c.Id == clientId).FirstOrDefault();

                        if (client != null)
                        {
                            if (userHasPermission(userId))
                            {
                                Payment payment = new Payment();
                                payment.CreatedByUserId = userId;  // this needs to be checked that the user exists when this functionality is done
                                payment.DateCreated = DateTime.Now;
                                payment.TransactionDate = transactionDate;
                                payment.PaymentTypeId = paymentTypeId;
                                payment.PaymentMethodId = paymentMethodId;

                                payment.Amount = amount;
                                payment.AuthCode = authCode;
                                payment.ReceiptNumber = receiptNumber;

                                ClientPayment clientPayment = new ClientPayment();
                                clientPayment.Client = client;
                                clientPayment.Payment = payment;

                                client.ClientPayments.Add(clientPayment); // should of added to payment and clientpayment tables

                                if (!string.IsNullOrEmpty(paymentNote))
                                {
                                    Note note = new Note();

                                    note.Note1 = paymentNote;
                                    note.DateCreated = DateTime.Now;
                                    note.CreatedByUserId = userId;
                                    note.Removed = false;
                                    note.NoteTypeId = 1; // This needs to be the id of the PaymentNoteType ??

                                    ClientPaymentNote clientPaymentNote = new ClientPaymentNote();
                                    clientPaymentNote.Client = client;
                                    clientPaymentNote.Payment = payment;
                                    clientPaymentNote.Note = note;

                                    client.ClientPaymentNotes.Add(clientPaymentNote);
                                }

                                // Can the additional amount be negative ? maybe
                                if (additionalAmount > 0 )
                                {
                                    
                                    // Creating another payment entry with amount field becoming the additional amount.
                                    Payment linkedPayment = new Payment();
                                    linkedPayment.CreatedByUserId = userId;  // this needs to be checked that the user exists 
                                    linkedPayment.DateCreated = DateTime.Now;
                                    linkedPayment.TransactionDate = transactionDate;

                                    // do these values carry over from before ...
                                    linkedPayment.PaymentTypeId = paymentTypeId;
                                    linkedPayment.AuthCode = authCode;
                                    linkedPayment.ReceiptNumber = receiptNumber;
                                    // do these values carry over from before ...

                                    linkedPayment.PaymentMethodId = paymentAdditionalId; 
                                    linkedPayment.Amount = additionalAmount;

                                    ClientPayment linkedClientPayment = new ClientPayment();
                                    linkedClientPayment.Client = client;
                                    linkedClientPayment.Payment = linkedPayment;

                                    client.ClientPayments.Add(linkedClientPayment); // should of added to payment and clientpayment tables


                                    // Add the first payment to the ClientPaymentLink table
                                    ClientPaymentLink clientPaymentLink = new ClientPaymentLink();
                                    clientPaymentLink.Client = client;
                                    clientPaymentLink.Payment = payment;
                                    clientPaymentLink.LinkDateTime = DateTime.Now;
                                    clientPaymentLink.LinkCode = "CMD"; // where does this come from - ties the paymentlink together

                                    client.ClientPaymentLinks.Add(clientPaymentLink); // should of added to payment and clientpaymentlink tables

                                    // Add the second payment to the ClientPaymentLink table
                                    ClientPaymentLink secondClientPaymentLink = new ClientPaymentLink();
                                    secondClientPaymentLink.Client = client;
                                    secondClientPaymentLink.Payment = linkedPayment;
                                    secondClientPaymentLink.LinkDateTime = DateTime.Now;
                                    secondClientPaymentLink.LinkCode = "CMD"; // where does this come from - ties the paymentlink together

                                    client.ClientPaymentLinks.Add(secondClientPaymentLink); // should of added to payment and clientpaymentlink tables
                                }



                                atlasDB.SaveChanges();
                                status = "success";
                            }
                        }
                    }
                }
                catch (DbEntityValidationException ex)
                {
                    status = "error: data validation error";
                }
            }
            else
            {
                status = "error: JSON not sent.";
            }
            return status;
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }

        private bool userHasPermission(int userId)
        {
            return true;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/AddClientAndCourseToPayment/{ClientId}/{PaymentId}/{CourseId}/{UserId}")]
        /// <summary>
        /// Add a client to a payment.  If a courseId is passed in add the course to the payment as well.
        /// </summary>
        /// <param name="ClientId"></param>
        /// <param name="PaymentId"></param>
        /// <param name="CourseId"></param>
        /// <param name="UserId"></param>
        /// <returns></returns>
        public int AddClientAndCourseToPayment(int ClientId, int PaymentId, int CourseId, int UserId)
        {
            var clientPayment = new ClientPayment();
            clientPayment.ClientId = ClientId;
            clientPayment.PaymentId = PaymentId;
            clientPayment.AddedByUserId = UserId;
            atlasDB.ClientPayment.Add(clientPayment);

            if(CourseId > 0)
            {
                var courseClientPayment = new CourseClientPayment();
                courseClientPayment.ClientId = ClientId;
                courseClientPayment.CourseId = CourseId;
                courseClientPayment.PaymentId = PaymentId;
                courseClientPayment.AddedByUserId = UserId;

                atlasDB.CourseClientPayments.Add(courseClientPayment);
            }
            
            atlasDB.SaveChanges();

            return clientPayment.Id;
        }
    }
}