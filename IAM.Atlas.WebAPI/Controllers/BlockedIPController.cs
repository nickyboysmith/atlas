using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;
using System.Net.Http;
using System.Net;
using System.Web;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class BlockedIPController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/blockedIP/Get")]
        [HttpGet]
        public object Get()
        {
            var blockedIPs = atlasDB.BlockIPs
                    .Select(ip => new
                    {
                        Id = ip.Id,
                        BlockedIP = ip.BlockedIp,
                        BlockDisabled = ip.BlockDisabled,
                        DateBlocked = ip.DateBlocked
                    }).ToList();

            return blockedIPs;
        }

        [AuthorizationRequired]
        [Route("api/blockedIP/Unblock")]
        [HttpPost]
        public object Unblock([FromBody] FormDataCollection formBody)
        {

            var userId = StringTools.GetInt("userId", ref formBody);

            var blockedIPs = (from fb in formBody
                                 where fb.Key.Contains("blockedIPs")
                                 select new { fb.Key, fb.Value });


            foreach (var IP in blockedIPs)
            {
                BlockIP blockIP = atlasDB.BlockIPs.Find(Int32.Parse(IP.Value));

                if (blockIP == null)
                {
                    //throw new HttpResponseException(
                    //    new HttpResponseMessage(HttpStatusCode.NotFound)
                    //    {
                    //        Content = new StringContent("The email you are tryng to delete does not exist."),
                    //        ReasonPhrase = "Cannot find Email."
                    //    }
                    //);
                }
                else
                {
                    blockIP.BlockDisabled = true;
                    blockIP.BlockDisabledByUserId = userId;

                }
            }
            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return "Success";
        }
    }
}