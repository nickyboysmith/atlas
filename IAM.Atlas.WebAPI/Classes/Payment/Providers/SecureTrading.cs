using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.WebAPI.Models.Payment;
using IAM.Atlas.Tools;
using System.Xml.Linq;
using System.Net;
using System.Xml;
using System.IO;
using System.Xml.Serialization;
using System.Web;

namespace IAM.Atlas.WebAPI.Classes.Payment.Providers
{
    public class SecureTrading : PaymentProviderInterface
    {
        private string WebServiceHost = System.Configuration.ConfigurationManager.AppSettings["SecureTradingServiceHost"].ToString();
        private string WebServiceUrl = System.Configuration.ConfigurationManager.AppSettings["SecureTradingServiceURL"].ToString();

        /// <summary>
        /// Process the card charge
        /// </summary>
        /// <param name="Card"></param>
        /// <param name="Address"></param>
        /// <param name="Amount"></param>
        /// <param name="ChargeType"></param>
        /// <param name="ProviderCredentials"></param>
        /// <param name="ClientIP"></param>
        /// <returns></returns>
        public object ChargeCard(Card Card, CardHolderAddress Address, decimal Amount, string ChargeType, object ProviderCredentials, string ClientIP, string paymentOrderReference)
        {

            var credentials = ProviderCredentials as IDictionary<string, object>;
            var username = credentials["username"].ToString();
            var password = credentials["password"].ToString();
            var siteReference = credentials["sitereference"];
            var accountChargeType = TransformChargeType(ChargeType);
            var requestChargeType = TransformRequestType(ChargeType);

            var AuthorizationHeader = "Basic " + PaymentTools.EncodeAuthorization(username, password);
            var theParsedDate = DateTime.Now;

            var paymentRequestXML = CreatePaymentRequestXML(Card, Address, Amount, accountChargeType, requestChargeType, ProviderCredentials, theParsedDate, ClientIP, paymentOrderReference);
            var paymentResponseXML = SendRequestToProvider(paymentRequestXML, AuthorizationHeader);

            return HandlePaymentResponse(paymentResponseXML, requestChargeType, theParsedDate, ProviderCredentials, AuthorizationHeader, paymentOrderReference);

        }


        public object CompleteAuthorization(object ProviderCredentials, string MD, string PaRes, string CardType, string paymentOrderReference)
        {
            var credentials = ProviderCredentials as IDictionary<string, object>;
            var username = credentials["username"].ToString();
            var password = credentials["password"].ToString();
            var siteReference = credentials["sitereference"];

            var AuthorizationHeader = "Basic " + PaymentTools.EncodeAuthorization(username, password);
            var theParsedDate = DateTime.Now;

            var paymentRequestXML = CreateCompleteAuthPaymentRequestXML(ProviderCredentials, MD, PaRes, paymentOrderReference);
            var paymentResponseXML = SendRequestToProvider(paymentRequestXML, AuthorizationHeader);

            return HandlePaymentResponse(
                paymentResponseXML, 
                "AUTH", 
                theParsedDate, 
                ProviderCredentials, 
                AuthorizationHeader,
                paymentOrderReference
            );

        }

        private object Handle3DPaymentResponse(object ProviderCredentials, ThreeDSecure ThreeDSecureAuth, string TransactionReference, string OrderReference, string AuthorizationHeader, DateTime ParsedDate, string paymentOrderReference)
        {

            // Check to see if the card is enrolled
            // If it is then return the auth object
            // If not charge card immediately
            if (ThreeDSecureAuth.Enrolled == "Y")
            {
                var authorization = new PaymentAuthorization();

                authorization.ParentTransactionReference = TransactionReference;
                authorization.AcsUrl = ThreeDSecureAuth.AcsUrl;
                authorization.TermUrl = PaymentTools.GetTermUrl();
                authorization.PaReq = ThreeDSecureAuth.PaReq;
                authorization.MD = ThreeDSecureAuth.MD;

                return authorization;
            }
            else
            {
                // Build the not enrolled payment XML File
                var paymentRequestXML = CreateNonEnrolledPaymentRequestXML(
                    ProviderCredentials,
                    TransactionReference,
                    paymentOrderReference,
                    "AUTH"
                );
                var paymentResponseXML = SendRequestToProvider(paymentRequestXML, AuthorizationHeader);

                // Handle the payment response
                return HandlePaymentResponse(paymentResponseXML, "AUTH", ParsedDate, ProviderCredentials, AuthorizationHeader, paymentOrderReference);
            }

            
        }

        private object HandlePaymentResponse(SecureTradingResponse PaymentResponse, string RequestChargeType, DateTime ParsedDate, object ProviderCredentials, string AuthorizationHeader, string paymentOrderReference)
        {

