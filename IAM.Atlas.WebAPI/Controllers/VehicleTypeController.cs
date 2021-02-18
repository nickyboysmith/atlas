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
    public class VehicleTypeController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/vehicleType/getVehicleTypes/{organisationId}")]
        [HttpGet]
        public object GetVehicleTypes(int organisationId)
        {
            try
            {
                var vehicleTypes = atlasDB.VehicleTypes
                                            .Where(vt => vt.OrganisationId == organisationId)
                                            .ToList();

                return vehicleTypes;

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
        [Route("api/vehicleType/AddVehicleType")]
        public string AddVehicleType([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            var vehicleTypeName = StringTools.GetString("VehicleTypeName", ref formData);
            var vehicleTypeDescription = StringTools.GetString("VehicleTypeDescription", ref formData);
            var vehicleTypeDisabled = StringTools.GetBool("VehicleTypeDisabled", ref formData);
            var vehicleTypeAutomatic = StringTools.GetBool("VehicleTypeAutomatic", ref formData);
            var organisationId = StringTools.GetInt("OrganisationId", ref formData);
            var createdByUserId = StringTools.GetInt("CreatedByUserId", ref formData);
            string status = "";

            try
            {
                if (!string.IsNullOrEmpty(vehicleTypeName))
                {
                    var vehicleType = new VehicleType();
                    vehicleType.Name = vehicleTypeName;
                    vehicleType.Description = vehicleTypeDescription;
                    vehicleType.Disabled = vehicleTypeDisabled;
                    vehicleType.Automatic = vehicleTypeAutomatic;
                    vehicleType.OrganisationId = organisationId;
                    vehicleType.DateCreated = DateTime.Now;
                    vehicleType.CreatedByUserId = createdByUserId;
                    atlasDB.VehicleTypes.Add(vehicleType);
                    atlasDB.SaveChanges();

                    status = "Vehicle Type saved successfully";
                }
                else
                {
                    status = "Vehicle name is empty.";
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
        [Route("api/vehicleType/saveVehicleType")]
        public string SaveVehicleType([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var vehicleTypeId = StringTools.GetInt("Id", ref formData);
            var name = StringTools.GetString("Name", ref formData);
            var description = StringTools.GetString("Description", ref formData);
            var disabled = StringTools.GetBool("Disabled", ref formData);
            var automatic = StringTools.GetBool("Automatic", ref formData);
            var updatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);
            var status = "";

            var vehicleType = atlasDB.VehicleTypes.Find(vehicleTypeId);

            try
            {
                atlasDB.VehicleTypes.Attach(vehicleType);
                var entry = atlasDB.Entry(vehicleType);

                vehicleType.Name = name;
                atlasDB.Entry(vehicleType).Property("Name").IsModified = true;

                vehicleType.Description = description;
                atlasDB.Entry(vehicleType).Property("Description").IsModified = true;

                vehicleType.Disabled = disabled;
                atlasDB.Entry(vehicleType).Property("Disabled").IsModified = true;

                vehicleType.Automatic = automatic;
                atlasDB.Entry(vehicleType).Property("Automatic").IsModified = true;

                vehicleType.UpdatedByUserId = updatedByUserId;
                atlasDB.Entry(vehicleType).Property("UpdatedByUserId").IsModified = true;

                vehicleType.DateUpdated = DateTime.Now;
                atlasDB.Entry(vehicleType).Property("DateUpdated").IsModified = true;

                atlasDB.SaveChanges();

                status = "Vehicle Type Saved Successfully";
            }

            catch (Exception ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }
    }
}

