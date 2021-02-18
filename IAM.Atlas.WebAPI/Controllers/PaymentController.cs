using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Data.Entity;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.Tools;
using Newtonsoft.Json;
using IAM.Atlas.WebAPI.Classes.Payment;
using System.Dynamic;
using IAM.Atlas.WebAPI.Models.Payment;
using System.Web;
using System.Globalization;
using IAM.Atlas.WebAPI.Models;
using System.Data.Entity;
using System.Text;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class PaymentController : AtlasBaseController
    {

        public string authorizationToken { get; set; }

        public string ipAddress { get; set; }

        // Default constructor. this.name will = null after this is run
        public PaymentController()
        {
        }

        // Other constructor. this.name = passed in "name" after this is run
        public PaymentController(string token, string ip)
        {
            //"this.name" specifies that you are referring to the name that belongs to this class
            this.authorizationToken = token;
            this.ipAddress = ip;
        }



        [HttpPost]
        public PaymentFrontendStructure CompleteAuthorization([FromBody] FormDataCollection formBody)
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("PaymentController:CompleteAuthorization", 1, "Started Process");
            //}
            PaymentFrontendStructure paymentFrontendStructure = null;
            var paymentAmount = StringTools.GetDecimal("amount", ref formBody);
            var clientName = StringTools.GetString("clientName", ref formBody);
            var isAssignedTo = StringTools.GetString("isAssignedTo", ref formBody);
            var clientId = StringTools.GetInt("clientId", ref formBody);
            var userId = StringTools.GetInt("userId", ref formBody);
            var courseListCount = ArrayTools.ArrayLength("courses", ref formBody);
            var cardSupplier = StringTools.GetString("cardSupplier", ref formBody);
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Invalid organisation.");
            var paymentChargeType = StringTools.GetString("type", ref formBody);

            var md = StringTools.GetString("md", ref formBody);
            var paRes = StringTools.GetString("paRes", ref formBody);
            var cardType = StringTools.GetString("cardType", ref formBody);
            var paymentOrderReference = StringTools.GetString("orderReference", ref formBody);

            var cardHolderName = StringTools.GetString("paymentName", ref formBody);

            var provider = atlasDB.OrganisationPaymentProviders
                .Include("PaymentProvider")
                .Where(
                    payment => payment.OrganisationId == organisationId
                )
                .Select(
                    providerDetail => new
                    {
                        providerDetail.PaymentProvider.Name,
                        Id = providerDetail.PaymentProviderId
                    }
                )
                .FirstOrDefault();

            // Check
            if (provider == null)
            {
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Unfortunately, we were unable to process your payment. Please contact support.");
            }

            // Get the details for the selected PaymentGateway
            var providerCredentials = GetPaymentProviderCredentials(Convert.ToInt32(provider.Id), organisationId);

            // Decode the 3dResponse parameters
            var updatedMD = HttpUtility.UrlDecode(md);
            var updatedPaRes = HttpUtility.UrlDecode(paRes);

            try
            {
                var processPayment = new ProcessPayment();
                var paymentProcessResult = processPayment.CompleteAuth(
                                                                        provider.Name
                                                                        , updatedMD
                                                                        , updatedPaRes
                                                                        , providerCredentials
                                                                        , cardType
                                                                        , "CompleteAuthorization"
                                                                        , paymentOrderReference
                                                                        );


                // do Stuff based on the Type returned
                var paymentResultType = paymentProcessResult.GetType().Name;

                var otherInf = ".. updatedPaRes: '" + updatedPaRes + "'";

                paymentFrontendStructure = SavePaymentDetails(
                                                                paymentChargeType
                                                                , paymentResultType
                                                                , paymentProcessResult
                                                                , clientId
                                                                , userId
                                                                , paymentAmount
                                                                , courseListCount
                                                                , clientName
                                                                , isAssignedTo
                                                                , cardSupplier
                                                                , cardHolderName
                                                                , provider
                                                                , formBody
                                                                , paymentOrderReference
                                                                , cardType
                                                                , otherInf
                                                            );
            }
            catch(Exception ex)
            {
                LogError("PaymentController CompleteAuthorization", ex);
            }


            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("PaymentController:CompleteAuthorization", 2, "Completed Process");
            //}
            return paymentFrontendStructure;

        }

        [AuthorizationRequired]
        [HttpGet]
        public vwPaymentDetail Get(int Id)
        {
            var payment = atlasDBViews.vwPaymentDetails
                                    .Where(p => p.PaymentId == Id)
                                    .FirstOrDefault();
            return payment;
        }

        // GET api/payment
        [AuthorizationRequired]
        [Route("api/Payment")]
        [HttpPost]
        public PaymentFrontendStructure Post([FromBody] FormDataCollection formBody)
        {
            var theToken = "";
            try
            {
                var token = this.Request.Headers.GetValues("X-Auth-Token").ToList();
                theToken = token[0];
            }
            catch (Exception ex)
            {
                theToken = this.authorizationToken;
            }

            string paymentOrderReference;

            var creationDate = StringTools.GetString("paymentDate", ref formBody);
            var cardToken = StringTools.GetString("token", ref formBody).Remove(0, 5);
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Invalid organisation.");
            var paymentAmount = StringTools.GetDecimal("amount", ref formBody);
            var cardHolderAddress = StringTools.GetString("address", ref formBody);
            var decrypted = "";
            var paymentChargeType = StringTools.GetString("type", ref formBody);
            var clientName = StringTools.GetString("clientName", ref formBody);
            var isAssignedTo = StringTools.GetString("isAssignedTo", ref formBody);
            var clientId = StringTools.GetInt("clientId", ref formBody);
            var courseListCount = ArrayTools.ArrayLength("courses", ref formBody);
            var cardSupplier = StringTools.GetString("cardSupplier", ref formBody);
            var courseId = StringTools.GetInt("courses[0][CourseId]", ref formBody);

            clientName = RemoveIllegalCharacters(clientName);
            cardHolderAddress = RemoveIllegalCharacters(cardHolderAddress);

            var emptyAddress = "{}";


            // get user id from token
            LoginSession theUser =
                atlasDB.LoginSessions.Where(
                    session => session.AuthToken == theToken
                )
                .FirstOrDefault();

            // Check the user isn't null
            if (theUser == null)
            {
                Error.FrontendHandler(HttpStatusCode.Forbidden, "Please log back in to restart the process.");
            }

            // Re Create Public Key
            var publicKey = theToken + "_" + creationDate + "_" + theUser.UserId;

            try
            {
                // Decrypt the card details
                decrypted = StringCipher.OpenSSLDecrypt(cardToken, publicKey);
            }
            catch
            {

                Error.FrontendHandler(HttpStatusCode.BadRequest, "Your request is not valid");
            }

            // Convert into an object
            var cardDetails = JsonConvert.DeserializeObject<Card>(decrypted);

            //We seem to be getting Problems When the Address is entered on occasion, so for now we will not send the Address
            cardHolderAddress = emptyAddress;

            // Convert into object
            var addressDetails = JsonConvert.DeserializeObject<CardHolderAddress>(cardHolderAddress);

            // get the payment provider
            var provider = atlasDB.OrganisationPaymentProviders
                .Include("PaymentProvider")
                .Where(
                    payment => payment.OrganisationId == organisationId
                )
                .Select(
                    providerDetail => new
                    {
                        providerDetail.PaymentProvider.Name,
                        Id = providerDetail.PaymentProviderId
                    }
                )
                .FirstOrDefault();

            // Check that
            if (provider == null)
            {
                Error.FrontendHandler(HttpStatusCode.InternalServerError, "Unfortunately, we are unable to process your payment. Please contact support.");
            }

            // Get the details for the selected PaymentGateway
            var providerCredentials = GetPaymentProviderCredentials(Convert.ToInt32(provider.Id), organisationId);

            // Process the payment for the selected PaymentGateway
            // Specify which Method to use
            var clientIP = "";
            try
            {
                clientIP = GetIPAddress();
            }
            catch (Exception ex)
            {
                clientIP = this.ipAddress;
            }

            paymentOrderReference = GeneratePaymentOrderReference(clientId, courseId, organisationId);

            string validationMessage = ValidateData(cardDetails, addressDetails);

            var paymentDetails = new PaymentFrontendStructure();
            if (string.IsNullOrEmpty(validationMessage) == false)
            {
                throw new Exception(validationMessage); // so fall back into angular controller errorCallback: apparently the way to go
            }
            else
            {
                try
                {
                    var processPayment = new ProcessPayment();
                    var paymentProcessResult = processPayment.Start(provider.Name, cardDetails, addressDetails, paymentAmount, paymentChargeType, providerCredentials, "ChargeCard", clientIP, paymentOrderReference);

                    // do Stuff based on the Type returned
                    var paymentResultType = paymentProcessResult.GetType().Name;

                    if (paymentResultType == "PaymentError" && paymentChargeType == "telephone")
                    {
                        //Retry if Payment Error
                        var cardHolderNameBackup = cardDetails.HolderName;
                        cardDetails.HolderName = ""; //Payments Reject because of Name Error. Payment Names aren't always needed. In the Old Atlas System they were excluded.
                        paymentProcessResult = processPayment.Start(provider.Name
                                                                    , cardDetails
                                                                    , addressDetails
                                                                    , paymentAmount
                                                                    , paymentChargeType
                                                                    , providerCredentials
                                                                    , "ChargeCard"
                                                                    , clientIP
                                                                    , paymentOrderReference
                                                                    );
                        paymentResultType = paymentProcessResult.GetType().Name;
                        cardDetails.HolderName = cardHolderNameBackup;
                    }

                    var otherInf = ".. ClientIP: " + clientIP;
                    otherInf = otherInf + " .... Card Length: " + cardDetails.Number.Length.ToString();
                    otherInf = otherInf + " .... CV2 Length: " + cardDetails.CV2.Length.ToString();

                    // call the savePaymentDetails function to record this payment into the database.
                    paymentDetails = SavePaymentDetails(
                                                        paymentChargeType
                                                        , paymentResultType
                                                        , paymentProcessResult
                                                        , clientId
                                                        , theUser.UserId
                                                        , paymentAmount
                                                        , courseListCount
                                                        , clientName
                                                        , isAssignedTo
                                                        , cardSupplier
                                                        , cardDetails.HolderName
                                                        , provider
                                                        , formBody
                                                        , paymentOrderReference
                                                        , cardDetails.Type
                                                        , otherInf
                                                    );
                }
                catch (Exception ex)
                {
                    LogError("PaymentController Post", ex);
                    throw ex;
                }
            }
            return paymentDetails;
        }


        // Build what is needed from this user story
        private PaymentFrontendStructure SavePaymentDetails (
                                                            string paymentChargeType
                                                            , string PaymentResultType
                                                            , object PaymentProcessResult
                                                            , int ClientId
                                                            , int UserId
                                                            , decimal Amount
                                                            , int CourseListCount
                                                            , string ClientName
                                                            , string AssignedTo
                                                            , string CardSupplier
                                                            , string CardHolderName
                                                            , object Provider
                                                            , FormDataCollection formBody
                                                            , string paymentOrderReference
                                                            , string cardType = ""
                                                            , string otherInformation = ""
                                                            )
        {
            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("PaymentController:SavePaymentDetails", 1, "Started Process");
            //}
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Invalid organisation.");
            var cardHolderAddress = StringTools.GetString("address", ref formBody);
            var FirstCourseIdData = StringTools.GetInt("courses[0][CourseId]", ref formBody);
            int? FirstCourseId = null;
            if (FirstCourseIdData > 0) { FirstCourseId = FirstCourseIdData; }

            var paymentData = new PaymentFrontendStructure();
            dynamic paymentResult = PaymentProcessResult;
            dynamic provider = Provider;

            // build method

            // If doing a 3d secure request
            // Then build front end object
            if (PaymentResultType == "PaymentAuthorization")
            {
                paymentData.AcsUrl = paymentResult.AcsUrl;
                paymentData.MD = paymentResult.MD;
                paymentData.PaReq = paymentResult.PaReq;
                paymentData.TermUrl = paymentResult.TermUrl;
                paymentData.TransactionReference = paymentResult.ParentTransactionReference;
                paymentData.Is3DSecureRequest = true;
                paymentData.OrderReference = paymentOrderReference;
                paymentData.PaymentName = CardHolderName;
                paymentData.ClientName = ClientName;

            }
            else if (PaymentResultType == "PaymentSuccess")
            {
                // Build the payment save data
                try
                {
                    // Get the payment Card Type early as needed to retrieve PayemntMethod and PaymentType for online payments
                    string processedCardType = paymentResult.CardType;
                    var theProcessedCardType = atlasDB.PaymentCardTypes
                        .Where(paymentCardTypes => paymentCardTypes.Name == processedCardType)
                        .Select(actualCardType => new
                        {
                            actualCardType.Id
    
                        })
                        .FirstOrDefault();

                    var paymentMethodAndType = new vwOrganisationPaymentCardTypeToPaymentMethodAndTypeLink();
                    if (string.IsNullOrEmpty(paymentChargeType) == false &&  paymentChargeType.ToLower() == "online")
                    {
                        paymentMethodAndType = atlasDBViews.vwOrganisationPaymentCardTypeToPaymentMethodAndTypeLinks
                            .Where(x => x.OrganisationId == organisationId
                                && x.PaymentCardTypeId == theProcessedCardType.Id
                                && x.PaymentTypeName == "Full") //always full payment online
                            .FirstOrDefault();
                    }

                    // Main Payment 
                    var payment = new Payment();

                    payment.DateCreated = DateTime.Now;
                    payment.TransactionDate = paymentResult.TransactionDate;
                    payment.Amount = Amount;
                    payment.PaymentTypeId = paymentMethodAndType.PaymentTypeId;
                    payment.PaymentMethodId = paymentMethodAndType.PaymentMethodId;
                    payment.ReceiptNumber = paymentResult.TransactionReference;
                    payment.AuthCode = paymentResult.AuthCode;
                    payment.CreatedByUserId = UserId;
                    payment.UpdatedByUserId = UserId;
                    payment.PaymentName = (String.IsNullOrEmpty(CardHolderName)) ? ClientName : CardHolderName;

                    payment.Reference = paymentOrderReference;

                    // Add the payment to the payment table
                    atlasDB.Payment.Add(payment);

                    atlasDB.SaveChanges();

                    try
                    {
                        if (ClientId != 0 && (AssignedTo == "client" || AssignedTo == "clientCourse"))
                        {
                            var clientPayment = new ClientPayment();
                            clientPayment.ClientId = ClientId;
                            clientPayment.Payment = payment;
                            clientPayment.AddedByUserId = UserId;

                            // Add the payment to the client payment table
                            atlasDB.ClientPayment.Add(clientPayment);

                            atlasDB.SaveChanges();
                        }
                    } catch (Exception ex)
                    {
                        //For Some Reason This Fails to save Every Now and then.
                        //Missing Data Will be Entered Later
                    }


                    // If a course has been assigned to a client
                    if (CourseListCount != 0 && AssignedTo == "clientCourse")
                    {
                        for (int i = 0; i < CourseListCount; i++)
                        {
                            var courseId = StringTools.GetIntOrFail("courses[" + i + "][CourseId]", ref formBody, "Invalid Course Id");
                            var courseClientPayment = new CourseClientPayment();
                            courseClientPayment.ClientId = ClientId;
                            courseClientPayment.Payment = payment;
                            courseClientPayment.CourseId = courseId;
                            courseClientPayment.AddedByUserId = UserId;

                            // Add to the CourseClientPayment table
                            atlasDB.CourseClientPayments.Add(courseClientPayment);
                        }
                        atlasDB.SaveChanges();
                    }

                    try { 
                        // Log the payment card
                        var paymentCard = new PaymentCard();
                        paymentCard.Payment = payment;
                        paymentCard.PaymentProviderId = provider.Id;
                        paymentCard.PaymentProviderTransactionReference = paymentResult.TransactionReference;
                        paymentCard.DateCreated = DateTime.Now;
                        paymentCard.TransactionDate = paymentResult.TransactionDate;
                        paymentCard.CreatedByUserId = UserId;
                        paymentCard.PaymentCardTypeId = theProcessedCardType.Id; // Add Correct Id

                        // If the card supplier field has been filled out
                        if (!string.IsNullOrEmpty(CardSupplier))
                        {
                            var doesCardSupplierExist = atlasDB.PaymentCardSuppliers.Where(
                                theCardSupplier =>
                                    theCardSupplier.Name == CardSupplier
                            ).FirstOrDefault();

                            if (doesCardSupplierExist != null)
                            {
                                // then use card supplied id
                                paymentCard.PaymentCardSupplier = doesCardSupplierExist;
                            }

                            if (doesCardSupplierExist == null)
                            {
                                // create a new object then add to the id
                                var thePaymentCardSupplier = new PaymentCardSupplier();
                                thePaymentCardSupplier.Name = CardSupplier;
                                atlasDB.PaymentCardSuppliers.Add(thePaymentCardSupplier);

                                atlasDB.SaveChanges();

                                paymentCard.PaymentCardSupplier = thePaymentCardSupplier;
                            }
                        }

                        //aDD the payment card to the DB
                        atlasDB.PaymentCards.Add(paymentCard);

                        atlasDB.SaveChanges();

                    }
                    catch (Exception ex)
                    {
                        //For Some Reason This Fails to save Every Now and then.
                        //Any Data Missing in this Try/Catch is not essential.
                    }

                    paymentData.Is3DSecureRequest = false;
                    paymentData.PaymentId = payment.Id;
                    paymentData.TransactionReference = payment.ReceiptNumber;
                    paymentData.AuthCode = payment.AuthCode;
                    paymentData.Amount = payment.Amount;
                }
                catch (Exception ex)
                {
                    LogError("PaymentController SavePaymentDetails", ex);
                    SavePaymentErrorInformation(organisationId
                                                , UserId
                                                , ClientId
                                                , FirstCourseId
                                                , Amount
                                                , ClientName
                                                , Provider.ToString()
                                                , "Payment Error: " + paymentResult.Message, cardHolderAddress.ToString()
                                                );
                    Error.FrontendHandler(
                        HttpStatusCode.ServiceUnavailable, 
                        "There was error with our service, this has been logged. Please retry. If the problem persists! Contact Administration!"
                    );
                }
            }
            else if (PaymentResultType == "PaymentError")   // @TODO: remove the frontendhandler and just throw a new exception (with new error messages).
            {
                SavePaymentErrorInformation(organisationId
                                            , UserId
                                            , ClientId
                                            , FirstCourseId
                                            , Amount
                                            , ClientName
                                            , Provider.ToString()
                                            , "Payment Error: " + paymentResult.Message
                                            , "Address Input: " + cardHolderAddress.ToString()
                                                + " ..... Payment Type: " + cardType
                                                + " ..... Payment Charge Type: " + paymentChargeType
                                                + " ...... " + otherInformation
                                            );
                string ErrorDetail = "" + paymentResult.Message;
                switch (ErrorDetail)
                {
                    case "Invalid field":
                        ErrorDetail = "Secure Trading Says that one of the fields entered is incorrect.";
                        break;
                    case "No account found":
                        ErrorDetail = "We are sorry but it appears we do not support this Payment Card Type.";
                        break;
                    case "Decline":
                        ErrorDetail = "This Payment card has been Declined.";
                        break;
                    default:
                        ErrorDetail = "Message From Secure Trading: " + ErrorDetail;
                        break;
                }
                Error.FrontendHandler(HttpStatusCode.BadRequest
                                        , "Your payment was unsuccessful and you have not been charged."
                                            + "\n" + ErrorDetail
                                            + "\nPlease check the payment details entered and try again."
                                        );
            }
            else if (PaymentResultType == "String")
            {
                SavePaymentErrorInformation(organisationId
                                            , UserId
                                            , ClientId
                                            , FirstCourseId
                                            , Amount
                                            , ClientName
                                            , Provider.ToString()
                                            , "Payment Error: " + paymentResult.Message
                                            , "Address Input: " + cardHolderAddress.ToString()
                                                + " ..... Payment Type: " + cardType
                                                + " ..... Payment Charge Type: " + paymentChargeType
                                                + " ...... " + otherInformation
                                            );
                Error.FrontendHandler(HttpStatusCode.BadRequest
                                        , "Your payment was unsuccessful and you have not been charged."
                                            + "\nPlease check the payment details entered and try again."
                                        );
            }
            else
            {
                SavePaymentErrorInformation(organisationId
                                            , UserId
                                            , ClientId
                                            , FirstCourseId
                                            , Amount
                                            , ClientName
                                            , Provider.ToString()
                                            , "Payment Error: " + paymentResult.Message
                                            , "Address Input: " + cardHolderAddress.ToString()
                                                + " ..... Payment Type: " + cardType
                                                + " ..... Payment Charge Type: " + paymentChargeType
                                                + " ...... " + otherInformation
                                            );
                Error.FrontendHandler(HttpStatusCode.BadRequest
                                        , "Your payment was unsuccessful and you have not been charged."
                                            + "\nPlease check the payment details entered and try again."
                                        );
            }

            //if (GlobalVariables.SaveProcessesForMonitoring == true)
            //{
            //    SaveToProcessMonitor("PaymentController:SavePaymentDetails", 1, "Completed Process");
            //}
            return paymentData;

        }

        private void SavePaymentErrorInformation(int? orgId = null
                                                , int? eventUserId = null
                                                , int? clientId = null
                                                , int? courseId = null
                                                , decimal? paymentAmount = null
                                                , string paymentName = ""
                                                , string paymentProvider = ""
                                                , string paymentProviderResponseInf = ""
                                                , string otherInf = ""
                                                )
        {
            var payErrInf = new PaymentErrorInformation();
            try
            {
                //Try and Save Payment Error Information if you can
                if (clientId <= 0) { clientId = null; }
                
                atlasDB.uspSavePaymentErrorInformation(orgId, eventUserId, clientId, courseId, paymentAmount, paymentName, paymentProvider, paymentProviderResponseInf, otherInf);

            } catch(Exception ex)
            {
                var err = ex;
                LogError("SavePaymentErrorInformation", ex);
            }

        }

        private string RemoveIllegalCharacters(string inputString)
        {
            string output = new string(inputString.Where(c => !char.IsControl(c)).ToArray()); //Strip Out Control Characters
            //output = new string(output.Where(c => char.IsLetter(c) || char.IsDigit(c)).ToArray()); //Strip Out Non Alpha Numeric Characters
            output = output.Trim();
            return output;
        }

        /// <summary>
        /// Get a list of the credentials needed for the payment provider
        /// </summary>
        /// <param name="PaymentProviderId"></param>
        /// <returns></returns>
        private object GetPaymentProviderCredentials(int PaymentProviderId, int organisationId)
        {

            var paymentProviderCredentials =
                atlasDB.OrganisationPaymentProviderCredentials
                .Where(
                    credentials =>
                        credentials.PaymentProviderId == PaymentProviderId &&
                        credentials.OrganisationId == organisationId
                )
                .Select(
                    providerCredentials => new
                    {
                        Key = providerCredentials.Key,
                        Value = providerCredentials.Value
                    }
                )
                .ToList();


            // Create New Expando Object
            dynamic paymentProviderKeys = new ExpandoObject();
            var paymentProviderObject = paymentProviderKeys as IDictionary<String, object>;

            // Loop through the keys
            foreach (var theKey in paymentProviderCredentials)
            {
                paymentProviderObject[theKey.Key] = theKey.Value;
            }

            return paymentProviderKeys;

        }

        private string GeneratePaymentOrderReference(int clientId, int courseId, int GeneratePaymentOrderReference)
        {
            string generatedOrderReference = "";
            PaymentOrderReference orderReference = new PaymentOrderReference();
            if (courseId > 0)
            {
                //orderReference = (
                //     from course in atlasDB.Course
                //     join courseVenue in atlasDB.CourseVenue on course.Id equals courseVenue.CourseId
                //     join venueRegion in atlasDB.VenueRegions on courseVenue.VenueId equals venueRegion.VenueId
                //     join region in atlasDB.Region on venueRegion.RegionId equals region.Id
                //     where course.Id == courseId
                //     select new PaymentOrderReference
                //     {
                //         CourseReference = course.Reference,
                //         Region = region.Name
                //     }
                // ).FirstOrDefault();
                orderReference = atlasDB.Course
                                    .Include(c => c.CourseVenue)
                                    .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                                    .Include(c => c.CourseVenue.Select(cv => cv.Venue))
                                    .Where(c => c.Id == courseId)
                                    .Select(c => new PaymentOrderReference {
                                        CourseReference = c.Reference,
                                        Region = (c.CourseVenue.FirstOrDefault() == null ? "" : (c.CourseVenue.FirstOrDefault().Venue.VenueRegions.Count() > 0 ? c.CourseVenue.FirstOrDefault().Venue.VenueRegions.FirstOrDefault().Region.Name : "")),
                                        ClientId = clientId
                                    })
                                    .FirstOrDefault();
            }

            //if (orderReference != null && clientId > 0)
            //{
            //    orderReference.ClientId = clientId;
            //}
            if(orderReference != null)
            {
                generatedOrderReference = orderReference.GeneratedOrderReference;
            }
            return generatedOrderReference;
        }

        private string ValidateData(Card cardDetails, CardHolderAddress addressDetails)
        {
            var validationMessage = string.Empty;
            if (cardDetails == null)
            {
                ConcatenateValidationMessage(ref validationMessage, "Please enter card details.");
            }
            else
            {
                if (cardDetails.HolderName == null)
                {
                    ConcatenateValidationMessage(ref validationMessage, "Please enter a card holder name.");
                }

                if (cardDetails.Number == null)
                {
                    ConcatenateValidationMessage(ref validationMessage, "Please enter a card number.");
                }

                if (cardDetails.Type == null)
                {
                    ConcatenateValidationMessage(ref validationMessage, "Please Select a card type.");
                }

                if (cardDetails.Expiry == null)
                {
                    ConcatenateValidationMessage(ref validationMessage, "Please enter a card expiry month and year.");
                }
                else
                {
                    if (cardDetails.Expiry.Month == null)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a card expiry month.");
                    }
                    else if (IsValidMonth(cardDetails.Expiry.Month) == false)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a valid card expiry month.");
                    }

                    if (cardDetails.Expiry.Year == null)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a card expiry year.");
                    }
                    else if (IsValidYear(cardDetails.Expiry.Year) == false)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a valid card expiry year.");
                    }
                }

                if (cardDetails.Start != null)
                { 
                    if (cardDetails.Start.Month == null)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a card start month.");
                    }
                    else if (IsValidMonth(cardDetails.Start.Month) == false)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a valid card start month.");
                    }

                    if (cardDetails.Start.Year == null)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a card start year.");
                    }
                    else if (IsValidYear(cardDetails.Start.Year) == false)
                    {
                        ConcatenateValidationMessage(ref validationMessage, "Please enter a valid card start year.");
                    }
                }
            }

            return validationMessage;
        }

        private void ConcatenateValidationMessage(ref string validationMessage, string newMessage)
        {
            validationMessage += validationMessage != "" ? "\n" : "";
            validationMessage += newMessage;
        }

        private bool IsValidMonth(string month)
        {
            var isValid = false;

            try
            {
                var ret = DateTime.ParseExact(month, "MM", CultureInfo.CurrentCulture).Month;
                isValid = true;
            }
            catch
            {
                isValid = false;
            }
            return isValid;
        }

        private bool IsValidYear(string year)
        {
            var isValid = false;

            try
            {
                var ret = DateTime.ParseExact(year, "yyyy", CultureInfo.CurrentCulture).Year;
                isValid = true;
            }
            catch
            {
                isValid = false;
            }
            return isValid;
        }

    }
}