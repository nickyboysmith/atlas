using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using IAM.Atlas.WebAPI.Models;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Script.Serialization;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity;
using System.Web.Http.ModelBinding;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ClientSearchController : AtlasBaseController
    {
        [HttpPost]
        [Route("api/clientsearch/search")]
        //public List<vwClientDetail> Search([FromBody] FormDataCollection formBody)
        public List<vwClientDetailMinimal> Search([FromBody] FormDataCollection formBody)
        {
            //var clients = new List<vwClientDetail>();
            var clients = new List<vwClientDetailMinimal>();
            var clientSearch = formBody.ReadAs<ClientSearch>();
            //string firstNameSplit = !string.IsNullOrEmpty(clientSearch.name) ? clientSearch.name.Split(' ').FirstOrDefault() : "";
            //string lastNameSplit = !string.IsNullOrEmpty(clientSearch.name) ? clientSearch.name.Split(' ').LastOrDefault() : "";
            var clientId = StringTools.GetInt("clientId", ref formBody);
            var organisationId = StringTools.GetInt("organisationId", ref formBody);
            if (clientSearch.clientMaxRows == 0) clientSearch.clientMaxRows = 200;

            if (
                (clientId > 0)
                || (string.IsNullOrEmpty(clientSearch.name) == false)
                || (string.IsNullOrEmpty(clientSearch.postCode) == false)
                || (string.IsNullOrEmpty(clientSearch.licence) == false)
                || (string.IsNullOrEmpty(clientSearch.reference) == false)
                )
            {
                //clients = atlasDBViews.vwClientDetails
                clients = atlasDBViews.vwClientDetailMinimals
                                        .Where(
                                                cd => (cd.OrganisationId == organisationId) &&
                                                        (clientId > 0 ? cd.ClientId == clientId : true) &&
                                                        (string.IsNullOrEmpty(clientSearch.name) ? true : cd.DisplayName.Contains(clientSearch.name)) &&
                                                        (string.IsNullOrEmpty(clientSearch.postCode) ? true : cd.PostCode.Contains(clientSearch.postCode)) &&
                                                        (string.IsNullOrEmpty(clientSearch.licence) ? true : cd.LicenceNumber.Contains(clientSearch.licence)) &&
                                                        (string.IsNullOrEmpty(clientSearch.reference) ? true : cd.CourseReference.Contains(clientSearch.reference))
                                        )
                                        .OrderByDescending(vwcd => vwcd.ClientCreatedDate)
                                        .Take(clientSearch.clientMaxRows)
                                        .ToList();
            }
            else
            {
                //clients = atlasDBViews.vwClientDetails
                clients = atlasDBViews.vwClientDetailMinimals
                                    .Where(cd => (cd.OrganisationId == organisationId))
                                    .OrderByDescending(vwcd => vwcd.ClientCreatedDate)
                                    .Take(clientSearch.clientMaxRows)
                                    .ToList();
            }
            return clients;
        }

        class ClientSearch
        {
            public string name { get; set; }
            public string licence { get; set; }
            public string postCode { get; set; }
            public string clientClientId { get; set; }
            public int clientMaxRows { get; set; }
            public string reference { get; set; }
            public string clientCompletionStatus { get; set; }
            public string organisationId { get; set; }
        }

        //[AuthorizationRequired]
        //// POST api/<controller>
        //public IEnumerable<ClientSearchJSON> Post([FromBody] FormDataCollection formBody)   // this type passes the JSON data to this webapi controller
        //{
        //    /*             
        //     Search Criteria: 
        //     *string name
        //     *string reference
        //     *string licence
        //     *string postCode
        //     *string clientId
        //     *string completionStatus : All clients, attended, not attended             
             
        //     Output Criteria:
        //     *string Client Name
        //     *string Reference
        //     *string Name (Display Name)
        //     *string Postcode
        //     */
        //    List<ClientSearchJSON> clientsResults = new List<ClientSearchJSON>();

        //    if (formBody != null)
        //    {
        //        var formData = formBody;
        //        //Extract the search criteria
        //        string name = formBody.Get("name") != null ? formBody.Get("name") : "";
        //        string nameFirstPart = name.Split(' ').FirstOrDefault();
        //        string nameLastPart = name.Split(' ').LastOrDefault();
        //        string reference = formBody.Get("reference") != null ? (formBody.Get("reference")).ToLower() : "";
        //        string licence = formBody.Get("licence") != null ? (formBody.Get("licence")).ToLower().Replace(" ", "") : "";
        //        string postCode = formBody.Get("postCode") != null ? (formBody.Get("postCode")).ToLower() : "";
        //        int organisationId = StringTools.GetInt("organisationId", ref formData);
        //        int maxResults = 999;

        //        int clientId = 0;
        //        if (formBody.Get("clientClientId") != null)
        //        {
        //            int.TryParse((formBody.Get("clientClientId")), out clientId);
        //        }

        //        if (formBody.Get("clientMaxRows") != null)
        //        {
        //            if (!int.TryParse((formBody.Get("clientMaxRows")), out maxResults))
        //            {
        //                maxResults = 999;
        //            }
        //        }
        //        string completionStatus = formBody.Get("clientCompletionStatus") != null ? formBody.Get("clientCompletionStatus") : ""; //Course status not possible yet 27/05/2015 Dan Murray

        //        //The search algorythm here will need some re-working at a later stage to cater for fuzzy string matching and multiple locations and licences
        //        //per client as well as Reference and Completion Status

        //        List<Client> clients = new List<Client>();

        //        //Since Licence Numbers and Client Id's are unique these are the first to be checked, if a client is found by ID, other search parameters will be ignored
        //        //The same does not apply for licence number due to the possibility of duplication
        //        if (clientId > 0)
        //        {
        //            clients = atlasDB.Clients
        //                        .Include("ClientLicence")
        //                        .Include("ClientEmails")
        //                        .Include("ClientEmails.Email")
        //                        .Include("ClientLocations")
        //                        .Include("ClientLocations.Location")
        //                        .Include("ClientPhones")
        //                        .Include("ClientPhones.PhoneType")
        //                        //.Include("CourseClients")
        //                        .Include("CourseClients.Course.CourseType")
        //                        .Include(c => c.ClientOrganisations)
        //                        .Where(c => c.Id == clientId && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                        .Take(maxResults).ToList();
        //        }

        //        if (clients.Count < 1 && licence != "")
        //        {
        //            clients = atlasDB.Clients
        //                        .Include("ClientLicences")
        //                        .Include("ClientEmails")
        //                        .Include("ClientEmails.Email")
        //                        .Include("ClientLocations")
        //                        .Include("ClientLocations.Location")
        //                        .Include("ClientPhones")
        //                        .Include("ClientPhones.PhoneType")
        //                        .Include("CourseClients.Course.CourseType")
        //                        .Include(c => c.ClientOrganisations)
        //                        .Where(c => c.ClientLicences.Any(a => a.LicenceNumber.ToLower().Replace(" ", "") == licence.ToLower().Replace(" ", "")) && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                        .Take(maxResults).ToList();
        //        }

        //        if (clients.Count < 1 && postCode != "")
        //        {
        //            clients = atlasDB.Clients
        //                        .Include("ClientLicences")
        //                        .Include("ClientEmails")
        //                        .Include("ClientEmails.Email")
        //                        .Include("ClientLocations")
        //                        .Include("ClientLocations.Location")
        //                        .Include("ClientPhones")
        //                        .Include("ClientPhones.PhoneType")
        //                        .Include("CourseClients.Course.CourseType")
        //                        .Include(c => c.ClientOrganisations)
        //                        .Where(c => c.ClientLocations.Any(a => a.Location.PostCode.ToLower().Replace(" ", "") == postCode.ToLower().Replace(" ", "")) && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                        .Take(maxResults).ToList();
        //        }

        //        if (clients.Count < 1 && (nameFirstPart != "" || nameLastPart != ""))
        //        {
        //            if (nameFirstPart == nameLastPart)
        //            {
        //                clients = atlasDB.Clients
        //                            .Include("ClientLicence")
        //                            .Include("ClientEmails")
        //                            .Include("ClientEmails.Email")
        //                            .Include("ClientLocations")
        //                            .Include("ClientLocations.Location")
        //                            .Include("ClientPhones")
        //                            .Include("ClientPhones.PhoneType")
        //                            .Include("CourseClients.Course.CourseType")
        //                            .Include(c => c.ClientOrganisations)
        //                            .Where(c => (c.FirstName.ToLower().Contains(nameFirstPart) || c.Surname.ToLower().Contains(nameLastPart)) && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                            .Take(maxResults).ToList();
        //            }
        //            else
        //            {
        //                clients = atlasDB.Clients
        //                    .Include("ClientLicence")
        //                    .Include("ClientEmails")
        //                    .Include("ClientEmails.Email")
        //                    .Include("ClientLocations")
        //                    .Include("ClientLocations.Location")
        //                    .Include("ClientPhones")
        //                    .Include("ClientPhones.PhoneType")
        //                    .Include("CourseClients.Course.CourseType")
        //                    .Include(c => c.ClientOrganisations)
        //                    .Where(c => c.FirstName.ToLower().Contains(nameFirstPart) && c.Surname.ToLower().Contains(nameLastPart) && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                    .Take(maxResults).ToList();
        //            }
        //        }
        //        // if a blank search return all clients
        //        if (clients.Count == 0 && String.IsNullOrEmpty(name) && String.IsNullOrEmpty(reference) && String.IsNullOrEmpty(licence) && String.IsNullOrEmpty(postCode))
        //        {
        //            switch (completionStatus)
        //            {
        //                case "attended":
        //                    clients = atlasDB.Clients
        //                                .Include("ClientLicences")
        //                                .Include("ClientEmails")
        //                                .Include("ClientEmails.Email")
        //                                .Include("ClientLocations")
        //                                .Include("ClientLocations.Location")
        //                                .Include("ClientPhones")
        //                                .Include("ClientPhones.PhoneType")
        //                                .Include("CourseClients.Course.CourseType")
        //                                .Include(c => c.ClientOrganisations)
        //                                .Where(c => c.CourseClients.Any() && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                                .OrderByDescending(c => c.Id)
        //                                .Take(maxResults).ToList();
        //                    break;
        //                case "notattended":
        //                    clients = atlasDB.Clients
        //                                .Include("ClientLicences")
        //                                .Include("ClientEmails")
        //                                .Include("ClientEmails.Email")
        //                                .Include("ClientLocations")
        //                                .Include("ClientLocations.Location")
        //                                .Include("ClientPhones")
        //                                .Include("ClientPhones.PhoneType")
        //                                .Include("CourseClients.Course.CourseType")
        //                                .Include(c => c.ClientOrganisations)
        //                                .Where(c => !c.CourseClients.Any() && c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                                .OrderByDescending(c => c.Id)
        //                                .Take(maxResults).ToList();
        //                    break;
        //                default:    // return all
        //                    clients = atlasDB.Clients
        //                                .Include("ClientLicences")
        //                                .Include("ClientEmails")
        //                                .Include("ClientEmails.Email")
        //                                .Include("ClientLocations")
        //                                .Include("ClientLocations.Location")
        //                                .Include("ClientPhones")
        //                                .Include("ClientPhones.PhoneType")
        //                                .Include("CourseClients.Course.CourseType")
        //                                .Include(c => c.ClientOrganisations)
        //                                .Where(c => c.ClientOrganisations.Any(co => co.OrganisationId == organisationId))
        //                                .OrderByDescending(c => c.Id)
        //                                .Take(maxResults).ToList();
        //                    break;
        //            }
        //        }

        //        if (clients.Count > 0)
        //        {
        //            clientsResults = clients
        //                .Select(c => new ClientSearchJSON
        //                {
        //                    clientId = c.Id.ToString(),
        //                    clientName = c.FirstName + " " + c.Surname,
        //                    reference = "N/A",
        //                    courseType = c.CourseClients.LastOrDefault() != null ? (string)c.CourseClients.LastOrDefault().Course.CourseType.Description : "N/A",
        //                    displayName = c.DisplayName,
        //                    postcode = c.ClientLocations.LastOrDefault() != null ? (string)c.ClientLocations.LastOrDefault().Location.PostCode : "N/A",
        //                    locked = c.Locked ?? false
        //                }).ToList();
        //        }
        //    }
        //    return clientsResults;
        //}

        [HttpPost]
        [Route("api/clientsearch/SearchViewedClients")]
        public List<vwUsersClientDetail> SearchViewedClients([FromBody] FormDataCollection formBody)
        {
            var clients = new List<vwUsersClientDetail>();
            var clientSearch = formBody.ReadAs<ClientSearch>();
            var userId = StringTools.GetInt("userId", ref formBody);
            var clientId = StringTools.GetInt("clientId", ref formBody);
            var organisationId = StringTools.GetInt("organisationId", ref formBody);
            if (clientSearch.clientMaxRows == 0) clientSearch.clientMaxRows = 200;

            if (
                (clientId > 0)
                || (string.IsNullOrEmpty(clientSearch.name) == false)
                || (string.IsNullOrEmpty(clientSearch.postCode) == false)
                || (string.IsNullOrEmpty(clientSearch.licence) == false)
                || (string.IsNullOrEmpty(clientSearch.reference) == false)
                )
            {
                clients = atlasDBViews.vwUsersClientDetails
                                        .Where(
                                                ucd => (ucd.OrganisationId == organisationId) &&
                                                        (ucd.UserId == userId) &&
                                                        (clientId > 0 ? ucd.ClientId == clientId : true) &&
                                                        (string.IsNullOrEmpty(clientSearch.name) ? true : ucd.DisplayName.Contains(clientSearch.name)) &&
                                                        (string.IsNullOrEmpty(clientSearch.postCode) ? true : ucd.PostCode.Contains(clientSearch.postCode)) &&
                                                        (string.IsNullOrEmpty(clientSearch.licence) ? true : ucd.LicenceNumber.Contains(clientSearch.licence)) &&
                                                        (string.IsNullOrEmpty(clientSearch.reference) ? true : ucd.CourseReference.Contains(clientSearch.reference))
                                        )
                                        .OrderByDescending(ucd => ucd.DateUserLastViewedClient)
                                        .Take(clientSearch.clientMaxRows)
                                        .ToList();
            }
            else
            {
                clients = atlasDBViews.vwUsersClientDetails
                                        .Where(ucd => (ucd.OrganisationId == organisationId))
                                        .OrderByDescending(ucd => ucd.DateUserLastViewedClient)
                                        .Take(clientSearch.clientMaxRows)
                                        .ToList();
            }

            return clients;
        }
    }
}