            var theResponse = PaymentResponse.Reponses.First();
            var responseType = theResponse.Type;
            var threeDSecureAuth = (theResponse.ThreeDSecureAuth == null) ? null : theResponse.ThreeDSecureAuth.First();
            var errorCode = theResponse.Errors.First().Code;
            var errorMessage = theResponse.Errors.First().Message;
            var merchant = (theResponse.Merchants == null) ? null : theResponse.Merchants.First();
            var theCardType = (theResponse.Billings == null) ? null : theResponse.Billings.First().Payments.First().CardType;

            // Check to see if the payment is successful
            var isPaymentSuccessful = PaymentSuccessCheck(responseType, Convert.ToInt32(errorCode), errorMessage);

            // Return a success type 
            // If payment has been processed
            if (isPaymentSuccessful == true)
            {
                if (RequestChargeType == "THREEDQUERY")
                {
                    return Handle3DPaymentResponse(
                        ProviderCredentials, 
                        threeDSecureAuth, 
                        theResponse.TransactionReference, 
                        merchant.OrderReference, 
                        AuthorizationHeader, 
                        ParsedDate,
                        paymentOrderReference
                    );
                }
                // If the Charge Type isnt THREEDQuery
                // Then Return Normal Payment Object
                else
                {
                    var success = new PaymentSuccess();
                    success.CardType = theCardType;
                    success.TransactionDate = ParsedDate;
                    success.AuthCode = theResponse.AuthCode;
                    success.TransactionReference = theResponse.TransactionReference;
                    return success;
                }
            }
            // Return error type if  
            else if (isPaymentSuccessful == false)
            {
                var error = new PaymentError();
                error.Message = errorMessage;
                return error;
            }
            // If it isnt a bool then return an error
            else
            {
                var error = new PaymentError();
                error.Message = "There has been an error! Please retry payment.";
                return error;
            }
        }

        public object ErrorHandler(string ErrorMessage)
        {
            return ErrorMessage;
        }

        /// <summary>
        /// Check the status of the payment
        /// </summary>
        /// <param name="Type"></param>
        /// <param name="ErrorCode"></param>
        /// <param name="Message"></param>
        /// <returns></returns>
        public bool PaymentSuccessCheck(string Type, int ErrorCode, string Message)
        {
            if (ErrorCode != 0 && Message != "Ok")
            {
                return false;
            }
            return true;
        }

 

        private XDocument CreateCompleteAuthPaymentRequestXML(object ProviderCredentials, string MD, string PaRes, string paymentOrderReference)
        {
            var credentials = ProviderCredentials as IDictionary<string, object>;
            var siteReference = credentials["sitereference"].ToString();
            var username = credentials["username"].ToString();

            var xml = new XElement("requestblock",
                new XAttribute("version", "3.67"),
                new XElement("alias", username),
                new XElement("request",
                    new XAttribute("type", "AUTH"),
                        new XElement("operation",
                            new XElement("md", MD),
                            new XElement("pares", PaRes)
                        ),
                        new XElement("merchant",
                            new XElement("orderreference", paymentOrderReference) 
                        )
                )
            );

            return new XDocument(xml);
        }

        private XDocument CreateNonEnrolledPaymentRequestXML(object ProviderCredentials, string TransactionReference, string paymentOrderReference, string RequestType)
        {
            var credentials = ProviderCredentials as IDictionary<string, object>;
            var siteReference = credentials["sitereference"].ToString();
            var username = credentials["username"].ToString();

            var xml = new XElement("requestblock",
                new XAttribute("version", "3.67"),
                new XElement("alias", username),
                new XElement("request",
                    new XAttribute("type", RequestType),
                        new XElement("operation",
                            new XElement("sitereference", siteReference),
                            new XElement("parenttransactionreference", TransactionReference)
                        ),
                        new XElement("merchant",
                            new XElement("orderreference", paymentOrderReference)
                        )
                )
            );

            return new XDocument(xml);

        }

