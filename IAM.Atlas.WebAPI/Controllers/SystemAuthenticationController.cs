using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SystemAuthenticationController : AtlasBaseController
    {
        
        [Route("api/systemauthentication/blockcheck")]
        [HttpGet]
        public bool CheckBlockedIP()
        {
            var clientIp = GetIPAddress();

            return atlasDBViews.vwBlockedIPs
                .Any(theBlockedIP => theBlockedIP.BlockedIp == clientIp
                    && (theBlockedIP.BlockDisabled == null || theBlockedIP.BlockDisabled == false )
                );
        }

        [Route("api/systemauthentication/statuscheck")]
        [HttpGet]
        public object CheckSystemStatus()
        {
            var sysStatus = atlasDBViews.vwSystemStatus
                                    .Select(system => new {
                                        SystemAvailable = system.SystemAvailable,
                                        SystemStatusMessage = system.SystemStatus,
                                        SystemColour = system.SystemStatusColour,
                                        SystemBlockedMessage = system.SystemBlockedMessage,
                                        AtlasSystemName = system.AtlasSystemName,
                                        AtlasSystemCode = system.AtlasSystemCode,
                                        AtlasSystemType = system.AtlasSystemType,
                                        OnlineBookingBlocked = system.OnlineBookingBlocked,
                                        OnlineBookingSystemNoticeOn = system.OnlineBookingSystemNoticeOn,
                                        OnlineBookingSystemNoticeMessage = system.OnlineBookingSystemNoticeMessage,
                                        OnlineBookingSystemNoticeClickHereOn = system.OnlineBookingSystemNoticeClickHereOn,
                                        OnlineBookingSystemNoticeClickHereMessage = system.OnlineBookingSystemNoticeClickHereMessage,
                                        OnlineBookingSystemNoticeClickHereLink = system.OnlineBookingSystemNoticeClickHereLink,
                                        OnlineBookingSystemNoticeColour = system.OnlineBookingSystemNoticeColour
                                    });

            return sysStatus;
        }



        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formParams)
        {

            return "";

        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }
    }
}