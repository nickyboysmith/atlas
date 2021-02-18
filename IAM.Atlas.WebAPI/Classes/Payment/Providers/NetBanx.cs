using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.WebAPI.Models.Payment;
using IAM.Atlas.Tools;
using RestSharp;
using RestSharp.Authenticators;
using RestSharp.Deserializers;
using RestSharp.Serializers;
using System.Web.Script.Serialization;
using System.Net;
using System.Web;

namespace IAM.Atlas.WebAPI.Classes.Payment.Providers
{
    public class NetBanx : PaymentProviderInterface
    {

        private string chargeUrl = System.Configuration.ConfigurationManager.AppSettings["netBanxChargeURL"].ToString();
        private string threeDSecureUrl = System.Configuration.ConfigurationManager.AppSettings["netBanxThreeDSecureURL"].ToString();
        private string threeDSecureDetails = System.Configuration.ConfigurationManager.AppSettings["netBanxThreeDSecureDetailsURL"].ToString();

        public object ChargeCard(Card Card, CardHolderAddress Address, decimal Amount, string ChargeType, object ProviderCredentials, string ClientIP, string paymentOrderReference)
        {

            var credentials = ProviderCredentials as IDictionary<string, object>;
            var accountNumber = credentials["accountNumber"].ToString();
            var apiKey = credentials["apiKey"].ToString();

            // Create the transaction time
            var theParsedDate = DateTime.Now;

            // Encode the Username & PW for basic auth
            var AuthorizationHeader = "Basic " + StringCipher.Base64Encode(apiKey);

            // Build the request
            var paymentRequest = CreatePaymentRequest(
                AuthorizationHeader,
                Card,
                Address,
                accountNumber,
                Amount,
                ChargeType,
                theParsedDate,
                ProviderCredentials,
                ClientIP,
                paymentOrderReference
            );

            return HandlePaymentRequest(
                paymentRequest, 
                ChargeType, 
                theParsedDate,
                Amount,
                AuthorizationHeader, 
                Card, 
                Address, 
                accountNumber, 
                ProviderCredentials,
                paymentOrderReference
            );

        }

        public object CompleteAuthorization(object ProviderCredentials, string MD, string PaRes, string CardType, string paymentOrderReference)
        {

            var credentials = ProviderCredentials as IDictionary<string, object>;
            var accountNumber = credentials["accountNumber"].ToString();
            var apiKey = credentials["apiKey"].ToString();

            // Create the transaction time
            var theParsedDate = DateTime.Now;

            // Encode the Username & PW for basic auth
            var AuthorizationHeader = "Basic " + StringCipher.Base64Encode(apiKey);

            // Split merchant data to get merchantRefNum
            var decodedMD = HttpUtility.HtmlDecode(MD);
            var merchantData = decodedMD.Split('|');
            var merchantRefNum = merchantData[0];
            var enrollmentId = merchantData[1];
            var cardToken = merchantData[2];
            var cardAddressToken = merchantData[3];

            var publicKey = merchantRefNum + "_" + accountNumber;

            // Decrypt the card token
            var decryptedCardDetails = StringCipher.OpenSSLDecrypt(cardToken, publicKey);

            // Decrypt the card Address token
            var decryptedCardAddressDetails = StringCipher.OpenSSLDecrypt(cardAddressToken, publicKey);

            // Serialize Card Details
            JavaScriptSerializer serializer = new JavaScriptSerializer();

            // Create Card object
            var cardObject = serializer.Deserialize<NetBanxEnrollment>(decryptedCardDetails);

            // Create Card Address object
            var cardAddressObject = serializer.Deserialize<CardHolderAddress>(decryptedCardAddressDetails);

            // Process the request
            // To get the 3D Secure Data
            var authentication = Create3DSecurePaymentAuth(
                AuthorizationHeader, 
                accountNumber, 
                merchantRefNum, 
                enrollmentId, 
                PaRes
            );