        /// <summary>
        /// Build the XML Request!
        /// That will be sent to Secure trading
        /// </summary>
        /// <param name="Card"></param>
        /// <param name="Address"></param>
        /// <param name="Amount"></param>
        /// <param name="ChargeType"></param>
        /// <param name="ProviderCredentials"></param>
        /// <param name="transactionDate"></param>
        /// <param name="ClientIP"></param>
        /// <returns></returns>
        private XDocument CreatePaymentRequestXML(Card Card, CardHolderAddress Address, decimal Amount, string ChargeType, string RequestType, object ProviderCredentials, DateTime transactionDate, string ClientIP, string paymentOrderReference)
        {


            var credentials = ProviderCredentials as IDictionary<string, object>;
            var siteReference = credentials["sitereference"].ToString();
            var username = credentials["username"].ToString();

            var nameSplit = Card.HolderName.Split(null);
            var nameCount = nameSplit.Count();
            var firstName = nameSplit[0];
            var lastName = nameSplit[(nameCount - 1)];

            var accept = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5";

            var termUrl = PaymentTools.GetTermUrl();

            var expiryDate = (Card == null) ? "" : Card.GetDates(Card.Expiry);
            var startDate = (Card == null) || Card.Start == null ? "" : Card.GetDates(Card.Start);

            var creditCardNumber = (Card == null) ? "" : Card.Number;
            var cv2 = (Card == null) ? "" : Card.CV2;
            var cardType = (Card == null) ? "" : Card.Type;


            var xml = new XElement("requestblock",
                new XAttribute("version", "3.67"),
                new XElement("alias", username),
                new XElement("request",
                    new XAttribute("type", RequestType),
                        new XElement("operation",
                            new XElement("sitereference", siteReference),
                            new XElement("accounttypedescription", ChargeType)
                        ),
                        new XElement("merchant",
                            new XElement("orderreference", paymentOrderReference),
                            (RequestType == "THREEDQUERY") ? new XElement("termurl", termUrl) : null
                        ),
                        new XElement("customer",
                            new XElement("ip", ClientIP),
                            new XElement("accept", accept)
                            
                        ),
                        new XElement("billing",
                            new XElement("amount",
                                new XAttribute("currencycode", "GBP"),
                                Convert.ToInt32(Amount * 100) // Add parameter (amount in pence * 100)
                            ),
                            //new XElement("town", "London"),
                            new XElement("premise", Address.StreetAddress),
                            new XElement("postcode", Address.PostCode),
                            new XElement("country", "GB"),
                            new XElement("name",
                                new XElement("first", firstName),
                                new XElement("last", lastName)
                            ),
                            new XElement("payment",
                                new XAttribute("type", cardType),
                                    new XElement("expirydate", expiryDate),
                                    new XElement("startdate",startDate),
                                    new XElement("pan", creditCardNumber),
                                    new XElement("securitycode", cv2)
                            )
                        ),
                        new XElement("settlement")
                )

            ); 


            return new XDocument(xml);
          
        }

        /// <summary>
        /// Send the xml request to Secure Trading
        /// </summary>
        /// <param name="XMLContent"></param>
        /// <param name="BasicAuth"></param>
        /// <returns></returns>
        private SecureTradingResponse SendRequestToProvider (XDocument XMLContent, string BasicAuth)
        {


            HttpWebResponse httpWebResponse = null;
            Stream requestStream = null;

            // Create HttpWebRequest for the API URL.
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(this.WebServiceUrl);

            try
            {

                var bytes = Encoding.ASCII.GetBytes(XMLContent.ToString());

                httpWebRequest.Method = "POST";
                httpWebRequest.ContentType = "text/xml; charset=utf-8";
                httpWebRequest.ContentLength = bytes.Length;
                httpWebRequest.Accept = "text/xml";
                httpWebRequest.KeepAlive = false;
                httpWebRequest.Host = this.WebServiceHost;
                httpWebRequest.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0b; Windows NT 5.1; .NET CLR 1.0.2914)";
                httpWebRequest.Headers.Add(HttpRequestHeader.AcceptEncoding, "gzip");
                httpWebRequest.Headers.Add(HttpRequestHeader.Authorization, BasicAuth);
                httpWebRequest.Headers.Add(HttpRequestHeader.AcceptEncoding, "gzip,deflate");
                httpWebRequest.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;

                //Get Stream object
                requestStream = httpWebRequest.GetRequestStream();
                requestStream.Write(bytes, 0, bytes.Length);
                requestStream.Close();

                // Post the Request.
                httpWebResponse = (HttpWebResponse)httpWebRequest.GetResponse();

                var response = new SecureTradingResponse();

                // If the submission is success, Status Code would be OK
                if (httpWebResponse.StatusCode == HttpStatusCode.OK)
                {
                    string xml = string.Empty;
                    using (StreamReader sr = new StreamReader(httpWebResponse.GetResponseStream()))
                    {
                        xml = sr.ReadToEnd();
                    }
                    response = SecureTradingResponse.FromXmlString(xml);
                }
                else {
                    throw new Exception("Error sending payment to provider");
                }
                return response;
            }
            catch (WebException webException)
            {
                throw new Exception(webException.Message);
            }
            catch (Exception exception)
            {
                throw new Exception(exception.Message);
            }

  
        }


