using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Data.Entity;
using System.Net.Http.Formatting;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ReferringAuthorityController : AtlasBaseController
    {


        [AuthorizationRequired]
        [Route("api/referringauthority/Get")]
        public object Get()
        {
            var referringAuthorities = atlasDB.ReferringAuthorities.ToList();
            return referringAuthorities;
        }




        [AuthorizationRequired]
        [Route("api/referringauthority/GetByOrganisation/{organisationId}")]
        /// <summary>
        /// Gets an organisation's referring authorities
        /// </summary>
        /// <param name="organisationId">The organisations Id</param>
        /// <returns>Returns a list of all the Referring Authorities</returns>
        public List<ReferringAuthority> GetByOrganisation(int organisationId)
        {
            var referringAuthorities = new List<ReferringAuthority>();
            referringAuthorities = atlasDB.ReferringAuthorities
                                            .Include(ra => ra.ReferringAuthorityContracts)
                                            .Where(ra => ra.ReferringAuthorityContracts.Any(rac => rac.ContractedOrganisationId == organisationId))
                                            .ToList();
            return referringAuthorities;
        }


        [AuthorizationRequired]
        [Route("api/referringauthority/GetAuthority/{organisationId}")]
        /// <summary>
        /// Gets an organisation's referring authorities
        /// </summary>
        /// <param name="organisationId">The organisations Id</param>
        /// <returns>Returns a list of all the Referring Authorities</returns>
        public ReferringAuthorityResult GetAuthority(int organisationId)
        {
            var referringAuthorities = atlasDB.ReferringAuthorities
                                            .Include(ra => ra.ReferringAuthorityContracts)
                                            .Where(ra => ra.AssociatedOrganisationId == organisationId)
                                            .FirstOrDefault();
            if (referringAuthorities != null)
            {
                ReferringAuthorityResult referringAuthority = new ReferringAuthorityResult
                {
                    Id = referringAuthorities.Id,
                    Name = referringAuthorities.Name,
                    AssociatedOrganisationId = referringAuthorities.AssociatedOrganisationId != null ? (int)referringAuthorities.AssociatedOrganisationId : 0,
                    Description = referringAuthorities.Description,
                    Disabled = referringAuthorities.Disabled != null ? (bool)referringAuthorities.Disabled : false,
                    Reference = referringAuthorities.ReferringAuthorityContracts.ToList().LastOrDefault() != null ? referringAuthorities.ReferringAuthorityContracts.ToList().LastOrDefault().Reference : "",
                    EndDate = referringAuthorities.ReferringAuthorityContracts.ToList().LastOrDefault() != null ? referringAuthorities.ReferringAuthorityContracts.ToList().LastOrDefault().EndDate.HasValue ? referringAuthorities.ReferringAuthorityContracts.FirstOrDefault().EndDate.Value.Date.ToString("dd/MM/yyyy") : "" : "",
                    StartDate = referringAuthorities.ReferringAuthorityContracts.ToList().LastOrDefault() != null ? referringAuthorities.ReferringAuthorityContracts.ToList().LastOrDefault().StartDate.HasValue ? referringAuthorities.ReferringAuthorityContracts.FirstOrDefault().StartDate.Value.Date.ToString("dd/MM/yyyy") : "" : ""
                };
                return referringAuthority;
            }
            else return new ReferringAuthorityResult();
        }


        [AuthorizationRequired]
        [HttpPost]
        [Route("api/referringauthority/saveauthority")]
        /// <summary>
        /// Gets an organisation's referring authorities
        /// </summary>
        /// <param name="organisationId">The organisations Id</param>
        /// <returns>Returns a list of all the Referring Authorities</returns>
        public object SaveAuthority([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;

            var ReferringAuthorityId = StringTools.GetInt("ReferringAuthorityId", ref formData);
            var UserId = StringTools.GetInt("UserId", ref formData);
            var AssociatedOrganisationId = StringTools.GetInt("AssociatedOrganisationId", ref formData);
            var Name = StringTools.GetString("Name", ref formData);
            var Description = StringTools.GetString("Description", ref formData);
            var Disabled = StringTools.GetBool("Disabled", ref formData);
            var Reference = StringTools.GetString("Reference", ref formData);
            var EndDate = StringTools.GetDate("EndDate", "dd/MM/yyyy", ref formData);
            var StartDate = StringTools.GetDate("StartDate", "dd/MM/yyyy", ref formData);

            string status = "";


            try
            {
                var referringAuthority = atlasDB.ReferringAuthorities.Where(x => x.AssociatedOrganisationId == AssociatedOrganisationId).FirstOrDefault();

                if (referringAuthority != null)
                {
                    referringAuthority.Name = Name;
                    referringAuthority.Description = Description;
                    referringAuthority.Disabled = Disabled;
                    referringAuthority.UpdatedByUserId = UserId;
                    referringAuthority.DateUpdated = DateTime.Now;
                }

                var referringAuthorityContract = atlasDB.ReferringAuthorityContracts.Where(x => x.ReferringAuthorityId == ReferringAuthorityId).ToList().LastOrDefault();

                if (referringAuthorityContract != null)
                {

                    if (Reference != referringAuthorityContract.Reference
                        || StartDate != referringAuthorityContract.StartDate
                        || EndDate != referringAuthorityContract.EndDate)
                    {
                        referringAuthorityContract.Reference = Reference;
                        referringAuthorityContract.StartDate = StartDate;
                        referringAuthorityContract.EndDate = EndDate;
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(Reference))
                    {

                        ReferringAuthorityContract referringAuthorityContract1 = new ReferringAuthorityContract();

                        referringAuthorityContract1.ReferringAuthorityId = ReferringAuthorityId;
                        referringAuthorityContract1.ContractedOrganisationId = AssociatedOrganisationId;

                        referringAuthorityContract1.Reference = Reference;
                        referringAuthorityContract1.StartDate = StartDate;
                        referringAuthorityContract1.EndDate = EndDate;
                        referringAuthorityContract1.DateCreated = DateTime.Now;
                        referringAuthorityContract1.CreatedByUserId = UserId;


                        referringAuthority.ReferringAuthorityContracts.Add(referringAuthorityContract1);
                    }
                }

                atlasDB.SaveChanges();

                status = "success";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error Updating the Referring Authority. Please retry.";
            }

            return status;
        }


        public class ReferringAuthorityResult
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public int AssociatedOrganisationId { get; set; }
            public bool Disabled { get; set; }
            public string Reference { get; set; }
            public string StartDate { get; set; }
            public string EndDate { get; set; }
        }
    }
}