            // Handle the auth response
            // to get the params to pass to the card payment object
            var handlePaymentResponse = Handle3dSecureAuthRequest(authentication);

            // If there has been an error
            // Return that tot he frontend
            if (handlePaymentResponse.GetType().Name == "PaymentError") {
                return handlePaymentResponse;
            }

            // NetBanx 3d Auth
            var netBanx3DAuthDetails = (NetBanx3DAuth) handlePaymentResponse;

            // Process the payment withthe 3d request
            var processPayment = Create3dSecurePaymentRequest(
                netBanx3DAuthDetails,
                AuthorizationHeader,
                accountNumber,
                merchantRefNum,
                enrollmentId,
                cardObject,
                cardAddressObject
            );

            var theCard = new Card();

            return HandlePaymentRequest(
                processPayment,
                "telephone",
                theParsedDate,
                cardObject.amount,
                AuthorizationHeader,
                theCard,
                cardAddressObject,
                accountNumber,
                ProviderCredentials,
                paymentOrderReference
            );
        }

        public object ErrorHandler(string ErrorMessage)
        {
            return ErrorMessage;
        }

        private IRestResponse Get3DAuthenticationDetails (string AuthorizationHeader, string AccountNumber, string Id)
        {
            var endPoint = SelectEndpoint("auth", AccountNumber) + "/" + Id + "?fields=enrollmentchecks";

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.GET;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(endPoint);

            // Set the content type
            restRequest.JsonSerializer.ContentType = "application/json";

            // Set Authorization header
            restRequest.AddHeader("Authorization", AuthorizationHeader);

            return client.Execute(restRequest);

        }

        private IRestResponse Create3dSecurePaymentRequest(
            NetBanx3DAuth AuthorizationObject,
            string AuthorizationHeader,
            string AccountNumber,
            string MerchantRef,
            string EnrollmentId,
            NetBanxEnrollment OriginalCard,
            CardHolderAddress Address
        )
        {

            var endPoint = SelectEndpoint("telephone", AccountNumber);

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(endPoint);


            // Set the content type
            restRequest.JsonSerializer.ContentType = "application/json";

            // Set Authorization header
            restRequest.AddHeader("Authorization", AuthorizationHeader);

            // Buld card object
            var netBanxCardDetails = new
            {
                cardNum = OriginalCard.card.cardNum,
                cardExpiry = OriginalCard.card.cardExpiry,
                cvv = OriginalCard.card.cvv
            };


            // Create the threeDSecurePaymentRequest 
            var threeDSecurePaymentRequest = new
            {
                settleWithAuth = true,
                merchantRefNum = MerchantRef,
                authentication = new
                {
                    eci = AuthorizationObject.eci,
                    cavv = AuthorizationObject.cavv,
                    xid = AuthorizationObject.xid,
                    signatureStatus = AuthorizationObject.signatureStatus,
                    threeDResult = AuthorizationObject.threeDResult,
                    threeDEnrollment = "Y"
                },
                amount = OriginalCard.amount,
                card = netBanxCardDetails,
                billingDetails = new
                {
                    street = Address.StreetAddress,
                    zip = Address.PostCode
                }
            };

            // Add the json body
            restRequest.AddJsonBody(threeDSecurePaymentRequest);

            return client.Execute(restRequest);
        }

        private IRestResponse Create3DSecurePaymentAuth(
            string AuthorizationHeader,
            string AccountNumber,
            string MerchantRefNum,
            string EnrollmentId,
            string PaRes
        )
        {
            var endPoint = SelectEndpoint("online", AccountNumber) + "/" + EnrollmentId + "/authentications";

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(endPoint);

            // Set the content type
            restRequest.JsonSerializer.ContentType = "application/json";

            // Set Authorization header
            restRequest.AddHeader("Authorization", AuthorizationHeader);


            var netBanxAuthRequest = new
            {
                merchantRefNum = MerchantRefNum,
                paRes = PaRes
            };

            restRequest.AddJsonBody(netBanxAuthRequest);

            return client.Execute(restRequest);

        }

