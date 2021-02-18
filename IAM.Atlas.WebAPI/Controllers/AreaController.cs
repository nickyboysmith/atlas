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


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class AreaController : AtlasBaseController
    {

        

        //public object related(int OrganisationId)
        public object Get(int Id)
        {
            var organisationAreas =
            (
                from area in atlasDB.Area
                where area.OrganisationId == Id
                select new AreaJSON { Id = area.Id, Name = area.Name, Notes = area.Notes, Disabled = area.Disabled }
            ).ToList();
            
            return organisationAreas;
        }

        [Route("api/area/related/{Id}")]
        [HttpGet]
        public object related(int Id)
        {
            var searchResults =
            (
                from organisationUser in atlasDB.OrganisationUsers
                join organisation in atlasDB.Organisations on organisationUser.OrganisationId equals organisation.Id
                where organisationUser.UserId == Id
                select new { organisation.Id, organisation.Name }
            ).ToList();

            return searchResults;
        }

        // GET api/area/related/5
        
       

        public string Post([FromBody] FormDataCollection formBody)
        {

            string status = "";
            int areaID = 0;
            int organisationID;
            int disabledArea;
            bool disabled;

            Area area = new Area();

            if (Int32.TryParse(formBody["organisationId"], out organisationID))
            {
            }
            else
            {
                return "There was an error verifying your organisation. Please retry.";
            }

            if (Int32.TryParse(formBody["disabled"], out disabledArea))
            {
            }
            else
            {
                return "There was an error verifying your area status. Please retry.";
            }

            if (disabledArea == 1)
            {
                disabled = true;
            }
            if (disabledArea == 0)
            {
                disabled = false;
            }

            /***
                * If the area ID doesnt exist then insert it here!!!
                */
            if (formBody["AreaId"] == null)
            {
                try
                {

                    area.OrganisationId = organisationID;

                    area.Name = formBody["Name"];

                    area.Notes = formBody["Notes"];



                    if (disabledArea == 1)
                    {
                        area.Disabled = true;
                    }
                    if (disabledArea == 0)
                    {
                        area.Disabled = false;
                    }


                    atlasDB.Area.Add(area);
                    atlasDB.SaveChanges();

                    areaID = area.Id;

                }
                catch (DbEntityValidationException ex)
                {
                    return "There was an error adding the area. Please retry.";
                }
            }

            /***
              * If the area ID exists
              * Update the current area id
              */
            if (formBody["AreaId"] != null)
            {
                int theAreaID;
                if (Int32.TryParse(formBody["AreaId"], out theAreaID))
                {

                    try
                    {

                        var checkAreaExists = atlasDB.Area.Where(theArea => theArea.Id == theAreaID).FirstOrDefault();

                        area.OrganisationId = organisationID;

                        area.Name = formBody["Name"];

                        area.Notes = formBody["Notes"];

                        if (disabledArea == 1)
                        {
                            area.Disabled = true;
                        }
                        if (disabledArea == 0)
                        {
                            area.Disabled = false;
                        }

                        area.Id = checkAreaExists.Id;

                        atlasDB.Entry(checkAreaExists).CurrentValues.SetValues(area);
                        atlasDB.SaveChanges();
                        
                    }
                    catch (DbEntityValidationException ex)
                    {
                        status = "There was an error updating the area. Please retry.";
                    }

                }
                else
                {
                    status = "There was an error reading the area. Please retry.";
                }

            }

            return status;

        }
        
    }
}