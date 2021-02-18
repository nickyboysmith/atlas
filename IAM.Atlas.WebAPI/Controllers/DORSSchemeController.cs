using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DORSSchemeController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/DORSScheme/GetList/{organisationId}")]
        public List<DORSScheme> GetList(int organisationId)
        {
            var DORSSchemes = atlasDB.DORSSchemes
                                        //.Include(ds => ds.DORSSchemeCourseTypes)
                                        //.Include(ds => ds.DORSSchemeCourseTypes.Select(dsct => dsct.CourseType))
                                        .Where(ds => ds.DORSSchemeCourseTypes.Any(dsct => dsct.CourseType.OrganisationId == organisationId))
                                        .ToList();
            return DORSSchemes;
        }
    }
}