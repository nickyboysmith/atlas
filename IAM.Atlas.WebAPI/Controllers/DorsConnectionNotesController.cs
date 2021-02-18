using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Globalization;


namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class DorsConnectionNotesController : AtlasBaseController
    {

        

        [AuthorizationRequired]
        public object Get(int Id)
        {
            // Validate org belong to the org id from the token
            // will do this as part of another user story

            var notes = atlasDB.DORSConnectionNotes
                .Include("DORSConnection")
                .Include("Note")
                .Include("Note.User")
                .Include("Note.NoteType")
                .Where(
                    dorsNotes => 
                        dorsNotes.DORSConnection.OrganisationId == Id
                )
                .Select(
                    theNotes => new
                    {
                        Id = theNotes.Note.Id,
                        Text = theNotes.Note.Note1,
                        Date = theNotes.Note.DateCreated,
                        UserName = theNotes.Note.User.LoginId,
                        Type = theNotes.Note.NoteType.Name
                    }
                )
                .OrderByDescending(
                    theNotes => theNotes.Date
                )
                .ToList();


            return notes;
        }

        // [AuthorizationRequired]
        public string Post([FromBody] FormDataCollection formBody)
        {

            var organisationId = 0;

            // Get this user ID from token instead of passing it in
            var userId = 0;
            var noteTypeId = 0;
            var noteContent = formBody["content"];



            // Try parse the OrganisationId
            if (Int32.TryParse(formBody["organisationId"], out organisationId)) {
            } else {
                return "We couldn't verify your organisation.";
            }

            // Try parse the UserId
            if (Int32.TryParse(formBody["userId"], out userId)) {
            } else {
                return "We couldn't verify your user details.";
            }

            // Try parse the UserId
            if (Int32.TryParse(formBody["type"], out noteTypeId)) {
            } else {
                return "We couldn't verify your user details.";
            }

            if (String.IsNullOrEmpty(noteContent))
            {
                return "Your note needs to contain some text.";
            }



            try {

                var checkDORSConnectionExists = atlasDB.DORSConnections.Where(
                    connection => connection.OrganisationId == organisationId
                )
                .FirstOrDefault();

                if (checkDORSConnectionExists == null)
                {
                    return "This is an invalid request";
                }

                Note note = new Note();

                note.Note1 = noteContent;
                note.NoteTypeId = noteTypeId;
                note.DateCreated = DateTime.Now;
                note.CreatedByUserId = userId;

                DORSConnectionNote dorsConnectionNotes = new DORSConnectionNote();
                dorsConnectionNotes.NoteId = note.Id;
                dorsConnectionNotes.DORSConnectionId = checkDORSConnectionExists.Id;

                dorsConnectionNotes.Note = note;
                


                atlasDB.DORSConnectionNotes.Add(dorsConnectionNotes);

                atlasDB.SaveChanges();

                return "success";

            } catch (DbEntityValidationException ex) {
                return "There was an error adding your note.";
            }



        }


        
        
    }
}