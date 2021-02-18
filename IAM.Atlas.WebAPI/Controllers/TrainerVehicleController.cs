using IAM.Atlas.Data;
using System;
using System.Drawing;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class TrainerVehicleController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/TrainerVehicle/GetTrainersByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetTrainersByOrganisation(int OrganisationId)
        {
            return atlasDB.Trainer
                .Include("TrainerOrganisation")
                .Include("TrainerLicence")
                .Where(tr => tr.TrainerOrganisation.Any(o => o.OrganisationId == OrganisationId))
                .Select(
                    trainer => new
                    {
                        Id = trainer.Id,
                        DisplayName = trainer.DisplayName,
                        LicenceNumber = trainer.TrainerLicence.FirstOrDefault() != null ? (trainer.TrainerLicence.FirstOrDefault().LicenceNumber != null ? trainer.TrainerLicence.FirstOrDefault().LicenceNumber : "") : ""
                    })
                .OrderBy(trainer => trainer.DisplayName)
                .ToList();
        }

        [AuthorizationRequired]
        [Route("api/TrainerVehicle/GetTrainerById/{TrainerId}")]
        [HttpGet]
        public object GetTrainerById(int TrainerId)
        {
            return atlasDB.Trainer
                .Include("TrainerLicence")
                .Where(t => t.Id == TrainerId)
                .Select(
                    trainer => new
                    {
                        Id = trainer.Id,
                        TrainerName = trainer.DisplayName,
                        TrainerDateOfBirth = trainer.DateOfBirth,
                        TrainerLicenceNumber = trainer.TrainerLicence.FirstOrDefault().LicenceNumber
                    }).Single();
        }

        [AuthorizationRequired]
        [Route("api/TrainerVehicle/GetTrainerVehicleDetailsByOrganisation/{OrganisationId}/{TrainerId}/{VehicleTypeId}/{VehicleCategoryId}")]
        [HttpGet]
        public object GetTrainerVehicleDetailsByOrganisation(int OrganisationId, int? TrainerId, int? VehicleTypeId, int? VehicleCategoryId)
        {
            
            var organisationId = OrganisationId;
            var trainerId = TrainerId;
            var vehicleTypeId = VehicleTypeId;
            var vehicleCategoryId = VehicleCategoryId;

            // Construct dynamic where clause
            string whereCondition = "OrganisationId == " + organisationId;

            if (trainerId != null)
            {
                whereCondition = whereCondition + " && TrainerId == " + trainerId;

            }

            if (vehicleTypeId != null)
            {
                whereCondition = whereCondition + " && VehicleTypeId == " + vehicleTypeId;

            }

            if (vehicleCategoryId != null)
            {
                whereCondition = whereCondition + " && TrainerVehicleCategoryIds.Contains(\":" + vehicleCategoryId.ToString() + ":\")"; 
            }

            var trainerVehicleDetails = atlasDBViews.vwTrainerVehicles
                                               .Where(whereCondition)
                                               .Select(
                                                   vehicleDetails => new
                                                   {
                                                       TrainerId = vehicleDetails.TrainerId,
                                                       TrainerVehicleId = vehicleDetails.TrainerVehicleId,
                                                       TrainerName = vehicleDetails.TrainerName,
                                                       TrainerDateOfBirth = vehicleDetails.TrainerDateOfBirth,
                                                       TrainerLicenceNumber = vehicleDetails.TrainerLicenceNumber,
                                                       TrainerVehicleNumberPlate = vehicleDetails.TrainerVehicleNumberPlate,
                                                       TrainerVehicleCategoryIds = vehicleDetails.TrainerVehicleCategoryIds,
                                                       TrainerVehicleDescription = vehicleDetails.TrainerVehicleDescription,
                                                       TrainerVehicleDescriptionWithCategories = vehicleDetails.TrainerVehicleDescriptionWithCategories,
                                                       TrainerVehicleNotes = vehicleDetails.TrainerVehicleNotes,
                                                       VehicleTypeId = vehicleDetails.VehicleTypeId,
                                                       VehicleTypeName = vehicleDetails.VehicleTypeName,
                                                       VehicleTypeDescription = vehicleDetails.VehicleTypeDescription 
                                                   })
                                               .OrderBy(vehicleDetails => vehicleDetails.VehicleTypeDescription)
                                               .ToList();


            return trainerVehicleDetails;
            
        }

        [AuthorizationRequired]
        [Route("api/TrainerVehicle/GetTrainerVehicleNotesById/{OrganisationId}/{TrainerVehicleId}")]
        [HttpGet]
        public object GetTrainerVehicleNotesById(int OrganisationId, int TrainerVehicleId)
        {

            return atlasDBViews.vwTrainerVehicleNotes_SubView
                    .Where(tvn => tvn.TrainerVehicleId == TrainerVehicleId
                                    && tvn.OrganisationId == OrganisationId);

        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/TrainerVehicle/SaveNote")]
        public string SaveNote([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var trainerVehicleId = StringTools.GetInt("trainerVehicleId", ref formData);
            var organisationId = StringTools.GetInt("organisationId", ref formData);
            var noteTypeId = StringTools.GetInt("type", ref formData);
            var userId = StringTools.GetInt("userId", ref formData);
            var text = StringTools.GetString("text", ref formData);

            // Create the Note
            var note = new Note();
            note.Note1 = text;
            note.NoteTypeId = noteTypeId;
            note.DateCreated = DateTime.Now;
            note.CreatedByUserId = userId;
            atlasDB.Notes.Add(note);

            // Create the TrainerVehicle Note
            var trainerVehicleNote = new TrainerVehicleNote();
            trainerVehicleNote.TrainerVehicleId = trainerVehicleId;
            trainerVehicleNote.NoteId = note.Id;
            atlasDB.TrainerVehicleNotes.Add(trainerVehicleNote);

            string status = "";

            try
            {
                atlasDB.SaveChanges();

                status = "Trainer Vehicle Note Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/TrainerVehicle/AddTrainerVehicle")]
        public string AddTrainerVehicle([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var trainerId = StringTools.GetInt("TrainerId", ref formData);
            var vehicleTypeId = StringTools.GetInt("VehicleTypeId", ref formData);
            var numberPlate = StringTools.GetString("TrainerVehicleNumberPlate", ref formData);
            var description = StringTools.GetString("TrainerVehicleDescription", ref formData);
            var notes = StringTools.GetString("TrainerVehicleNotes", ref formData);
            var userId = StringTools.GetInt("AddedByUserId", ref formData);

            string status = "";


            var categoryIds = (from fb in formBody
                              where fb.Key.Contains("VehicleCategoryIds")
                              select new { fb.Key, fb.Value });

            // Create the TrainerVehicle
            var trainerVehicle = new TrainerVehicle();
            trainerVehicle.TrainerId = trainerId;
            trainerVehicle.VehicleTypeId = vehicleTypeId;
            trainerVehicle.NumberPlate = numberPlate;
            trainerVehicle.Description = description;
            trainerVehicle.DateAdded = DateTime.Now;
            trainerVehicle.AddedByUserId = userId;

            atlasDB.TrainerVehicles.Add(trainerVehicle);

            // Create the Trainer Vehicle Categories
            foreach (var categoryId in categoryIds)
            {
                var trainerVehicleCategory = new TrainerVehicleCategory();

                trainerVehicleCategory.TrainerVehicleId = trainerVehicle.Id;
                trainerVehicleCategory.VehicleCategoryId = Int32.Parse(categoryId.Value);

                atlasDB.TrainerVehicleCategories.Add(trainerVehicleCategory);
            }

            // Create the Note
            var note = new Note();
            note.Note1 = notes;
            note.NoteTypeId = 1; // Default to General
            note.DateCreated = DateTime.Now;
            note.CreatedByUserId = userId;
            atlasDB.Notes.Add(note);

            // Create the TrainerVehicle Note
            var trainerVehicleNote = new TrainerVehicleNote();
            trainerVehicleNote.TrainerVehicleId = trainerVehicle.Id;
            trainerVehicleNote.NoteId = note.Id;
            atlasDB.TrainerVehicleNotes.Add(trainerVehicleNote);

            try
            {
                atlasDB.SaveChanges();

                status = "Trainer Vehicle Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/TrainerVehicle/EditTrainerVehicle")]
        public string EditTrainerVehicle([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var trainerId = StringTools.GetInt("TrainerId", ref formData);
            var vehicleTypeId = StringTools.GetInt("VehicleTypeId", ref formData);
            var description = StringTools.GetString("TrainerVehicleDescription", ref formData);

            string status = "";

            var editTrainerVehicle = atlasDB.TrainerVehicles
                                       .Where(tv => tv.TrainerId == trainerId
                                              && tv.VehicleTypeId == vehicleTypeId).FirstOrDefault();

            if (editTrainerVehicle != null)
            {
                

                atlasDB.TrainerVehicles.Attach(editTrainerVehicle);
                var entry = atlasDB.Entry(editTrainerVehicle);

                editTrainerVehicle.Description = description;
                
                atlasDB.Entry(editTrainerVehicle).Property("Description").IsModified = true;

            }

            // Get the TrainerVehicle Categories to Remove
            var removeTrainerVehicleCategories = atlasDB.TrainerVehicleCategories
                                   .Where(tvc => tvc.TrainerVehicleId == editTrainerVehicle.Id).ToList();


            if (removeTrainerVehicleCategories.Count() != 0)
            {
                foreach (var removeTrainerVehicleCategory in removeTrainerVehicleCategories)
                {
                    // Remove the TrainerVehicle Category
                    atlasDB.TrainerVehicleCategories.Remove(removeTrainerVehicleCategory);
                    atlasDB.Entry(removeTrainerVehicleCategory).State = EntityState.Deleted;
                    
                }

            }

            var categoryIds = (from fb in formBody
                               where fb.Key.Contains("VehicleCategoryIds")
                               select new { fb.Key, fb.Value });

            // Create the Trainer Vehicle Categories
            foreach (var categoryId in categoryIds)
            {
                var trainerVehicleCategory = new TrainerVehicleCategory();

                trainerVehicleCategory.TrainerVehicleId = editTrainerVehicle.Id;
                trainerVehicleCategory.VehicleCategoryId = Int32.Parse(categoryId.Value);

                atlasDB.TrainerVehicleCategories.Add(trainerVehicleCategory);
            }

            try
            {
                atlasDB.SaveChanges();

                status = "Trainer Vehicle Saved Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }
        
        [HttpPost]
        [AuthorizationRequired]
        [Route("api/TrainerVehicle/RemoveTrainerVehicle")]
        public string RemoveTrainerVehicle([FromBody] FormDataCollection formBody)
        {

            var formData = formBody;

            var trainerId = StringTools.GetInt("TrainerId", ref formData);
            var vehicleTypeId = StringTools.GetInt("VehicleTypeId", ref formData);
            var RemovedByUserId = StringTools.GetInt("RemovedByUserId", ref formData);

            // Get the TrainerVehicleId to Remove
            var removeTrainerVehicle = atlasDB.TrainerVehicles
                                       .Where(tv => tv.TrainerId == trainerId
                                              && tv.VehicleTypeId == vehicleTypeId).FirstOrDefault();

            if (removeTrainerVehicle != null)
            {

                // Create the TrainerVehicleRemove Entry
                var trainerVehicleRemove = new TrainerVehicleRemove();
                trainerVehicleRemove.TrainerVehicleId = removeTrainerVehicle.Id;
                trainerVehicleRemove.RemovedByUserId = RemovedByUserId;

                trainerVehicleRemove.DateRemoved = DateTime.Now;
                
                atlasDB.TrainerVehicleRemoves.Add(trainerVehicleRemove);
            }

            string status = "";

            try
            {
                atlasDB.SaveChanges();

                status = "Trainer Vehicle Removed Successfully";
            }
            catch (DbEntityValidationException ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }

            return status;
        }
    }
}
