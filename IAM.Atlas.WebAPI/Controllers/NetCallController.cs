using IAM.Atlas.Data;
using System.Data.Entity;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web;
using System.Runtime.Serialization;
using System.Xml.Serialization;
using System.Web.Http;
using System.Xml;
using System.Xml.Linq;
using System.IO;
using System.Xml.Schema;
using IAM.Atlas.WebAPI.Models.Netcall;
using System.Globalization;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class NetCallController : AtlasBaseController
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="CallingNumber"></param>
        /// <returns></returns>
        public AccountDetailWithCourseId GetAccountDetailsByCallingNumber(string CallingNumber)
        {
            var callingUser = atlasDB.Users
                                        .Include(u => u.NetcallAgents)
                                        .Where(u => u.NetcallAgents.Any(nca => nca.DefaultCallingNumber == CallingNumber))
                                        .FirstOrDefault();

            AccountDetailWithCourseId accountDetail = null;
            if (callingUser != null && !callingUser.Disabled) {
                accountDetail = atlasDBViews.vwClientDetails
                                            .Where(cd => cd.LockedByUserId == callingUser.Id)
                                            .OrderByDescending(cd => cd.DateTimeLocked)
                                            .Select(cd => new AccountDetailWithCourseId
                                            {
                                                ClientID = cd.ClientId.ToString(),
                                                AmountToPay = (int)(cd.TotalPaymentDueByClient == null ? 0 : cd.TotalPaymentDueByClient * 100) - (int)(cd.AmountPaidByClient == null ? 0 : cd.AmountPaidByClient * 100), // convert to pence
                                                CourseDateTime = cd.CourseStartDate == null ? DateTime.MinValue : (DateTime)cd.CourseStartDate,
                                                CourseVenue = cd.VenueName,
                                                Result = "SUCCESS",
                                                CourseId = cd.CourseId
                                            })
                                            .FirstOrDefault();
                if(accountDetail != null)
                {
                    int clientId = -1;
                    if (int.TryParse(accountDetail.ClientID, out clientId))
                    {
                        var netcallOverride = GetUnpaidNetcallOverride(clientId, accountDetail.CourseId);
                        if(netcallOverride != null)
                        {
                            accountDetail.AmountToPay = (int) (netcallOverride.Amount * 100);    // convert to pence
                        }
                    }
                }
            }
            if(accountDetail == null)
            {
                accountDetail = new AccountDetailWithCourseId();
                accountDetail.Result = "NOT_FOUND";
            }
            return accountDetail;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ClientId"></param>
        /// <param name="DOB"></param>
        /// <returns></returns>
        public AccountDetailWithCourseId GetAccountDetailByClientIdAndDOB(string ClientId, string DOB)
        {
            AccountDetailWithCourseId accountDetail = null;
            int clientId = -1;
            DateTime dob;
            if(int.TryParse(ClientId, out clientId))
            {
                if(DateTime.TryParseExact(DOB, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dob))
                {
                    accountDetail = atlasDBViews.vwClientDetails
                                        .Where(cd => cd.ClientId == clientId && 
                                                        cd.DateOfBirth == dob)
                                        .Select(cd => new AccountDetailWithCourseId
                                        {
                                            ClientID = cd.ClientId.ToString(),
                                            AmountToPay = (int)(cd.TotalPaymentDueByClient == null ? 0 : cd.TotalPaymentDueByClient * 100) - (int)(cd.AmountPaidByClient == null ? 0 : cd.AmountPaidByClient * 100), // convert to pence
                                            CourseDateTime = cd.CourseStartDate == null ? DateTime.MinValue : (DateTime)cd.CourseStartDate,
                                            CourseVenue = cd.VenueName,
                                            Result = "SUCCESS",
                                            CourseId = cd.CourseId
                                        })
                                        .FirstOrDefault();

                    if (accountDetail != null)
                    {
                        var netcallOverride = GetUnpaidNetcallOverride(clientId, accountDetail.CourseId);
                        if (netcallOverride != null)
                        {
                            accountDetail.AmountToPay = (int)(netcallOverride.Amount * 100);    // convert to pence
                        }
                    }
                }
            }
            if (accountDetail == null)
            {
                accountDetail = new AccountDetailWithCourseId();
                accountDetail.Result = "NOT_FOUND";
            }
            return accountDetail;
        }

        /// <summary>
        /// Only returns NetcallOverrides that have no NetcallOverridePayments against them (ie ones that haven't been paid for).
        /// </summary>
        /// <param name="ClientId">The client related to the current netcall request</param>
        /// <param name="CourseId">The course that the current netcall request is for (if available)</param>
        /// <returns></returns>
        NetcallOverride GetUnpaidNetcallOverride(int ClientId, int? CourseId)
        {
            var netcallOverride = atlasDB.NetcallOverrides
                                            .Include(no => no.NetcallOverridePayments)
                                            .Where(no =>    no.ClientId == ClientId && 
                                                            no.CourseId == CourseId && 
                                                            no.Disabled == false &&
                                                            no.NetcallOverridePayments.Count == 0)
                                            .OrderByDescending(no => no.Id)
                                            .FirstOrDefault();
            return netcallOverride;
        }

        public AccountPaymentResult SaveAccountPaymentResult(string RequestID, string RequestTime, string CallingNumber, string AppContext, string ClientID, string PaymentResult, string AuthorisationReference)
        {
            var accountPaymentResult = new AccountPaymentResult();

            if (PaymentResult == "SUCCESS")
            {
                // look up the previous Netcall request for amount the client has paid.
                var netcallRequest = atlasDB.NetcallRequests.Where(nr => nr.InRequestIdentifier == RequestID && nr.OutPaymentAmountInPence > 0).FirstOrDefault();
                int clientId;
                int.TryParse(ClientID, out clientId);

                if (netcallRequest != null && netcallRequest.OutPaymentAmountInPence != null)
                {
                    // get the atlas system user id
                    var systemControl = new SystemControlController().Get();
                    var atlasSystemUserId = -1;
                    if (systemControl != null) atlasSystemUserId = systemControl.AtlasSystemUserId == null ? -1 : (int) systemControl.AtlasSystemUserId;

                    // get the client
                    var client = atlasDB.Clients.Where(c => c.Id == clientId).FirstOrDefault();

                    // does the client.Id equal the clientId in the netcallRequest?
                    if(netcallRequest.OutClientIdentifier != client.Id.ToString())
                    {
                        // set the client to null, this is an unallocated payment
                        client = null;
                    }

                    // record the payment in our DB
                    var payment = new Payment();

                    // the netcallRequest.OutTotalPaymentAmountInPence shouldn't ever be null
                    payment.Amount = netcallRequest.OutPaymentAmountInPence == null ? 0 : (((int) netcallRequest.OutPaymentAmountInPence) / (decimal)100.00);    // convert to Pounds
                    payment.AuthCode = AuthorisationReference;
                    payment.NetcallPayment = true;
                    DateTime requestDateTime;
                    if (!DateTime.TryParseExact(RequestTime, "yyyy-MM-ddThh:mm:ss", CultureInfo.InvariantCulture, DateTimeStyles.None, out requestDateTime))
                    {
                        requestDateTime = DateTime.Now;
                    }
                    payment.TransactionDate = requestDateTime;
                    payment.DateCreated = DateTime.Now;
                    payment.CreatedByUserId = atlasSystemUserId;

                    // add a netcallPayment entry into the DB
                    var netcallPayment = new NetcallPayment();
                    netcallPayment.NetcallRequestId = netcallRequest.Id;

                    payment.NetcallPayments.Add(netcallPayment);

                    // if client == null it is an anonymous payment, do nothing
                    if (client != null)
                    {
                        if (netcallRequest.CourseId > 0)
                        {
                            // create a CourseClientPayment
                            var courseClientPayment = new CourseClientPayment();
                            courseClientPayment.ClientId = client.Id;
                            courseClientPayment.CourseId = (int) netcallRequest.CourseId;
                            courseClientPayment.AddedByUserId = atlasSystemUserId;
                            payment.CourseClientPayments.Add(courseClientPayment);
                        }
                        else
                        {
                            // create a ClientPayment
                            var clientPayment = new ClientPayment();
                            clientPayment.ClientId = client.Id;
                            clientPayment.AddedByUserId = atlasSystemUserId;
                            payment.ClientPayment.Add(clientPayment);
                        }
                        // can we find an unpaid netcallOverride for this request?
                        var netcallOverride = GetUnpaidNetcallOverride(client.Id, netcallRequest.CourseId);
                        if(netcallOverride != null)
                        {
                            if(netcallOverride.Amount == payment.Amount)    // does the override amount match the paid ammount?
                            {
                                // create a netcallOverridePayment for this payment
                                var netcallOverridePayment = new NetcallOverridePayment();
                                netcallOverridePayment.NetcallOverrideId = netcallOverride.Id;
                                payment.NetcallOverridePayments.Add(netcallOverridePayment);
                            }
                        }
                    }

                    atlasDB.Payment.Add(payment);
                    atlasDB.SaveChanges();
                }
                else
                {
                    // couldn't find the previous request
                    accountPaymentResult.Result = "SYSTEM_ERROR";
                }
            }
            else
            {
                // if the PaymentResult wasn't a success it will be logged in the NetcallRequest table so do nothing here
            }

            if (string.IsNullOrEmpty(accountPaymentResult.Result))
            {
                accountPaymentResult.Result = "SUCCESS";
            }
            return accountPaymentResult;
        }


        public NetcallRequest logNetcallRequest(string RequestID, string RequestTime, string CallingNumber, string AppContext, string ClientID, string PaymentResult, string AuthorisationReference)
        {
            var netcallRequest = new NetcallRequest();
            netcallRequest.InCallingNumber = CallingNumber;
            netcallRequest.InClientIdentifier = ClientID;
            DateTime requestDateTime;
            if (!DateTime.TryParseExact(RequestTime, "yyyy-MM-ddThh:mm:ss", CultureInfo.InvariantCulture, DateTimeStyles.None, out requestDateTime))
            {
                requestDateTime = DateTime.Now;
            }
            netcallRequest.InRequestDateTime = requestDateTime;
            netcallRequest.InRequestIdentifier = RequestID;
            netcallRequest.InAppContext = AppContext;
            netcallRequest.InAuthorisationReference = AuthorisationReference;
            netcallRequest.InPaymentResult = PaymentResult;

            atlasDB.NetcallRequests.Add(netcallRequest);
            atlasDB.SaveChanges();

            return netcallRequest;
        }

        public NetcallRequest logNetcallRequest(string RequestID, string RequestTime, string CallingNumber, string AppContext, string ClientID, string DOB)
        {
            var netcallRequest = new NetcallRequest();
            netcallRequest.InCallingNumber = CallingNumber;
            netcallRequest.InClientIdentifier = ClientID;
            netcallRequest.InDateOfBirth = DOB;
            netcallRequest.InRequestIdentifier = RequestID;
            netcallRequest.InAppContext = AppContext;
            DateTime requestDateTime;
            if (!DateTime.TryParseExact(RequestTime, "yyyy-MM-ddThh:mm:ss", CultureInfo.InvariantCulture, DateTimeStyles.None, out requestDateTime))
            {
                requestDateTime = DateTime.Now;
            }
            netcallRequest.InRequestDateTime = requestDateTime;

            atlasDB.NetcallRequests.Add(netcallRequest);
            atlasDB.SaveChanges();

            return netcallRequest;
        }

        public void logNetcallResponse(AccountDetailWithCourseId accountDetailWithCourseId, NetcallRequest netcallRequest)
        {
            netcallRequest.OutClientIdentifier = accountDetailWithCourseId.ClientID;
            netcallRequest.OutCourseVenue = accountDetailWithCourseId.CourseVenue;
            netcallRequest.OutPaymentAmountInPence = accountDetailWithCourseId.AmountToPay;
            netcallRequest.OutResponseDate = DateTime.Now;
            netcallRequest.OutResult = accountDetailWithCourseId.Result;
            netcallRequest.OutResultDescription = accountDetailWithCourseId.ResultDescription;
            netcallRequest.CourseId = accountDetailWithCourseId.CourseId;
            
            var dbEntry = atlasDB.Entry(netcallRequest);
            dbEntry.State = EntityState.Modified;
            atlasDB.SaveChanges();
        }

        public void logNetcallResponse(AccountPaymentResult accountPaymentResult, NetcallRequest netcallRequest)
        {
            netcallRequest.OutResponseDate = DateTime.Now;
            netcallRequest.OutResult = accountPaymentResult.Result;
            netcallRequest.OutResultDescription = accountPaymentResult.ResultDescription;

            var dbEntry = atlasDB.Entry(netcallRequest);
            dbEntry.State = EntityState.Modified;
            atlasDB.SaveChanges();
        }

        public void logNetcallError(string ErrorMessage, string Request, DateTime RequestDate)
        {
            var netcallError = new NetcallErrorLog();
            netcallError.Request = Request;
            netcallError.ErrorMessage = ErrorMessage;
            netcallError.RequestDate = RequestDate;
            netcallError.WarningMessageSentToSupport = false;

            atlasDB.NetcallErrorLogs.Add(netcallError);
            atlasDB.SaveChanges();
        }

        public NetcallClientDetailsJSON GetClientDetails(int ClientId)
        {

            return atlasDB.CourseClients
                .Include("Course.CourseDate")
                .Include("Course.CourseVenue.Venue")
                .Where(
                    client => client.ClientId == ClientId
                )
                .Select(
                    clientDetail => new NetcallClientDetailsJSON
                    {
                        AmountToPay = (clientDetail.TotalPaymentDue == null ? 0 : clientDetail.TotalPaymentDue * 100) - (clientDetail.TotalPaymentMade == null ? 0 : clientDetail.TotalPaymentMade * 100), // Convert to pence
                        ClientId = clientDetail.ClientId,
                        CourseDateTime = clientDetail.Course.CourseDate.FirstOrDefault().DateStart,
                        CourseVenue = clientDetail.Course.CourseVenue.FirstOrDefault().Venue.Title,
                        CourseReference = clientDetail.Course.Reference,
                        Region = clientDetail.Client.ClientOrganisations.FirstOrDefault().Organisation.OrganisationRegion.FirstOrDefault().Region.Name
                    }
                )
                .FirstOrDefault();
        }

        public int CheckRequestId(string RequestId)
        {
            return atlasDB.NetcallRequests
                .Where(
                    request =>
                        request.InSessionIdentifier == RequestId &&
                        request.Method == "GetAccountDetails"
                )
                .ToList()
                .Count();
        }


        public void SaveNetCallRequest (NetcallRequest request)
        {
            atlasDB.NetcallRequests.Add(request);
            atlasDB.SaveChanges();
        }

        public string savePayment (
            int ClientId, 
            DateTime TransactionDate, 
            string TransactionReference
        )
        {

            // Get client details
            var clientDetails = atlasDB.CourseClients
                .Include("Client")
                .Where(
                    client => client.ClientId == ClientId
                )
                .Select(
                    theClient => new NetcallClientPaymentDetail
                    {
                        CourseId = theClient.CourseId,
                        Amount = (theClient.TotalPaymentDue == null ? 0 : theClient.TotalPaymentDue * 100) - (theClient.TotalPaymentMade == null ? 0 : theClient.TotalPaymentMade * 100), // Convert to pence
                        UserId = theClient.Client.UserId,
                        Name = theClient.Client.FirstName + " " + theClient.Client.Surname
                    }
                ).FirstOrDefault();

            // Main Payment 
            var payment = new Payment();

            payment.DateCreated = DateTime.Now;
            payment.TransactionDate = TransactionDate;
            payment.Amount = (decimal) clientDetails.Amount;
            payment.PaymentTypeId = null;
            payment.PaymentMethodId = null;
            payment.ReceiptNumber = "";
            payment.AuthCode = TransactionReference;
            payment.CreatedByUserId = (int) clientDetails.UserId;
            payment.UpdatedByUserId = clientDetails.UserId;
            payment.PaymentName = clientDetails.Name;

            // Add the payment to the payment table
            atlasDB.Payment.Add(payment);

            var courseClientPayment = new CourseClientPayment();
            courseClientPayment.ClientId = ClientId;
            courseClientPayment.Payment = payment;
            courseClientPayment.CourseId = clientDetails.CourseId;

            // Add to the CourseClientPayment table
            atlasDB.CourseClientPayments.Add(courseClientPayment);

            try
            {
                atlasDB.SaveChanges();
            } catch (Exception e) {
                return "Payment can not be saved.";
            }

            return "Payment saved successfully.";
        }

 

    }


    


}