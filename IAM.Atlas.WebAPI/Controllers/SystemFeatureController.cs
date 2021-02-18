using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;
using System.Net.Http;
using System.Net;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class SystemFeatureController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/systemFeature/Information/{SystemFeatureId}/{OrganisationId}")]
        [HttpGet]
        public object GetSystemFeatureInformation(int SystemFeatureId, int OrganisationId)
        {
            var info = atlasDB.SystemFeatureItems
                .Where(
                    items =>  items.Id == SystemFeatureId
                )
                .Select(
                    item => new {
                        item.Description,
                        Notes = item
                            .SystemFeatureUserNotes
                            .Where(
                                note => 
                                    note.OrganisationId == OrganisationId && 
                                    note.ShareWithOrganisation == true &&
                                    note.Disabled == false
                            )
                            .Select(
                                systemNote => new
                                {
                                    Content = systemNote.Note.Note1,
                                    systemNote.DateAdded
                                }
                            )
                            .ToList()
                    }
                )
                .FirstOrDefault();
            return info;
        }

        [Route("api/systemFeature/AddNote")]
        [HttpPost]
        public bool AddNote([FromBody] FormDataCollection formBody)
        {
            var organisationId = StringTools.GetIntOrFail("organisationId", ref formBody, "Please select a valid organisation");
            var noteTypeId = StringTools.GetIntOrFail("type", ref formBody, "Please select a valid note type");
            var userId = StringTools.GetIntOrFail("userId", ref formBody, "Please select a valid User");
            var systemFeatureId = StringTools.GetIntOrFail("systemFeatureId", ref formBody, "Please select a system feature");
            var shareInformation = StringTools.GetBoolOrFail("shareInformation", ref formBody, "Please tell us whether or not you'd like this note shared");
            var note = StringTools.GetStringOrFail("text", ref formBody, "Please enter text for the note");

            try {

                var theNote = new Note();
                theNote.Note1 = note;
                theNote.NoteTypeId = noteTypeId;
                theNote.CreatedByUserId = userId;

                // Now add the note
                var systemUserNote = new SystemFeatureUserNote();

                systemUserNote.AddedByUserId = userId;
                systemUserNote.DateAdded = DateTime.Now;
                systemUserNote.Disabled = false;
                systemUserNote.SystemFeatureItemId = systemFeatureId;
                systemUserNote.OrganisationId = organisationId;
                systemUserNote.ShareWithOrganisation = shareInformation;
                systemUserNote.Note = theNote;

                atlasDB.SystemFeatureUserNotes.Add(systemUserNote);

                atlasDB.SaveChanges();

            } catch (Exception e) {

                throw (e);

            }

            return true;
        }

        [AuthorizationRequired]
        [Route("api/systemFeature/GetFeatureGroups")]
        [HttpGet]
        public object getFeatureGroups()
        {
            try
            {
                return atlasDB.SystemFeatureGroups.ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }


        [AuthorizationRequired]
        [Route("api/systemFeature/GetFeatureGroupDetailsByGroupId/{FeatureGroupId}")]
        [HttpGet]
        public object GetFeatureGroupDetailsByGroupId(int FeatureGroupId)
        {
            try
            {

                return atlasDB.SystemFeatureGroups
                            .Where(sfg => sfg.Id == FeatureGroupId).ToList();



            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/systemFeature/GetFeatureGroupItemsByGroupId/{FeatureGroupId}")]
        [HttpGet]
        public object GetFeatureGroupItemsByGroupId(int FeatureGroupId)
        {
            try
            {
                return atlasDB.SystemFeatureGroupItems
                .Include("SystemFeatureItem")
                .Where(sfgi => sfgi.SystemFeatureGroupId == FeatureGroupId)
                .ToList()
                .Select(sfi => new
                {
                    Id = sfi.SystemFeatureItem.Id,
                    Name = sfi.SystemFeatureItem.Name,
                    Title = sfi.SystemFeatureItem.Title,
                    Description = sfi.SystemFeatureItem.Description,
                    Disabled = sfi.SystemFeatureItem.Disabled

                });

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }


        [AuthorizationRequired]
        [Route("api/systemFeature/GetFeatureGroupItemDetailsByGroupItemId/{FeatureGroupItemId}")]
        [HttpGet]
        public object GetFeatureGroupItemDetailsByGroupItemId(int FeatureGroupItemId)
        {
            try
            {

                return atlasDB.SystemFeatureItems
                            .Where(sfi => sfi.Id == FeatureGroupItemId).ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/systemFeature/GetAddExistingFeatureGroupItemDetailsByGroupItemId/{FeatureGroupItemId}")]
        [HttpGet]
        public object GetAddExistingFeatureGroupItemDetailsByGroupItemId(int FeatureGroupItemId)
        {
            try
            {

                return
                (from sfi in atlasDB.SystemFeatureItems
                 select new { Id = sfi.Id, Name = sfi.Name }).Except(from sfi1 in atlasDB.SystemFeatureItems
                                         join sfgi in atlasDB.SystemFeatureGroupItems on sfi1.Id equals sfgi.SystemFeatureItemId
                                         where sfgi.SystemFeatureGroupId == FeatureGroupItemId
                                         select new { Id = sfi1.Id, Name = sfi1.Name })
                                        .Distinct()
                                        .ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }





        [AuthorizationRequired]
        [Route("api/systemFeature/SaveFeatureGroup")]
        [HttpPost]
        public string SaveFeatureGroup([FromBody] FormDataCollection formBody)
        {

            var systemFeatureGroup = formBody.ReadAs<SystemFeatureGroup>();

            systemFeatureGroup.DateUpdated = DateTime.Now;

            if (systemFeatureGroup.Id > 0) // update
            {
                atlasDB.SystemFeatureGroups.Attach(systemFeatureGroup);
                    var entry = atlasDB.Entry(systemFeatureGroup);
                    entry.State = System.Data.Entity.EntityState.Modified;
            }
            else // add
            {
                atlasDB.SystemFeatureGroups.Add(systemFeatureGroup);
            }
            try
                    {
                        atlasDB.SaveChanges();
                    }
                    catch (DbEntityValidationException ex)
                    {
                        throw new HttpResponseException(
                            new HttpResponseMessage(HttpStatusCode.InternalServerError)
                            {
                                Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                                ReasonPhrase = "We can't process your request."
                            }
                        );
                    }
       
            return "success";

        }

        [AuthorizationRequired]
        [Route("api/systemFeature/SaveFeatureGroupItem")]
        [HttpPost]
        public string SaveFeatureGroupItem([FromBody] FormDataCollection formBody)
        {
            var systemFeatureGroupId = StringTools.GetInt("SystemFeatureGroupId", ref formBody);
            var systemFeatureItem = formBody.ReadAs<SystemFeatureItem>();

            systemFeatureItem.DateUpdated = DateTime.Now;

            if (systemFeatureItem.Id > 0) // update
            {
                atlasDB.SystemFeatureItems.Attach(systemFeatureItem);
                var entry = atlasDB.Entry(systemFeatureItem);
                entry.State = System.Data.Entity.EntityState.Modified;
            }
            else // add
            {
                atlasDB.SystemFeatureItems.Add(systemFeatureItem);

                SystemFeatureGroupItem systemFeatureGroupItem = new SystemFeatureGroupItem();

                systemFeatureGroupItem.SystemFeatureGroupId = systemFeatureGroupId;
                systemFeatureGroupItem.SystemFeatureItemId = systemFeatureGroupItem.Id;
                

                atlasDB.SystemFeatureGroupItems.Add(systemFeatureGroupItem);

            }
            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return "success";

        }

        [AuthorizationRequired]
        [Route("api/systemFeature/SaveAddExistingFeatureGroupItems")]
        [HttpPost]
        public object SaveAddExistingFeatureGroupItems([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var systemFeatureGroupId = StringTools.GetInt("SystemFeatureGroupId", ref formBody);

            var systemFeatureItems = (from fb in formBody
                                    where fb.Key.Contains("selectedItems")
                                    select new { fb.Key, fb.Value });


            foreach (var systemFeatureItem in systemFeatureItems)
            {
                var systemFeatureGroupItem = new SystemFeatureGroupItem();
                systemFeatureGroupItem.SystemFeatureGroupId = systemFeatureGroupId;
                systemFeatureGroupItem.SystemFeatureItemId = Int32.Parse(systemFeatureItem.Value);

                atlasDB.SystemFeatureGroupItems.Add(systemFeatureGroupItem);
            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return "Success";
        }

        [AuthorizationRequired]
        [Route("api/systemFeature/GetFeatureDescriptionNotesByFeatureName/{FeatureItemName}/{OrganisationId}/{UserId}")]
        [HttpGet]
        public object GetFeatureDescriptionNotesByFeatureName(string FeatureItemName, int OrganisationId, int UserId)
        {

            try
            {

                return atlasDBViews.vwSystemFeaturesWithinGroupsForUsers
                     .Where(
                         items => items.SystemFeatureName == FeatureItemName
                                     && (items.OrganisationId == OrganisationId || items.OrganisationId == null)
                                     && items.UserId == UserId

                         )
                     .Select(
                         item => new
                         {
                             Id = item.SystemFeatureId,
                             Description = item.SystemFeatureDescription,
                             Title = item.SystemFeatureTitle,
                             Notes = item.SystemFeatureNotes
                         })
                    .FirstOrDefault();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/systemFeature/GetNoteTypes")]
        [HttpGet]
        public object GetNoteTypes()
        {
            try { 

                return atlasDB.NoteType.ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/systemFeature/SaveNote")]
        [HttpPost]
        public object SaveNote([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var systemFeatureItemId = StringTools.GetInt("systemFeatureItemId", ref formBody);
            var noteTypeId = StringTools.GetInt("noteTypeId", ref formBody);
            var userId = StringTools.GetInt("addedByUserId", ref formBody);
            var organisationId = StringTools.GetInt("organisationId", ref formBody);
            var noteContent = StringTools.GetString("noteContent", ref formBody);
            var shareInformation = StringTools.GetBool("shareInformation", ref formBody);

           
            var note = new Note();

            note.Note1 = noteContent;
            note.DateCreated = DateTime.Now;
            note.CreatedByUserId = userId;
            note.Removed = false;
            note.NoteTypeId = noteTypeId;

            atlasDB.Notes.Add(note);

            var systemFeatureUserNote = new SystemFeatureUserNote();

            systemFeatureUserNote.SystemFeatureItemId = systemFeatureItemId;
            systemFeatureUserNote.NoteId = note.Id;
            systemFeatureUserNote.AddedByUserId = userId;
            systemFeatureUserNote.DateAdded = DateTime.Now;
            systemFeatureUserNote.Disabled = false;
            systemFeatureUserNote.OrganisationId = organisationId;
            systemFeatureUserNote.ShareWithOrganisation = shareInformation;

            atlasDB.SystemFeatureUserNotes.Add(systemFeatureUserNote);

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return "Success";
        }
    }
}



