using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Classes;
using System.Linq.Dynamic;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.Data;
using System;
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class VehicleCategoryController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/vehicleCategory/getVehicleCategories/{organisationId}")]
        [HttpGet]
        public object GetVehicleCategories(int organisationId)
        {
            try
            {
                var vehicleCategories = atlasDB.VehicleCategories
                                            .Where(vc => vc.OrganisationId == organisationId)
                                            .ToList();

                return vehicleCategories;

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists, please contact support"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/vehicleCategory/addVehicleCategory")]
        public string AddVehicleType([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            var vehicleCategoryName = StringTools.GetString("VehicleCategoryName", ref formData);
            var vehicleCategoryDescription = StringTools.GetString("VehicleCategoryDescription", ref formData);
            var vehicleCategoryDisabled = StringTools.GetBool("VehicleCategoryDisabled", ref formData);
            var organisationId = StringTools.GetInt("OrganisationId", ref formData);
            var addedByUserId = StringTools.GetInt("AddedByUserId", ref formData);
            string status = "";

            try
            {
                if (!string.IsNullOrEmpty(vehicleCategoryName))
                {
                    var vehicleCategory = new VehicleCategory();
                    vehicleCategory.Name = vehicleCategoryName;
                    vehicleCategory.Disabled = vehicleCategoryDisabled;
                    vehicleCategory.AddedByUserId = addedByUserId;
                    vehicleCategory.DateAdded = DateTime.Now;
                    vehicleCategory.Description = vehicleCategoryDescription;
                    vehicleCategory.OrganisationId = organisationId;
                    atlasDB.VehicleCategories.Add(vehicleCategory);
                    atlasDB.SaveChanges();

                    status = "Vehicle category saved successfully";
                }
                else
                {
                    status = "Vehicle category name is empty.";
                }
            }
            catch (Exception ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/vehicleCategory/saveVehicleCategory")]
        public string SaveVehicleCategory([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var vehicleCategoryId = StringTools.GetInt("Id", ref formData);
            var name = StringTools.GetString("Name", ref formData);
            var disabled = StringTools.GetBool("Disabled", ref formData);
            var description = StringTools.GetString("Description", ref formData);
            var updatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);
            var status = "";

            var vehicleCategory = atlasDB.VehicleCategories.Find(vehicleCategoryId);

            try
            {
                atlasDB.VehicleCategories.Attach(vehicleCategory);
                var entry = atlasDB.Entry(vehicleCategory);

                vehicleCategory.Name = name;
                atlasDB.Entry(vehicleCategory).Property("Name").IsModified = true;

                vehicleCategory.Disabled = disabled;
                atlasDB.Entry(vehicleCategory).Property("Disabled").IsModified = true;

                vehicleCategory.Description = description;
                atlasDB.Entry(vehicleCategory).Property("Description").IsModified = true;

                vehicleCategory.UpdatedByUserId = updatedByUserId;
                atlasDB.Entry(vehicleCategory).Property("UpdatedByUserId").IsModified = true;

                vehicleCategory.DateUpdated = DateTime.Now;
                atlasDB.Entry(vehicleCategory).Property("DateUpdated").IsModified = true;

                atlasDB.SaveChanges();

                status = "Vehicle Category Saved Successfully";
            }

            catch (Exception ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }
    }
}

