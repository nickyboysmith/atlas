using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class RefundRequestSearchController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/RefundRequestsearch/find/{OrganisationId}/{RefundRequestType}")]
        [AuthorizationRequired]
        public List<vwRefundRequest> FindRefundRequests(int OrganisationId, string RefundRequestType)
        {
            DateTime? newFromDate = null;

            var showNew = RefundRequestType == "new" ? true : false;
            var showAll = RefundRequestType == "all" ? true : false;
            var showCancelled = RefundRequestType == "cancelled" ? true : false;
            var showCompleted = RefundRequestType == "completed" ? true : false;

            if (showNew == true)
            {
                newFromDate = DateTime.Now.AddHours(-24);
            }

            var RefundRequests = atlasDBViews.vwRefundRequests
                                    .Where(rr =>
                                        (showCompleted == false || showAll == true ? true : rr.RequestCompleted == true) &&
                                        (showCancelled == false || showAll == true ? true : rr.RequestCancelled == true) &&
                                        (showNew == false || showAll == true ? true : rr.RefundRequestDate >= newFromDate)
                                     )
                                    .OrderByDescending(rr => rr.DateCreated)
                                    .ToList();
            return RefundRequests;
        }
    }
}