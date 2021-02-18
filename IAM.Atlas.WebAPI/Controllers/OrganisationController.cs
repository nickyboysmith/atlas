using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Data.Entity;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.WebAPI.Models;
using System.Net.Http.Formatting;
using IAM.Atlas.WebAPI.Classes;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class OrganisationController : AtlasBaseController
    {
        public object Get()
        {
            return atlasDB.Organisations.Select(o => new { o.Id, o.Name }).ToList();
        }


        // GET api/<controller>/5
        public Data.Organisation Get(int Id)
        {
            return atlasDB.Organisations.Where(o => o.Id == Id).FirstOrDefault();
        }

        // Get organisations and their contact details that facilitate a particular DORS Scheme Id
        [Route("api/Organisation/GetDorsOrganisationContactsWithAvailableCourses/{dorsSchemeIdentifier}")]
        [HttpGet]
        public object GetDorsOrganisationContactsWithAvailableCourses(int dorsSchemeIdentifier)
        {
            List<OrganisationContact> contactList = new List<OrganisationContact>();

            if (dorsSchemeIdentifier > 0)
            {
                contactList = atlasDBViews.vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegionByDORSSchemeIdentifiers
                .Where(x => x.DORSSchemeIdentifier == dorsSchemeIdentifier
                    && (x.OrganisationAddress != null || x.OrganisationEmailAddress != null || x.OrganisationPhoneNumber != null))
                .Select(e => new OrganisationContact
                {
                    Area = e.RegionName,
                    OrganisationName = e.OrganisationName,
                    OrganisationId = e.OrganisationId.ToString(),
                    OrganisationAddress = e.OrganisationAddress,
                    OrganisationPostCode = e.OrganisationPostCode,
                    OrganisationEmail = e.OrganisationEmailAddress,
                    OrganisationPhone = e.OrganisationPhoneNumber,
                    CourseTypeId = e.CourseTypeId,
                    RegionId = e.RegionId
                })
                .ToList();
                return contactList;
            }
            else
            {
                return contactList;
            }
        }

        // Get organisations and their contact details that facilitate a particular DORS Scheme Id
        [Route("api/Organisation/GetDorsOrganisationContacts/{dorsSchemeIdentifier}")]
        [HttpGet]
        public object GetDorsOrganisationContacts(int dorsSchemeIdentifier)
        {
            List<OrganisationContact> contactList = new List<OrganisationContact>();

            //If a non zero id is passed in get the contact details for that organisation
            if (dorsSchemeIdentifier > 0)
            {
                var schemeOrganisationOptions = atlasDB.DORSSchemeCourseTypes
                    .Include("DORSScheme")
                    .Include("CourseType")
                    .Where(x => x.DORSScheme.DORSSchemeIdentifier == dorsSchemeIdentifier);

                foreach (var schemeOrganisationOption in schemeOrganisationOptions)
                {
                    contactList.AddRange(this.GetOrganisationContacts(schemeOrganisationOption.CourseType.OrganisationId, schemeOrganisationOption.CourseType.Id));
                }

                return contactList;
            }
            else
            {
                return contactList;
            }
        }

        // Get organisations and their contact details
        [Route("api/Organisation/GetContacts/{organisationId}")]
        [HttpGet]
        public object GetContacts(int organisationId)
        {
            //If a non zero id is passed in get the contact details for that organisation
            if (organisationId > 0)
            {
                return this.GetOrganisationContacts(organisationId);
            }
            //Otherwise get the contact details for all organisations in the system that are not management organisations
            //'OrganisationManagements1' refers to organisations on the OrganisationManagements table that are identified as the 
            //managing organisation, not the root organisation.
            else
            {
                List<OrganisationContact> contactList = new List<OrganisationContact>();

                //foreach (var organisation in atlasDB.Organisations.Where(x => x.OrganisationManagements1.Count() < 1))
                foreach (var organisation in atlasDBViews.vwOrganisationDetails.Where(x => x.IsManagingOrganisation == false
                                                                                            && x.HasContactInformation == true
                                                                                        ))
                {
                    contactList.AddRange(this.GetOrganisationContacts(organisation.OrganisationId));
                }
                return contactList;
            }
        }

        private List<OrganisationContact> GetOrganisationContacts(int organisationId, int courseTypeId = -1)
        {
            //Get all organisation management organisations for a given organisation
            //if there are none (i.e.. no entries on the OrganisationManagement table), 
            //simply use the contact details for the root organisation

            var singleOrganisationContacts = atlasDB.OrganisationManagements
                .Include("Organisation")
                .Include("Organisation.OrganisationRegion")
                .Include("Organisation.OrganisationRegion.Region")
                .Include("Organisation.OrganisationContacts")
                .Include("Organisation.OrganisationContacts.Location")
                .Where(
                    x => organisationId > 0 ? x.Id == organisationId : true
                    && x.Organisation.OrganisationContacts.FirstOrDefault() != null
                    )
                .Select(e => new OrganisationContact
                {
                    //Note that 'Organisation' refers to the root organisation whilst 'Organisation1' refers to the organisation as a management contact
                    Area = e.Organisation.OrganisationRegion.FirstOrDefault().Region.Name,
                    OrganisationName = e.Organisation1.Name,
                    OrganisationId = e.Organisation1.Id.ToString(),
                    OrganisationAddress = e.Organisation1.OrganisationContacts.FirstOrDefault().Location.Address,
                    OrganisationPostCode = e.Organisation1.OrganisationContacts.FirstOrDefault().Location.PostCode,
                    OrganisationEmail = e.Organisation1.OrganisationContacts.FirstOrDefault().Email.Address,
                    OrganisationPhone = e.Organisation1.OrganisationContacts.FirstOrDefault().PhoneNumber,
                    CourseTypeId = courseTypeId
                })
                .ToList();

            if (singleOrganisationContacts.Count() < 1)
            {
                singleOrganisationContacts = atlasDB.Organisations
                .Include("OrganisationRegion")
                .Include("OrganisationRegion.Region")
                .Include("OrganisationContacts")
                .Include("OrganisationContacts.Location")
                .Include("OrganisationManagement")
                .Include("OrganisationManagement.Organisation")
                .Where(
                    x => organisationId > 0 ? x.Id == organisationId : true
                    && x.OrganisationContacts.FirstOrDefault() != null
                    )
                .Select(o => new OrganisationContact
                {
                    Area = o.OrganisationRegion.FirstOrDefault().Region.Name,
                    OrganisationName = o.Name,
                    OrganisationId = o.Id.ToString(),
                    OrganisationAddress = o.OrganisationContacts.FirstOrDefault().Location.Address,
                    OrganisationPostCode = o.OrganisationContacts.FirstOrDefault().Location.PostCode,
                    OrganisationEmail = o.OrganisationContacts.FirstOrDefault().Email.Address,
                    OrganisationPhone = o.OrganisationContacts.FirstOrDefault().PhoneNumber,
                    CourseTypeId = courseTypeId
                })
                .ToList();
            }
            //Filter out organisations which have no valid contact information
            var filteredContactList = new List<OrganisationContact>();
            foreach (var contact in singleOrganisationContacts)
            {
                if (!string.IsNullOrWhiteSpace(contact.OrganisationAddress)
                    || !string.IsNullOrWhiteSpace(contact.OrganisationEmail)
                    || !string.IsNullOrWhiteSpace(contact.OrganisationPhone))
                {
                    filteredContactList.Add(contact);
                }
            }
            singleOrganisationContacts = filteredContactList;


            return singleOrganisationContacts;
        }

        // Get organisations and their contact details
        [Route("api/Organisation/GetOrganisationContent/{organisationName}")]
        [HttpGet]
        public object GetOrganisationContent(string organisationName)
        {
            //Filter for erroneous content
            if (Regex.IsMatch(organisationName, "[-_:;./{1,}]"))
            {
                //Wait a moment - THAT'S not an organisation name! Exit this funny business!
                return "";
            }

            var result = atlasDB.Organisations
                .Include("OrganisationSystemConfiguration")
                .Include("OrganisationDisplay")
                .Include("OrganisationSelfConfiguration")
                .Where(x => x.Name.ToLower().Replace(" ", "") == organisationName.ToLower().Replace(" ", ""))
                .Select(o => new
                {
                    OrganisationId = o.Id,
                    DisplayName = o.OrganisationDisplay.FirstOrDefault().DisplayName,
                    ApplicationDescription = o.OrganisationSelfConfigurations.FirstOrDefault().ClientApplicationDescription,
                    WelcomeMessage = o.OrganisationSelfConfigurations.FirstOrDefault().ClientWelcomeMessage
                })
                 .ToList();
            return result;
        }

        // GET api/<controller>/5
        [Route("api/Organisation/GetByUser/{userId}")]
        public IEnumerable<Models.Organisation> GetByUser(int userId)
        {
            //If a user is a system administrator return all organisations ie. ignore user organisations
            if (atlasDB.SystemAdminUsers.Where(x => x.UserId == userId).Count() > 0)
            {
                //return atlasDB.Organisations.Select(ou => new Models.Organisation { id = ou.Id, name = ou.Name }).ToList();
                return atlasDBViews.vwOrganisationDetails
                            .Select(ou => new Models.Organisation { id = ou.OrganisationId, name = ou.OrganisationDisplayName }).ToList();
            }
            else
            {
                //...otherwise return the organisations to which they are associated.
                //return atlasDB.Organisations.Join(atlasDB.OrganisationUsers,
                //                                    organisation => organisation.Id,
                //                                    user => user.OrganisationId,
                //                                    (organisation, user) => new { Org = organisation, User = user })
                //                            .Where(ou => ou.User.UserId == userId)  //ou refers to the new org, user couplet in the above line
                //                            .Select(ou => new Models.Organisation { id = ou.Org.Id, name = ou.Org.Name }).ToList();


                //return atlasDBViews.vwOrganisationDetails
                //            .Join(atlasDB.OrganisationUsers,
                //                                    organisation => organisation.OrganisationId,
                //                                    user => user.OrganisationId,
                //                                    (organisation, user) => new { Org = organisation, User = user })
                //                            .Where(ou => ou.User.UserId == userId)
                //                            .Select(ou => new Models.Organisation { id = ou.Org.OrganisationId, name = ou.Org.OrganisationDisplayName }).ToList();


                return atlasDBViews.vwOrganisationDetailByOrganisationUsers
                                    .Where(ou => ou.UserId == userId)
                                    .Select(ou => new Models.Organisation { id = ou.OrganisationId, name = ou.OrganisationDisplayName })
                                    .ToList();

            }
        }

        // Create a new Organisation
        [Route("api/Organisation/Add")]
        [HttpPost]
        public void Add([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;
            var OrganisationName = StringTools.GetString("Name", ref formData);
            var CreatedByUserId = StringTools.GetInt("CreatedByUserId", ref formData);

            Data.Organisation organisation = new Data.Organisation();
            organisation.Name = OrganisationName;
            organisation.Active = false;
            organisation.CreationTime = DateTime.Now;
            organisation.CreatedByUserId = CreatedByUserId;

            atlasDB.Organisations.Add(organisation);
            
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
        }

        // GET api/<controller>/5
        [Route("api/Organisation/GetRegions/{orgId}")]
        [HttpGet]
        [AuthorizationRequired]
        public object GetRegions(int orgId)
        {
            var regions = atlasDB.OrganisationRegion
                          .Include("Region")
                          .Where(x => x.OrganisationId == orgId)
                          .Select
                          (y => new
                          {
                              id = y.Region.Id,
                              name = y.Region.Name
                          });
            return regions;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/Organisation/DownloadDocument/{Id}/{UserId}/{OrganisationId}/{UserSelectedOrganisationId}/{DocumentName}")]
        public HttpResponseMessage DownloadDocument(int Id, int UserId, int OrganisationId, int UserSelectedOrganisationId, string DocumentName)
        {
            HttpResponseMessage response = null;

            if (!this.UserMatchesToken(UserId, Request))
            {
                return response;
            }

            if (!this.UserHasOrganisationUserStatus(UserId, UserSelectedOrganisationId) && !this.UserHasSystemAdminStatus(UserId))
            {
                return response;
            }

            //Confirm that the document relates to the organisation
            var organisationDocument = atlasDB.DocumentOwners
                                                .Where(docOwner => docOwner.DocumentId == Id && docOwner.OrganisationId == UserSelectedOrganisationId)
                                                .FirstOrDefault();

            if (organisationDocument != null)
            {
                var documentController = new DocumentController();
                var documentId = organisationDocument.DocumentId;
                if (documentId > 0)
                {
                    response = documentController.DownloadFileContents((int)documentId, UserId, DocumentName);
                }
            }
            return response;
        }

        // POST api/<controller>
        public void Post([FromBody]string value)
        {
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }

        public class OrganisationContact
        {
            public string Area { get; set; }
            public string OrganisationId { get; set; }
            public string OrganisationName { get; set; }
            public string OrganisationAddress { get; set; }
            public string OrganisationPostCode { get; set; }
            public string OrganisationEmail { get; set; }
            public string OrganisationPhone { get; set; }
            public int CourseTypeId { get; set; }
            public int RegionId { get; set; }
        }
    }
}