        // 
        private IRestResponse CreatePaymentRequest(
            string AuthorizationHeader,
            Card Card,
            CardHolderAddress Address,
            string AccountNumber,
            decimal Amount,
            string ChargeType,
            DateTime TransactionDate,
            object ProviderCredentials,
            string ClientIP,
            string paymentOrderReference)
        {

            var endPoint = SelectEndpoint(ChargeType, AccountNumber);

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(endPoint);

            // Set the content type
            restRequest.JsonSerializer.ContentType = "application/json";

            // Set Authorization header
            restRequest.AddHeader("Authorization", AuthorizationHeader);

            var nameSplit = Card.HolderName.Split(null);
            var nameCount = nameSplit.Count();
            var firstName = nameSplit[0];
            var lastName = nameSplit[(nameCount - 1)];

            // var NetBanx Card object
            var netBanxCardDetails = new
            {
                cardNum = Card.Number,
                cardExpiry = new
                {
                    month = Card.Expiry.Month,
                    year = Card.Expiry.Year
                },
                cvv = Card.CV2
            };

            // If it is the NetBanx Telephone request
            if (ChargeType == "telephone")
            {
                // tel
                // Create empty NetBanx Request
                var netBanxMotoRequest = new
                {
                    settleWithAuth = true,
                    amount = Convert.ToInt32(Amount * 100),
                    merchantRefNum = paymentOrderReference,
                    card = netBanxCardDetails,
                    billingDetails = new
                    {
                        street = Address.StreetAddress,
                        zip = Address.PostCode
                    }
                };
                restRequest.AddJsonBody(netBanxMotoRequest);
            } else {
                // online
                // Create the 3d secure request
                var userAgent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36";
                var accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
                var merchantUrl = System.Configuration.ConfigurationManager.AppSettings["netBanxMerchantURL"].ToString();

                var netBanxThreeDSecureRequest = new
                {
                    merchantRefNum = paymentOrderReference,
                    amount = Convert.ToInt32(Amount * 100),
                    currency = "GBP",
                    customerIp = ClientIP == "::1" ? "127.0.0.1" : ClientIP, //TODO:- Fix properly (no time now) ::1 returned if local host so need to set as 127.0.0.1
                    userAgent = userAgent,
                    acceptHeader = accept,
                    merchantUrl = merchantUrl,
                    card = netBanxCardDetails
                };

                restRequest.AddJsonBody(netBanxThreeDSecureRequest);
            }

            return client.Execute(restRequest);
        }

        // Send the correct endpoint 
        // Based on which type of request is being processed
        private string SelectEndpoint(string EndpointToUse, string AccountNumber)
        {
            var endpoint = this.chargeUrl;

            // Check what the charge type is
            if (EndpointToUse == "online") {
                endpoint = this.threeDSecureUrl;
            }

            if (EndpointToUse == "auth") {
                endpoint = this.threeDSecureDetails;
            }

            // replace placeholder
            endpoint = endpoint.Replace("[account_number]", AccountNumber);

            return endpoint;
        }

       private object Handle3DAuthenticationDetails(IRestResponse ThreeDAuthRequestDetails)
       {
            JsonDeserializer deserial = new JsonDeserializer();
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            dynamic JSONObj = deserial.Deserialize<Dictionary<string, string>>(ThreeDAuthRequestDetails);

            // Make errors global
            // As they wont always exist
            var requestErrors = new NetBanxErrors();
            var errorObject = "";

            // Check that the error objetc exists
            if (JSONObj.TryGetValue("error", out errorObject)) {
                requestErrors = serializer.Deserialize<NetBanxErrors>(errorObject);
            }

            // Check to see if the rest request 
            // Was processed with out an error
            if (ThreeDAuthRequestDetails.StatusCode == HttpStatusCode.OK) {
                return serializer.Deserialize<NetBanx3DAuth>(ThreeDAuthRequestDetails.Content);
            } else {
                // Catch anything that isnt a 200 Response
                var error = new PaymentError();
                error.Message = requestErrors.message;
                return error;
            }

       }
        

