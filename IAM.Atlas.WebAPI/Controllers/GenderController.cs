using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class GenderController : AtlasBaseController
    {
        /// <summary>
        /// Get all the different genders
        /// </summary>
        /// <returns>A list of genders</returns>
        [Route("api/gender/getGenders")]
        public List<Gender> GetGenders()
        {
            var genders = new List<Gender>();
            genders = atlasDB.Genders.ToList();
            return genders;
        }
    }
}