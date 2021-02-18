using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using System.Linq.Dynamic;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.Data;
using System;
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class MysteryShopperController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/mysteryShopper/getAvailableUsers/{organisationId}")]
        [HttpGet]
        public object GetAvailableUsers(int organisationId)
        {
            try
            {
                var availableUsers = atlasDB.Users
                                            .Include(u => u.OrganisationUsers)
                                            .Include(u => u.MysteryShopperAdministrators1)
                                            .Where(u => u.MysteryShopperAdministrators1.Count == 0 && u.OrganisationUsers.Any(ou => ou.OrganisationId == organisationId))
                                            .Select(u => new
                                            {
                                                Id = u.Id,
                                                Name = u.Name
                                            }).ToList();

                return availableUsers;

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists, please contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/mysteryShopper/getMysteryShopperAdministrators/{organisationId}")]
        [HttpGet]
        public object GetMysteryShopperAdministrators(int organisationId)
        {
            try
            {
                var mysteryShopperAdministrators = atlasDB.MysteryShopperAdministrators
                                                        .Include(msa => msa.User1)
                                                        .Include(msa => msa.User1.OrganisationUsers)
                                                        .Where(msa => msa.User1.OrganisationUsers.All(ou => ou.OrganisationId == organisationId))
                                                        .Select(msa => new
                                                        {
                                                            Id = msa.User1.Id,
                                                            Name = msa.User1.Name
                                                        })
                                                        .ToList();
                return mysteryShopperAdministrators;

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists, please contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/mysteryShopper/updateMysteryShopperAdministrators")]
        [HttpPost]
        public object updateMysteryShopperAdministrators([FromBody] FormDataCollection formBody)
        {
            var action = StringTools.GetString("action", ref formBody);
            var userId = StringTools.GetInt("userId", ref formBody);
            var addedByUserId = StringTools.GetInt("addedByUserId", ref formBody);
            var status = "";

            if (action == "add")
            {

                var mysteryShopperAdministrator = new MysteryShopperAdministrator();
                mysteryShopperAdministrator.UserId = userId;
                mysteryShopperAdministrator.AddedByUserId = addedByUserId;
                mysteryShopperAdministrator.DateAdded = DateTime.Now;
                atlasDB.MysteryShopperAdministrators.Add(mysteryShopperAdministrator);
                atlasDB.Entry(mysteryShopperAdministrator).State = EntityState.Added;

            }
            else if (action == "remove")
            {
                var mysteryShopperAdministrators = atlasDB.MysteryShopperAdministrators
                                                            .Where(msa => msa.UserId == userId).FirstOrDefault();

                if (mysteryShopperAdministrators != null)
                {
                    atlasDB.MysteryShopperAdministrators.Remove(mysteryShopperAdministrators);
                    atlasDB.Entry(mysteryShopperAdministrators).State = EntityState.Deleted;
                }
            }

            try
            {
                atlasDB.SaveChanges();
                status = "true";
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists please contact support."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return status;
        }
    }
}