        private object HandlePaymentRequest(
            IRestResponse PaymentRequest, 
            string ChargeType, 
            DateTime TransactionDate,
            decimal Amount,
            string AuthorizationHeader, 
            Card Card, 
            CardHolderAddress Address, 
            string accountNumber, 
            object ProviderCredentials,
            string paymentOrderReference
        )
        {
            JsonDeserializer deserial = new JsonDeserializer();
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            dynamic JSONObj = deserial.Deserialize<Dictionary<string, string>>(PaymentRequest);

            // Make card object global
            var card = new NetBanxCard();
            var cardObject = "";

            // Check that the card object exists
            if (JSONObj.TryGetValue("card", out cardObject)) {
                card = serializer.Deserialize<NetBanxCard>(cardObject);
            }

            // Make errors global
            // As they wont always exist
            var requestErrors = new NetBanxErrors();
            var errorObject = "";

            // Check that the error objetc exists
            if (JSONObj.TryGetValue("error", out errorObject)) {
                requestErrors = serializer.Deserialize<NetBanxErrors>(errorObject);
            }
            
            // Check to see if the rest request 
            // Was processed with out an error
            if (PaymentRequest.StatusCode == HttpStatusCode.OK) {

                // Check to see what type of request this is
                if (ChargeType == "telephone") {

                    var paymentStatus = JSONObj["status"];
                    var completedPayment = Convert.ToBoolean(JSONObj["settleWithAuth"]);
                    
                    // @important
                    // Imperative completedPayment variable is checked for
                    // As the if completedPayment == false [payment hasnt been taken, card has only been authorised]
                    if (paymentStatus == "COMPLETED" && completedPayment == true)
                    {
                        var success = new PaymentSuccess();
                        success.CardType = NetBanxCardTypeConversion(card.type); // Add the card type
                        success.TransactionDate = TransactionDate;
                        success.AuthCode = JSONObj["authCode"];
                        success.TransactionReference = JSONObj["id"];
                        return success;
                    } else {
                        // If the settle with auth is false
                        var error = new PaymentError();
                        error.Message = "You card wasn't charged. If this issue persists please contact support!";
                        return error;
                    }

                } else {

                    // 3D Request response
                    if (JSONObj["threeDEnrollment"] == "Y")
                    {
                        // Build object to send serialize
                        var storedCardDetails = new NetBanxEnrollment();
                        var cardDetails = new NetBanxCard();

                        // BUild the card details
                        cardDetails.cardNum = Card.Number;
                        cardDetails.cardExpiry = card.cardExpiry;
                        cardDetails.cvv = Card.CV2;

                        // Add to enrollment Object
                        storedCardDetails.amount = Convert.ToInt32(Amount * 100);
                        storedCardDetails.card = cardDetails;

                        // Serialize the card details
                        var serializedCardDetails = serializer.Serialize(storedCardDetails);

                        // Serialize the card address details
                        var serializedCardAddressDetails = serializer.Serialize(Address);

                        // Create Public Key
                        var publicKey = JSONObj["merchantRefNum"] + "_" + accountNumber;

                        // Create a card Token
                        var cardToken = StringCipher.OpenSSLEncrypt(serializedCardDetails, publicKey);

                        // Create a card Token
                        var cardAddressToken = StringCipher.OpenSSLEncrypt(serializedCardAddressDetails, publicKey);

                        // Process the 3d request
                        var authorization = new PaymentAuthorization();

                        authorization.ParentTransactionReference = JSONObj["id"];
                        authorization.AcsUrl = JSONObj["acsURL"];
                        authorization.TermUrl = PaymentTools.GetTermUrl();
                        authorization.PaReq = JSONObj["paReq"];
                        authorization.MD = JSONObj["merchantRefNum"] + "|" + JSONObj["id"] + "|" + cardToken + "|" + cardAddressToken;

                        return authorization;

                    } else {
                        // As the card is not enrolled in 3D Secure
                        // Then run thrpugh the request
                        var thePaymentRequest = CreatePaymentRequest(
                            AuthorizationHeader,
                            Card,
                            Address,
                            accountNumber,
                            Amount,
                            "telephone",
                            TransactionDate,
                            ProviderCredentials,
                            "", // We don't need the IP for this request
                            paymentOrderReference
                        );

                        // Return the object the way 
                        // It is needed
                        return HandlePaymentRequest(
                            thePaymentRequest,
                            "telephone",
                            TransactionDate,
                            Amount,
                            AuthorizationHeader,
                            Card,
                            Address,
                            accountNumber,
                            ProviderCredentials,
                            paymentOrderReference
                        );

                    }
                }

            } else {
                // Catch anything that isnt a 200 Response
                var error = new PaymentError();
                error.Message = requestErrors.message;
                return error;
            }
        }