        /// <summary>
        /// Check to the charge type and 
        /// If the type is telephone set to MOTO
        /// If not Set to ECOM
        /// </summary>
        /// <param name="PaymentChargeType"></param>
        /// <returns></returns>
        private string TransformChargeType(string PaymentChargeType)
        {
            var chargeType = "ECOM";
            if (PaymentChargeType == "telephone")
            {
                chargeType = "MOTO";
            } 
            return chargeType;
        }


        /// <summary>
        /// Check to the request type!
        /// Set the default type to AUTH
        /// If the type is online then SET to THREEDQUERY
        /// </summary>
        /// <param name="PaymentRequestType"></param>
        /// <returns></returns>
        private string TransformRequestType(string PaymentRequestType)
        {
            var requestType = "AUTH";
            if (PaymentRequestType == "online")
            {
                requestType = "THREEDQUERY";
            }
            return requestType;
        }


        [XmlRoot("responseblock")]
        public sealed class SecureTradingResponse
        {

            [XmlElement("requestreference")]
            public string RequestReference { get; set; }

            [XmlElement("secrand")]
            public string Secrand { get; set; }

            [XmlElement("response", Type = typeof(Response))]
            public Response[] Reponses { get; set; }

            public SecureTradingResponse()
            {
                Reponses = null;
            }

            public static SecureTradingResponse FromXmlString(string xmlString)
            {
                var reader = new StringReader(xmlString);
                var serializer = new XmlSerializer(typeof(SecureTradingResponse));
                var instance = (SecureTradingResponse)serializer.Deserialize(reader);
                return instance;
            }

        }

        [Serializable]
        public class Response
        {
            [XmlAttribute("type")]
            public string Type { get; set; }

            [XmlElement("transactionreference")]
            public string TransactionReference {get; set;}

            [XmlElement("timestamp")]
            public string TimeStamp { get; set; }

            [XmlElement("acquirerresponsecode")]
            public string AcquirerResponseCode { get; set; }

            [XmlElement("authcode")]
            public string AuthCode { get; set; }

            [XmlElement("live")]
            public int Live { get; set; }

            [XmlElement("merchant")]
            public Merchant[] Merchants { get; set; }

            [XmlElement("operation")]
            public Operation[] Operations { get; set; }

            [XmlElement("settlement")]
            public Settlement[] Settlements { get; set; }

            [XmlElement("billing")]
            public Billing[] Billings { get; set; }

            [XmlElement("error")]
            public Error[] Errors { get; set; }

            [XmlElement("security")]
            public Security[] Securities { get; set; }

            [XmlElement("threedsecure")]
            public ThreeDSecure[] ThreeDSecureAuth { get; set; }


            public Response()
            {
                Merchants = null;
                Operations = null;
                Settlements = null;
                Billings = null;
                Errors = null;
                Securities = null;
                ThreeDSecureAuth = null;
            }

        }

        [Serializable]
        public class Merchant
        {
            [XmlElement("orderreference")]
            public string OrderReference { get; set; }

            [XmlElement("tid")]
            public int Tid { get; set; }

            [XmlElement("merchantnumber")]
            public int MerchantNumber { get; set; }

            [XmlElement("merchantcountryiso2a")]
            public string CountryCode { get; set; }
        }

        [Serializable]
        public class Operation
        {
            [XmlElement("splitfinalnumber")]
            public int SplitFinalNumber { get; set; }

            [XmlElement("accounttypedescription")]
            public string AccountType { get; set; }
        }

        [Serializable]
        public class Settlement
        {
            [XmlElement("settleduedate")]
            public string SettleDueDate { get; set; }

            [XmlElement("settlestatus")]
            public int SettleStatus { get; set; }
        }

        [Serializable]
        public class Billing
        {

            [XmlElement("amount")]
            public int AmountCharged { get; set; }

            [XmlElement("payment")]
            public Payment[] Payments { get; set; }

            public Billing()
            {
                Payments = null;
            }

        }

        [Serializable]
        public class Payment
        {

            [XmlAttribute("type")]
            public string CardType { get; set; }

        }

        [Serializable]
        public class Error
        {
            [XmlElement("message")]
            public string Message { get; set; }

            [XmlElement("code")]
            public string Code { get; set; }
        }

        [Serializable]
        public class Security
        {
            [XmlElement("postcode")]
            public int PostcodeVerified { get; set; }

            [XmlElement("securitycode")]
            public int SecurityCodeVerified { get; set; }

            [XmlElement("address")]
            public int AddressVerified { get; set; }
        }

        public class ThreeDSecure
        {
            [XmlElement("acsurl")]
            public string AcsUrl { get; set; }

            [XmlElement("md")]
            public string MD { get; set; }

            [XmlElement("pareq")]
            public string PaReq { get; set; }

            [XmlElement("enrolled")]
            public string Enrolled { get; set; }
        }
        

    }
}
