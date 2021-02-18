using IAM.Atlas.WebAPI.Controllers;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Services.Description;
using System.Web.Services.Protocols;
using System.Xml.Serialization;
using IAM.Atlas.WebAPI;
using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models.Netcall;
using System.Text;

namespace IAM.Atlas.Netcall.WebService
{
    /// <summary>
    /// Summary description for netcall
    /// </summary>
    [WebService(Namespace = "urn:netcall")]
    [System.ComponentModel.ToolboxItem(false)]
    [SoapRpcService(Use = SoapBindingUse.Literal)]
    public class Netcall : System.Web.Services.WebService
    {
        [WebMethod]
        [SoapRpcMethod(RequestNamespace = "urn:tppayments", ResponseNamespace = "urn:netcall", Use = SoapBindingUse.Literal)]
        public AccountDetail GetAccountDetails(string RequestID, string RequestTime, string CallingNumber, string AppContext, string ClientID, string DOB)
        {
            AccountDetailWithCourseId accountDetailWithCourseId = null;
            NetCallController netcallController = null;
            try
            {
                netcallController = new NetCallController();

                // log request
                var netcallRequest = netcallController.logNetcallRequest(RequestID, RequestTime, CallingNumber, AppContext, ClientID, DOB);

                if (String.IsNullOrEmpty(CallingNumber))
                {
                    // No agent is involved and a client (already booked on a course) wishes to make a payment.
                    accountDetailWithCourseId = netcallController.GetAccountDetailByClientIdAndDOB(ClientID, DOB);
                }
                else
                {
                    // An agent is passing a call to the Netcall system, use the calling number to determine the current client and payment
                    accountDetailWithCourseId = netcallController.GetAccountDetailsByCallingNumber(CallingNumber);
                }

                // log the response
                netcallController.logNetcallResponse(accountDetailWithCourseId, netcallRequest);
            }
            catch(Exception ex)
            {
                if(netcallController != null)
                {
                    var errorRequestParams = new StringBuilder();
                    errorRequestParams.AppendFormat("GetAccountDetails: {0}, {1}, {2}, {3}, {4}, {5}", RequestID, RequestTime, CallingNumber, AppContext, ClientID, DOB);
                    netcallController.logNetcallError(ex.Message, errorRequestParams.ToString(), DateTime.Now);
                }
                accountDetailWithCourseId = new AccountDetailWithCourseId();
                accountDetailWithCourseId.Result = "SYSTEM_ERROR";
            }
            return accountDetailWithCourseId.RemoveCourseId();
        }

        [WebMethod]
        [SoapRpcMethod(RequestNamespace = "urn:tppayments", ResponseNamespace = "urn:netcall", Use = SoapBindingUse.Literal)]
        public AccountPaymentResult PostAccountPaymentResult(string RequestID, string RequestTime, string CallingNumber, string AppContext, string ClientID, string PaymentResult, string AuthorisationReference)
        {
            // VaLidate
            var accountPaymentResult = new AccountPaymentResult();
            NetCallController netcallController = null;

            try
            {
                netcallController = new NetCallController();

                // log request
                var netcallRequest = netcallController.logNetcallRequest(RequestID, RequestTime, CallingNumber, AppContext, ClientID, PaymentResult, AuthorisationReference);
                
                accountPaymentResult = netcallController.SaveAccountPaymentResult(RequestID, RequestTime, CallingNumber, AppContext, ClientID, PaymentResult, AuthorisationReference);

                // log the response
                netcallController.logNetcallResponse(accountPaymentResult, netcallRequest);
            }
            catch(Exception ex)
            {
                if (netcallController != null)
                {
                    var errorRequestParams = new StringBuilder();
                    errorRequestParams.AppendFormat("GetAccountDetails: {0}, {1}, {2}, {3}, {4}, {5}, {6}", RequestID, RequestTime, CallingNumber, AppContext, ClientID, PaymentResult, AuthorisationReference);
                    netcallController.logNetcallError(ex.Message, errorRequestParams.ToString(), DateTime.Now);
                }
                accountPaymentResult = new AccountPaymentResult();
                accountPaymentResult.Result = "SYSTEM_ERROR";
            }
            return accountPaymentResult;
        }
        
        private string CreateTransactionReference (
            string ClientId, 
            string CourseReference, 
            string Region
        )
        {
            // Create empty holder
            var regionId = "";

            // Create the region Id
            if (CourseReference == "Greater Manchester") {
                regionId = "GM";
            } else if (CourseReference == "Merseyside") {
                regionId = "M";
            } else {
                regionId = "X";
            }

            return ClientId + " - " + regionId + " - " + CourseReference;
        }

        private AccountDetail AccountDetailsRequestError(string ErrorType, string ErrorMessage)
        {
            var account = new AccountDetail();
            account.Result = ErrorType;
            account.ResultDescription = ErrorMessage;
            return account;
        }

        private AccountPaymentResult AccountPaymentResultRequestError(string ErrorType, string ErrorMessage)
        {
            var paymentResult = new AccountPaymentResult();
            paymentResult.Result = ErrorType;
            paymentResult.ResultDescription = ErrorMessage;
            return paymentResult;
        }

        private void LogRequest(NetCallController netcall, NetcallRequest Request)
        {
            try {
                netcall.SaveNetCallRequest(Request);
            } catch (Exception e) {
                // Log
            }
        }

    }

}
