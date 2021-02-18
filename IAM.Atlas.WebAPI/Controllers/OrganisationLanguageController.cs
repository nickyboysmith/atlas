using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using IAM.Atlas.WebAPI.Models;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class OrganisationLanguageController : AtlasBaseController
    {
        // Returns the languages available to a particular organisation
        public object Get(int Id)
        {
            var organisationLanguages = (
                    from ol in atlasDB.OrganisationLanguage
                    .Include("Language") 
                    where ol.OrganisationId == Id
                    select new OrganisationLanguageJSON{ Id = ol.Id, Description = ol.Language.EnglishName }
                ).ToList();

            return organisationLanguages;
        }  
    }

}