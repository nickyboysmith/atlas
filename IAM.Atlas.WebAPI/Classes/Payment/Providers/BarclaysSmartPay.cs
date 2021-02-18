using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.WebAPI.Models.Payment;
using System.Xml.Linq;
using System.Xml;
using System.Net;
using System.IO;
using System.Xml.Serialization;
using System.Threading;
using System.Runtime.InteropServices.WindowsRuntime;

namespace IAM.Atlas.WebAPI.Classes.Payment.Providers
{
    public class BarclaysSmartPay : PaymentProviderInterface
    {
        /**
         * @todo Move all payment urls to web config
         */
        private string WebServiceUrl = System.Configuration.ConfigurationManager.AppSettings["BarclaycardSmartpayURL"].ToString();
        private string WebServiceAction = System.Configuration.ConfigurationManager.AppSettings["BarclaycardSmartpayAction"].ToString();

        public object ChargeCard(Card Card, CardHolderAddress Address, decimal Amount, string ChargeType, object ProviderCredentials, string ClientIP, string paymentOrderReference)
        {

            var credentials = ProviderCredentials as IDictionary<string, object>;
            var username = credentials["username"].ToString();
            var password = credentials["password"].ToString();
            var merchantAccount = credentials[GetPaymentAccountType(ChargeType)].ToString();
            var theParsedDate = DateTime.Now;

            // Encode the Username & PW for basic auth
            var AuthorizationHeader = "Basic " + PaymentTools.EncodeAuthorization(username, password);

            // Build the XML for a PaymentRequest
            var paymentRequestXML = CreatePaymentRequest(
                Card,
                merchantAccount,
                Amount,
                ChargeType,
                theParsedDate,
                ProviderCredentials,
                ClientIP,
                paymentOrderReference
            );

            var paymentResponseXML = SendPaymentRequestToProvider(paymentRequestXML, AuthorizationHeader, false);
            return HandlePaymentResponse(paymentResponseXML, Card.Type, theParsedDate);

        }

        public object CompleteAuthorization(object ProviderCredentials, string MD, string PaRes, string CardType, string paymentOrderReference)
        {
            var credentials = ProviderCredentials as IDictionary<string, object>;
            var username = credentials["username"].ToString();
            var password = credentials["password"].ToString();
            var merchantAccount = credentials[GetPaymentAccountType("online")].ToString();
            var theParsedDate = DateTime.Now;

            // Encode the Username & PW for basic auth
            var AuthorizationHeader = "Basic " + PaymentTools.EncodeAuthorization(username, password);

            // Build the XML for a PaymentRequest
            var paymentRequestXML = Create3DAuthCompletionRequest(
                merchantAccount,
                MD,
                PaRes
            );

            var paymentResponseXML = SendPaymentRequestToProvider(paymentRequestXML, AuthorizationHeader, true);
            return HandlePaymentResponse(paymentResponseXML, CardType, theParsedDate); // todo hardcoded card type for smart pay -  find a way to get correct card type

        }


        public object ErrorHandler(string ErrorMessage)
        {
            return ErrorMessage;
        }

