using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Web.Http;
using System.Xml.Linq;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class VenueCostTypeController : AtlasBaseController
    {
        [Route("api/venuecosttype/getbyorganisation/{organisationId}")]
        public object GetByOrganisation(int organisationId)
        {
            return atlasDB.VenueCostType.Where(v => v.OrganisationId == organisationId).ToList();
        }

        // POST: api/CourseCategory
        public void Post([FromBody] FormDataCollection formBody)
        {
            FormDataCollection formData = formBody;
            VenueCostType venueCostType = new VenueCostType();
            venueCostType.Name = StringTools.GetString("Name", ref formData);
            venueCostType.Id = StringTools.GetInt("Id", ref formData);
            venueCostType.Disabled = StringTools.GetBool("Disabled", ref formData);
            venueCostType.OrganisationId = StringTools.GetInt("OrganisationId", ref formData);

            if (!string.IsNullOrEmpty(venueCostType.Name))
            {
                if (venueCostType.Id > 0)   // do an update
                {
                    atlasDB.VenueCostType.Attach(venueCostType);
                    var entry = atlasDB.Entry(venueCostType);
                    entry.State = System.Data.Entity.EntityState.Modified;
                }
                else    // add to the database
                {
                    atlasDB.VenueCostType.Add(venueCostType);
                }
                atlasDB.SaveChanges();
            }
        }
    }
}
