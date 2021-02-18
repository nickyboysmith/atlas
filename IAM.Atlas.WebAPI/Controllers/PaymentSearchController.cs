using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class PaymentSearchController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/paymentsearch/find/{OrganisationId}/{TypeId}/{MethodId}/{PaymentPeriod}/{PaymentOrRefund}")]
        [AuthorizationRequired]
        public List<vwPaymentDetail> FindPayments(int OrganisationId, int TypeId, int MethodId, string PaymentPeriod, string PaymentOrRefund)
        {
            var showBothPaymentsAndRefunds = PaymentOrRefund == "all" || PaymentOrRefund == "payment" ? true : false;
            var showOnlyRefunds = PaymentOrRefund == "refund" ? true : false;
            var showOnlyUnallocated = PaymentOrRefund == "payment" ? true : false;

            var todaysPayments = PaymentPeriod == "Today's Payments";
            var yesterdaysPayments = PaymentPeriod == "Yesterday's Payments";
            var thisWeeksPayments = PaymentPeriod == "This Week's Payments";
            var thisMonthsPayments = PaymentPeriod == "This Month's Payments";
            var previousMonthsPayments = PaymentPeriod == "The Previous Month's Payments";
            var twoMonthsAgoPayments = PaymentPeriod == "Payments Two Months Ago";
            var thisYearsPayments = PaymentPeriod == "This Year's Payments";
            var previousYearsPayments = PaymentPeriod == "The Previous Year's Payments";

            var payments = atlasDBViews.vwPaymentDetails
                                    .Where(pd =>    pd.OrganisationId == OrganisationId &&
                                                    (TypeId == -1 ? true : pd.PaymentTypeId == TypeId) &&
                                                    (MethodId == -1 ? true : pd.PaymentMethodId == MethodId) &&
                                                    (showBothPaymentsAndRefunds == true ? true : pd.RefundPayment == showOnlyRefunds) &&
                                                    (todaysPayments == true ? pd.PaymentsToday == true : true) &&
                                                    (yesterdaysPayments == true ? pd.PaymentsYesterday == true : true) &&
                                                    (thisWeeksPayments == true ? pd.PaymentsThisWeek == true : true) &&
                                                    (thisMonthsPayments == true ? pd.PaymentsThisMonth == true : true) &&
                                                    (previousMonthsPayments == true ? pd.PaymentsPreviousMonth == true : true) &&
                                                    (twoMonthsAgoPayments == true ? pd.PaymentsTwoMonthsAgo == true : true) &&
                                                    (thisYearsPayments == true ? pd.PaymentsThisYear == true : true) && 
                                                    (previousYearsPayments == true ? pd.PaymentsPreviousYear == true : true) &&
                                                    (showOnlyUnallocated == false ? true : pd.PaymentUnallocatedToClient == true)
                                    )
                                    .OrderByDescending(pd => pd.DateCreated)
                                    .ToList();
            return payments;
        }
    }
}
