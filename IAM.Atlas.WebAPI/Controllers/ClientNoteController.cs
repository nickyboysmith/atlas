using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    /// <summary>
    /// Note: This may need to be refactored into the Client Controller at a later date but for speed of development I will make a new class for now - Paul
    /// </summary>
    [AllowCrossDomainAccess]
    public class ClientNoteController : AtlasBaseController
    {
        [Route("api/ClientNote/GetTypes")]
        public IEnumerable<NoteTypeJSON> GetNoteTypes()
        {
            return atlasDB.NoteType.Select(n => new NoteTypeJSON { Id = n.Id, Name = n.Name}).ToList();
        }

        // POST: api/Client
        public string Post([FromBody] FormDataCollection formBody)
        {
            string status = "";
            if (formBody.Count() > 0)
            {
                var formClientId = formBody.Get("ClientId");
                var formNote = formBody.Get("Note");
                var formUserId = formBody.Get("UserId");
                var formNoteTypeId = formBody["NoteTypeId"];
                
                try
                {
                    if (formClientId != null && formNote != null && formUserId != null)
                    {
                        int clientId = Int32.Parse(formClientId.ToString());
                        string noteText = formNote.ToString();
                        int userId = Int32.Parse(formUserId.ToString());
                        int noteTypeId = Int32.Parse(formNoteTypeId.ToString());

                        Client client = atlasDB.Clients.Where(c => c.Id == clientId).FirstOrDefault();

                        if (client != null)
                        {
                            if(userHasPermission(userId))
                            {
                                Note note = new Note();
                                note.CreatedByUserId = userId;  // this needs to be checked that the user exists when this functionality is done
                                note.DateCreated = DateTime.Now;
                                note.Note1 = noteText;
                                note.NoteTypeId = noteTypeId;

                                ClientNote clientNote = new ClientNote();
                                clientNote.Client = client;
                                clientNote.Note = note;

                                client.ClientNotes.Add(clientNote);

                                atlasDB.SaveChanges();
                                status = "success";
                            }
                        }
                    }
                }
                catch (DbEntityValidationException ex)
                {
                    status = "error: data validation error";
                }
            }
            else
            {
                status = "error: JSON not sent.";
            }
            return status;
        }

        private bool userHasPermission(int userId)
        {
            return true;
        }
    }
}