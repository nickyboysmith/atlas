using IAM.Atlas.WebAPI.AtlasNetcallWebservice;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.ServiceModel.Channels;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class NetcallTestController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/NetcallTest/GetAccountDetails/{requestId}/{appContext}/{agentsPhoneExtension}")]
        public AccountDetail GetAccountDetails(string requestId, string appContext, string agentsPhoneExtension)
        {
            var soapClient = new AtlasNetcallWebservice.NetcallSoapClient("NetcallSoap" + getSystemName());
            var accountDetail = soapClient.GetAccountDetails(requestId, DateTime.Now.ToString(), agentsPhoneExtension, appContext, "", "");
            return accountDetail;
        }

        [HttpGet]
        [Route("api/NetcallTest/PostAccountPaymentResult/{requestId}/{appContext}/{clientId}/{paymentResult}/{authorisationReference}")]
        public AccountPaymentResult PostAccountPaymentResult(string requestId, string appContext, string clientId, string paymentResult, string authorisationReference)
        {
            var soapClient = new AtlasNetcallWebservice.NetcallSoapClient("NetcallSoap" + getSystemName());
            var accountPaymentResult = soapClient.PostAccountPaymentResult(requestId, DateTime.Now.ToString(), "", appContext, clientId, paymentResult, authorisationReference);
            return accountPaymentResult;
        }

        /// <summary>
        /// Returns a name for the system's environment, e.g. Test, Dev, UAT...
        /// </summary>
        /// <returns>the name for this environment</returns>
        string getSystemName()
        {
            var environmentName = "Dev";
            var systemControl = atlasDB.SystemControls.FirstOrDefault();
            if (systemControl != null)
            {
                environmentName = systemControl.AtlasSystemCode;
            }            
            return environmentName;
        }
    }
}