        private string CreatePaymentRequest(
            Card Card,
            string MerchantAccount,
            decimal Amount,
            string ChargeType,
            DateTime TransactionDate,
            object ProviderCredentials,
            string ClientIP,
            string paymentOrderReference
        )
        {
            
            var nameSplit = Card.HolderName.Split(null);
            var nameCount = nameSplit.Count();
            var firstName = nameSplit[0];
            var lastName = nameSplit[(nameCount - 1)];

            // Browser details
            var userAgent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008052912 Firefox/3.0";
            var accept = "text/html,application/xhtml+xml, application / xml; q = 0.9,*/*;q=0.8";

            // Get the card details
            var expiryMonth =  "";
            var expiryYear = "";
            var startMonth = "";
            var startYear = "";
            var creditCardNumber = "";
            var cv2 = "";
            var cardType = "";

            if (Card != null)
            {
                if (Card.Expiry != null)
                {
                    expiryMonth = Card.Expiry.Month;
                    expiryYear = Card.Expiry.Year;
                }
                if (Card.Start != null)
                {
                    startMonth = Card.Start.Month;
                    startYear = Card.Start.Year;
                }
                creditCardNumber = Card.Number;
                cv2 = Card.CV2;
                cardType = Card.Type;
            }

            

            // Build the xml string
            StringBuilder xml = new StringBuilder();
            xml.Append("<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">");
            xml.Append("<soap:Body>");
            xml.Append("<ns1:authorise xmlns:ns1=\"http://payment.services.adyen.com\">");
            xml.Append("<ns1:paymentRequest>");
            xml.Append("<amount xmlns=\"http://payment.services.adyen.com\">");
            xml.Append("<currency xmlns=\"http://common.services.adyen.com\">GBP</currency>");
            xml.Append("<value xmlns=\"http://common.services.adyen.com\">" + Convert.ToInt32(Amount * 100) + "</value>");
            xml.Append("</amount>");
            xml.Append("<card xmlns=\"http://payment.services.adyen.com\">");
            xml.Append("<cvc>" + cv2 + "</cvc>");
            xml.Append("<expiryMonth>" + expiryMonth + "</expiryMonth>");
            xml.Append("<expiryYear>" + expiryYear  + "</expiryYear>");
            xml.Append("<startMonth>" + startMonth  + "</startMonth>");
            xml.Append("<startYear>" + startYear + "</startYear>");
            xml.Append("<holderName>" + Card.HolderName + "</holderName>");
            xml.Append("<number>" + creditCardNumber + "</number>");
            xml.Append("</card>");

            // If the chargetype is online
            // Then add new xml node
            if (ChargeType == "online")
            {
                xml.Append("<browserInfo xmlns=\"http://payment.services.adyen.com\">");
                xml.Append("<acceptHeader xmlns=\"http://common.services.adyen.com\">");
                xml.Append(accept);
                xml.Append("</acceptHeader>");
                xml.Append("<userAgent xmlns=\"http://common.services.adyen.com\">");
                xml.Append(userAgent);
                xml.Append("</userAgent>");
                xml.Append("</browserInfo>");
            }

            xml.Append("<merchantAccount xmlns=\"http://payment.services.adyen.com\">" + MerchantAccount + "</merchantAccount>");
            xml.Append("<reference xmlns=\"http://payment.services.adyen.com\">");
            xml.Append(paymentOrderReference);
            xml.Append("</reference>");
            xml.Append("<shopperIP xmlns=\"http://payment.services.adyen.com\">" + ClientIP + "</shopperIP>");
            xml.Append("<shopperReference xmlns=\"http://payment.services.adyen.com\">" + Card.HolderName + "</shopperReference>");
            xml.Append("</ns1:paymentRequest>");
            xml.Append("</ns1:authorise>");
            xml.Append("</soap:Body>");
            xml.Append("</soap:Envelope>");

            return xml.ToString();

        }

        private string Create3DAuthCompletionRequest(string MerchantAccount, string MD, string PaRes)
        {

            // Browser details
            var userAgent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008052912 Firefox/3.0";
            var accept = "text/html,application/xhtml+xml, application / xml; q = 0.9,*/*;q=0.8";

            // Build the xml string
            StringBuilder xml = new StringBuilder();
            xml.Append("<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">");
            xml.Append("<soap:Body>");
            xml.Append("<ns1:authorise3d xmlns:ns1=\"http://payment.services.adyen.com\">");
            xml.Append("<ns1:paymentRequest3d>");
            xml.Append("<browserInfo xmlns=\"http://payment.services.adyen.com\">");
            xml.Append("<acceptHeader xmlns=\"http://common.services.adyen.com\">");
            xml.Append(accept);
            xml.Append("</acceptHeader>");
            xml.Append("<userAgent xmlns=\"http://common.services.adyen.com\">");
            xml.Append(userAgent);
            xml.Append("</userAgent>");
            xml.Append("</browserInfo>");
            xml.Append("<md xmlns=\"http://payment.services.adyen.com\">" + MD + "</md>");
            xml.Append("<paResponse xmlns=\"http://payment.services.adyen.com\">" + PaRes + "</paResponse>");
            xml.Append("<merchantAccount xmlns=\"http://payment.services.adyen.com\">" + MerchantAccount + "</merchantAccount>");
            xml.Append("</ns1:paymentRequest3d>");
            xml.Append("</ns1:authorise3d>");
            xml.Append("</soap:Body>");
            xml.Append("</soap:Envelope>");

            return xml.ToString();

        }

        private object SendPaymentRequestToProvider(string XMLContent, string BasicAuth, bool Request3DAuth)
        {

            HttpWebResponse httpWebResponse = null;
            var response = new Object();

            // Create HttpWebRequest for the API URL.
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(this.WebServiceAction);

            try
            {
                httpWebRequest.Method = "POST";
                httpWebRequest.ContentType = "text/xml; charset=utf-8";
                httpWebRequest.Accept = "text/xml";

                // set connection properties
                httpWebRequest.KeepAlive = true;  //15 sec on server side
                httpWebRequest.Timeout = Timeout.Infinite;
                httpWebRequest.Headers.Add("SOAPAction", this.WebServiceAction);
                httpWebRequest.Headers.Add(HttpRequestHeader.Authorization, BasicAuth);

                // 
                XmlDocument soapEnvelopeXml = new XmlDocument();
                soapEnvelopeXml.LoadXml(XMLContent);

                //Get Stream object
                using (Stream stream = httpWebRequest.GetRequestStream())
                {
                    soapEnvelopeXml.Save(stream);
                }

                // Post the Request.
                httpWebResponse = (HttpWebResponse)httpWebRequest.GetResponse();

                // If the submission is success, Status Code would be OK
                if (httpWebResponse.StatusCode == HttpStatusCode.OK)
                {
                    string xml = string.Empty;
                    using (StreamReader sr = new StreamReader(httpWebResponse.GetResponseStream()))
                    {
                        xml = sr.ReadToEnd();
                    }

                    // If charging a card 
                    // That has gone through 3D Secure
                    if (Request3DAuth) {
                        response = SmartPay3DSoapResponse(xml);
                    }
                    else {
                        response = SmartPaySoapResponse(xml);
                    }

                }
                else {
                    throw new Exception("Error sending payment to provider");
                }

            } catch (WebException webException) {

                WebResponse errRsp = webException.Response;
                using (StreamReader rdr = new StreamReader(errRsp.GetResponseStream())) {
                    string text = rdr.ReadToEnd();
                }

                throw new Exception(webException.Message);

            }
            catch (Exception exception) {
                throw new Exception(exception.Message);
            }

            return response;

        }

        // TODO: Refactor
        private PaymentResult SmartPaySoapResponse(string xml)
        {

            var xdoc = new XmlDocument();
            var xDocument = new XDocument();

            try
            {
                xdoc.LoadXml(@xml);
                xDocument = ToXDocument(xdoc);

                XNamespace soap = "http://schemas.xmlsoap.org/soap/envelope/";
                var soapBody = xDocument.Descendants(soap + "Body").First().FirstNode;

                var xmlString = new StringReader(soapBody.ToString());
                var serializer = new XmlSerializer(typeof(PaymentResult));
                return (PaymentResult)serializer.Deserialize(xmlString);
                
            } catch (Exception ex) {
                throw new Exception(ex.Message);
            }

        }

        private Payment3DResult SmartPay3DSoapResponse(string xml)
        {

            var xdoc = new XmlDocument();
            var xDocument = new XDocument();

            try
            {
                xdoc.LoadXml(@xml);
                xDocument = ToXDocument(xdoc);

                XNamespace soap = "http://schemas.xmlsoap.org/soap/envelope/";
                var soapBody = xDocument.Descendants(soap + "Body").First().FirstNode;

                var xmlString = new StringReader(soapBody.ToString());
                var serializer = new XmlSerializer(typeof(Payment3DResult));
                return (Payment3DResult)serializer.Deserialize(xmlString);

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

        }


        private object HandlePaymentResponse(object ThePaymentResult, string CardType, DateTime TransactionDate)
        {

            dynamic UpdatedPaymentResult = ThePaymentResult;
            var response = UpdatedPaymentResult.Responses[0];
            var resultCode = response.ResultCode;
            var authCode = response.AuthCode;
            var transactionRef = response.TransactionReference;
            var errorMessage = response.RefusalReason;

            // Check to see if there is an error
            if (resultCode == "Authorised")
            {

                var success = new PaymentSuccess();
                success.CardType = CardType;
                success.TransactionDate = TransactionDate;
                success.AuthCode = authCode;
                success.TransactionReference = transactionRef;
                return success;

            } else if (resultCode == "RedirectShopper") { 

                return Handle3DPaymentResponse(response);

            } else {

                var error = new PaymentError();
                error.Message = errorMessage;
                return error;
            }

        }

        private object Handle3DPaymentResponse(Response TheResponse)
        {

            var authorization = new PaymentAuthorization();

            authorization.ParentTransactionReference = TheResponse.TransactionReference;
            authorization.AcsUrl = TheResponse.IssuerUrl;
            authorization.TermUrl = PaymentTools.GetTermUrl();
            authorization.PaReq = TheResponse.PaRes;
            authorization.MD = TheResponse.MD;

            return authorization;

        }

        private string GetPaymentAccountType(string ChargeType)
        {
            var paymentAccountType = "merchantAccount";
            if (ChargeType == "telephone")
            {
                paymentAccountType = "motoAccount";
            }
            return paymentAccountType;
        }

        /// <summary>
        /// 
        /// </summary>
        [System.Xml.Serialization.XmlRootAttribute("authoriseResponse", Namespace = "http://payment.services.adyen.com", IsNullable = false)]
        public sealed class PaymentResult
        {
            [XmlElement("paymentResult", Type = typeof(Response))]
            public Response[] Responses { get; set; }

            public PaymentResult()
            {
                Responses = null;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        [System.Xml.Serialization.XmlRootAttribute("authorise3dResponse", Namespace = "http://payment.services.adyen.com", IsNullable = false)]
        public sealed class Payment3DResult
        {
            [XmlElement("paymentResult", Type = typeof(Response))]
            public Response[] Responses { get; set; }

            public Payment3DResult()
            {
                Responses = null;
            }
        }

        /// <summary>
        ///     
        /// </summary>
        [Serializable]
        public class Response
        {

            [XmlElement("authCode")]
            public string AuthCode { get; set; }

            [XmlElement("resultCode")]
            public string ResultCode { get; set; }

            [XmlElement("refusalReason")]
            public string RefusalReason { get; set; }

            [XmlElement("pspReference")]
            public string TransactionReference { get; set; }

            [XmlElement("md")]
            public string MD { get; set; }

            [XmlElement("paRequest")]
            public string PaRes { get; set; }

            [XmlElement("issuerUrl")]
            public string IssuerUrl { get; set; }
        }

        /// <summary>
        ///     
        /// </summary>
        /// <param name="xmlDocument"></param>
        /// <returns></returns>
        public XDocument ToXDocument(XmlDocument xmlDocument)
        {
            using (var nodeReader = new XmlNodeReader(xmlDocument))
            {
                nodeReader.MoveToContent();
                return XDocument.Load(nodeReader);
            }
        }
        

    }
}
