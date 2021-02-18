using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.ModelBinding;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class VenueCostController : AtlasBaseController
    {
        // GET: api/VenueCost
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }


        public object Get(int id)
        {
            var venueCost = atlasDB.VenueCost.Where(vc => vc.Id == id).FirstOrDefault();
            return venueCost;
        }

        // GET: api/VenueCost/GetByVenue/5
        [Route("api/VenueCost/GetByVenue/{id}")]
        public object GetByVenue(int id)
        {

            var venueCosts = (
                                   from vc in atlasDB.VenueCost
                                   join vct in atlasDB.VenueCostType on vc.CostTypeId equals vct.Id
                                   where vc.VenueId == id
                                   select new
                                   {
                                       id = vc.Id,
                                       costTypeName = vct.Name,
                                       cost = vc.Cost
                                   }
                                   ).ToList();

            return venueCosts;
        }

        // POST: api/VenueCost

        [AuthorizationRequired]
        [Route("api/venuecost/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {
            FormDataCollection formData = formBody;
            VenueCost venueCost = new VenueCost();
            venueCost.Id = StringTools.GetInt("Id", ref formData);
            venueCost.VenueId = StringTools.GetInt("VenueId", ref formData);
            venueCost.CostTypeId = StringTools.GetInt("CostTypeId", ref formData);
            venueCost.Cost = StringTools.GetDecimal("Cost", ref formData);
            venueCost.ValidFromDate = StringTools.GetDate("ValidFromDate", "dd/MM/yyyy", ref formData);
            venueCost.ValidToDate = StringTools.GetDate("ValidToDate", "dd/MM/yyyy", ref formData);

            if (venueCost.VenueId > 0 && venueCost.CostTypeId > 0 && venueCost.Cost > -1)
            {
                if (venueCost.Id > 0)   // do an update
                {
                    atlasDB.VenueCost.Attach(venueCost);
                    var entry = atlasDB.Entry(venueCost);
                    entry.State = System.Data.Entity.EntityState.Modified;
                }
                else    // add to the database
                {
                    atlasDB.VenueCost.Add(venueCost);
                }
                atlasDB.SaveChanges();
            }
        }

        // POST: api/VenueCost
        public void Post2([FromBody] FormDataCollection formBody)
        {
            var venueCost = formBody.ReadAs<VenueCost>();
            //FormDataCollection formData = formBody;
            //VenueCost venueCost = new VenueCost();
            //venueCost.Id = StringTools.GetInt("Id", ref formData);
            //venueCost.VenueId = StringTools.GetInt("VenueId", ref formData);
            //venueCost.CostTypeId = StringTools.GetInt("CostTypeId", ref formData);
            //venueCost.Cost = StringTools.GetDecimal("Cost", ref formData);
            //venueCost.ValidFromDate = StringTools.GetDate("ValidFromDate", "dd/MM/yyyy", ref formData);
            //venueCost.ValidToDate = StringTools.GetDate("ValidToDate", "dd/MM/yyyy", ref formData);

            if (venueCost.VenueId > 0 && venueCost.CostTypeId > 0 && venueCost.Cost > -1)
            {
                if (venueCost.Id > 0)   // do an update
                {
                    atlasDB.VenueCost.Attach(venueCost);
                    var entry = atlasDB.Entry(venueCost);
                    entry.State = System.Data.Entity.EntityState.Modified;
                }
                else    // add to the database
                {
                    atlasDB.VenueCost.Add(venueCost);
                }
                atlasDB.SaveChanges();
            }
        }

        [HttpGet]
        [Route("api/venuecost/delete/{id}")]
        public void Delete(int id)
        {
            var venueCost = atlasDB.VenueCost.Where(vc => vc.Id == id).FirstOrDefault();
            if (venueCost != null)
            {
                atlasDB.VenueCost.Remove(venueCost);
                atlasDB.SaveChanges();
            }
        }
    }
}
