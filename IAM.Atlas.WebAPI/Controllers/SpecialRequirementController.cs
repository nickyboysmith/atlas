using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SpecialRequirementController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/SpecialRequirement/{ClientId}/{OrganisationId}")]
        public object Get(int ClientId, int OrganisationId)
        {
            return atlasDB.ClientSpecialRequirements
                .Include("SpecialRequirement")
                .Where(
                    requirement => 
                        requirement.ClientId == ClientId &&
                        requirement.SpecialRequirement.OrganisationId == OrganisationId
                )
                .Select(
                    special => new
                    {
                        ClientSpecialRequirementId = special.Id,
                        special.SpecialRequirement.Id,
                        special.SpecialRequirement.Name,
                        special.SpecialRequirement.Description
                    }
                )
                .ToList();
        }

        [AuthorizationRequired]
        [Route("api/SpecialRequirement/Organisation/{ClientId}/{OrganisationId}")]
        public object GetOrganisationSpecialRequirements(int ClientId, int OrganisationId)
        {
            return atlasDB.SpecialRequirements
                .Include("ClientSpecialRequirements")
                .Where(
                    requirement =>
                        requirement.OrganisationId == OrganisationId &&
                        (!requirement.ClientSpecialRequirements.Any(
                            client => client.ClientId == ClientId
                        ))
                )
                .Select(
                    special => new
                    {
                        special.Id,
                        special.Name,
                        special.Description,
                        special.Disabled
                    }
                )
                .ToList();
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/SpecialRequirement/AddRequirement")]
        public object AddRequirement([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var requirementTitle = StringTools.GetStringOrFail("NewTitle", ref formData, "Please enter a valid Name");
            var requirementDescription = StringTools.GetStringOrFail("NewDescription", ref formData, "Please enter a valid Description");
            var userId = StringTools.GetInt("UserId", ref formBody);

            try
            {
                var requirement = new SpecialRequirement();
                requirement.OrganisationId = OrganisationId;
                requirement.Description = requirementDescription;
                requirement.Name = requirementTitle;
                requirement.DateCreated = DateTime.Now;
                requirement.CreatedByUserID = userId;
                requirement.Disabled = false;
                atlasDB.SpecialRequirements.Add(requirement);
                atlasDB.SaveChanges();
                return requirement.Id.ToString();
            }
            catch (Exception ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists please contact Support."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/SpecialRequirement/UpdateRequirement")]
        public object UpdateRequirement([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            var requirementId = StringTools.GetInt("Id", ref formData);
            var requirementDescription = StringTools.GetString("Description", ref formData);
            var requirementDisabled = StringTools.GetBool("Disabled", ref formData);
            var userId = StringTools.GetIntOrFail("UserId", ref formData, "Not a valid user");

            try
            {
                var requirement = atlasDB.SpecialRequirements
                                         .Where(x => x.Id == requirementId)
                                         .First();
                requirement.Description = requirementDescription;
                requirement.Disabled = requirementDisabled;
                requirement.DateUpdated = DateTime.Now;
                requirement.UpdatedByUserId = userId;
                atlasDB.SaveChanges();
                return "Updated";
            }
            catch (Exception ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists please contact Support."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/SpecialRequirement/GetByOrganisation/{OrganisationId}")]
        public object GetByOrganisationSpecialRequirements(int OrganisationId)
        {
            return atlasDB.SpecialRequirements
                .Where(
                    requirement =>
                        requirement.OrganisationId == OrganisationId
                )
                .ToList();
        }

        [AuthorizationRequired]
        public object Post([FromBody] FormDataCollection formBody)
        {
            var action = StringTools.GetStringOrFail("action", ref formBody, "We need an action to process this request");
            var clientId = StringTools.GetIntOrFail("clientId", ref formBody, "You need a valid client associated");
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "You need a valid organisation associated");

            try
            {
                if (action == "add")
                {
                    var specialRequirementId = StringTools.GetIntOrFail("specialRequirementId", ref formBody, "Special requirement needs to be associated.");
                    var userId = StringTools.GetIntOrFail("userId", ref formBody, "User needs to be assocaiated");

                    ClientSpecialRequirement clientSpecialRequirement = new ClientSpecialRequirement();
                    clientSpecialRequirement.SpecialRequirementId = specialRequirementId;
                    clientSpecialRequirement.DateAdded = DateTime.Now;
                    clientSpecialRequirement.ClientId = clientId;
                    clientSpecialRequirement.AddByUserId = userId;

                    atlasDB.ClientSpecialRequirements.Add(clientSpecialRequirement);

                } else if (action == "remove") {

                    var clientSpecialRequirementId = StringTools.GetIntOrFail("clientSpecialRequirementId", ref formBody, "A special requirement needs to be associated");
                    var existingClientSpecialRequirement = atlasDB.ClientSpecialRequirements.Find(clientSpecialRequirementId);
                    var requirementToDelete = atlasDB.Entry(existingClientSpecialRequirement);
                    requirementToDelete.State = EntityState.Deleted;

                } else {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("There was error your request. Please retry. If the problem persists! Contact support!"),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }

                atlasDB.SaveChanges();

                return "Updated";

            } catch (DbEntityValidationException ex) {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            } catch (Exception ex) {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [Route("api/SpecialRequirement/Add")]
        [HttpPost]
        public object AddSpecialRequirement([FromBody] FormDataCollection formBody)
        {
            var organisationId = StringTools.GetIntOrFail("OrganisationId", ref formBody, "An organisation nedds to be associated.");
            var requirementName = StringTools.GetStringOrFail("Name", ref formBody, "You need to have a name for the special requirement.");
            var requirementDescription = StringTools.GetStringOrFail("Description", ref formBody, "You need to enter a description for the special requirement.");
            var userId = StringTools.GetIntOrFail("UserId", ref formBody, "Not a valid user");

            try
            {
                SpecialRequirement specialRequirement = new SpecialRequirement();
                specialRequirement.Name = requirementName;
                specialRequirement.Description = requirementDescription;
                specialRequirement.Disabled = false;
                specialRequirement.DateCreated = DateTime.Now;
                specialRequirement.CreatedByUserID = userId;
                specialRequirement.OrganisationId = organisationId;

                atlasDB.SpecialRequirements.Add(specialRequirement);

                atlasDB.SaveChanges();

                return "added";
            } catch (DbEntityValidationException ex) { 
             
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            } catch (Exception ex) {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

        }
        
    }
}