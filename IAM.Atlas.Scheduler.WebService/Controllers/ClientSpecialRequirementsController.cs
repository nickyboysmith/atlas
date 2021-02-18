using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using System.Data.Entity;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{
    public class XClientSpecialRequirementsController : XBaseController
    {
        [HttpGet]
        [Route("api/ClientSpecialRequirements/SendClientSpecialRequirementsOutstandingNotification")]

        public bool SendClientSpecialRequirementsOutstandingNotification()
        {
            var errorMessage = new StringBuilder();
            var itemName = "SendClientSpecialRequirementsOutstandingNotification";

            // Get List Of SpecialRequirements to Notify
            var vwClientSpecialRequirementsOutstandingNotifications = atlasDBViews.vwClientSpecialRequirementsOutstandingNotifications.ToList();

            foreach (var clientSpecialRequirement in vwClientSpecialRequirementsOutstandingNotifications)
            {

                //var OrganisationId = clientSpecialRequirement.OrganisationId;

                // Get List of Support Users to Email
                //var systemSupportUsers = atlasDB.SystemSupportUsers
                //                                .Include(ssu => ssu.User)
                //                                .Where(ssu => ssu.OrganisationId == OrganisationId)
                //                                .Select (u => new
                //                                {
                //                                    Name = u.User.Name,
                //                                    Email = u.User.Email
                //                                }).ToList();

                //foreach (var systemSupportUser in systemSupportUsers)
                //{
                //    if (systemSupportUser.Name != null || systemSupportUser.Email != null)
                //    {
                    try
                    {
                        var OrganisationId = clientSpecialRequirement.OrganisationId;
                        var ClientId = clientSpecialRequirement.ClientId;
                        var ClientDisplayName = clientSpecialRequirement.ClientName;
                        var SpecialRequirements = clientSpecialRequirement.AdditionalRequirementsList;

                        atlasDB.uspSendClientSpecialRequirementsOutstandingNotification(OrganisationId, ClientId, ClientDisplayName, SpecialRequirements);
                    
                    }
                    catch (Exception ex)
                    {
                        errorMessage.AppendLine(string.Format("Unable to run uspSendClientSpecialRequirementsOutstandingNotification for Client Id {0}. Error {1}", clientSpecialRequirement.ClientId, ex.Message));
                    }
                    finally
                    {
                        if (errorMessage != null && errorMessage.Length > 0)
                        {
                            CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
                            atlasDB.SaveChanges();
                        }
                    }
                        
                //    }
                //}
            }
            return true;
        }
    }
}