        private object Handle3dSecureAuthRequest(IRestResponse PaymentRequest)
        {
            JsonDeserializer deserial = new JsonDeserializer();
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            var JSONObj = deserial.Deserialize<Dictionary<string, string>>(PaymentRequest);

            // Make errors global
            // As they wont always exist
            var requestErrors = new NetBanxErrors();
            var errorObject = "";

            // Check that the error object exists
            if (JSONObj.TryGetValue("error", out errorObject)) {
                requestErrors = serializer.Deserialize<NetBanxErrors>(errorObject);
            }

            // Check to see if the rest request 
            // Was processed with out an error
            if (PaymentRequest.StatusCode == HttpStatusCode.OK) {

                // Only pass values if status is completed
                if (JSONObj["status"] == "COMPLETED") {
                    var threeDAuth = serializer.Deserialize<NetBanx3DAuth>(PaymentRequest.Content);
                    return threeDAuth;
                } else {
                    // Catch anything that isnt a 200 Response
                    var error = new PaymentError();
                    error.Message = "There has been an issue authenticating your request. Is this issue persists, please contact support";
                    return error;
                }
            } else {
                // Catch anything that isnt a 200 Response
                var error = new PaymentError();
                error.Message = requestErrors.message;
                return error;
            }
        }

        private string NetBanxCardTypeConversion(string CardType)
        {
            // Create card type object
            var cardTypes = new Dictionary<string, string>();

            // Add card types to the object
            cardTypes["VI"] = "VISA";
            cardTypes["VE"] = "ELECTRON";
            cardTypes["VD"] = "DELTA";
            cardTypes["SO"] = "MAESTRO";
            cardTypes["SF"] = "MAESTRO";
            cardTypes["MD"] = "MAESTRO";
            cardTypes["MC"] = "MASTERCARD";
            cardTypes["JC"] = "JCB";
            cardTypes["DI"] = "DISCOVER";
            cardTypes["DC"] = "DINERS";
            cardTypes["AM"] = "AMEX";

            // Now the CardType object has been built
            // return the cardType
            return cardTypes[CardType];
        }

        public class NetBanxErrors
        {
            public string code { get; set; }
            public string message { get; set; }
        }

        public class NetBanx3DAuth
        {
            public string id { get; set; }
            public string cavv { get; set; }
            public int eci { get; set; }
            public string xid { get; set; }
            public string signatureStatus { get; set; }
            public string threeDResult { get; set; }
            public NetBanxEnrollment[] enrollmentchecks { get; set; }
        }

        public class NetBanxEnrollment
        {
            public int amount { get; set; }
            public NetBanxCard card { get; set; }
        }

        public class NetBanxCard
        {
            public string type { get; set; }
            public string cvv { get; set; }
            public string cardType { get; set; }
            public string lastDigits { get; set; }
            public string cardNum { get; set; }
            public NetBanxCardDates cardExpiry { get; set; }
        }

        public class NetBanxCardDates
        {
            public int month { get; set; }
            public int year { get; set; }
        }


    }
}
