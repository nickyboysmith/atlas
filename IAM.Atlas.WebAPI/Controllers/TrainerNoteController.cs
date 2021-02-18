using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class TrainerNoteController : AtlasBaseController
    {
        // GET api/<controller>
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/<controller>/5
        public string Get(int id)
        {
            return "value";
        }

        [Route("api/TrainerNote/GetTypes")]
        public IEnumerable<NoteType> GetTypes()
        {
            return atlasDB.NoteType.ToList();
        }

        [Route("api/TrainerNote/GetByTrainerId/{TrainerId}/{UserId}")]
        public IEnumerable<TrainerNotesJSON> GetByTrainerId(int TrainerId, int UserId)
        {
            //Check if trainer and user are the same
            var trainer = atlasDB.Trainer
                .Where(x => x.Id == TrainerId).FirstOrDefault();

            if (trainer == null)
            {
                return new List<TrainerNotesJSON>();
            }
            else
            {
                //If the User and train are the same person, only show notes by that user

                return atlasDB.TrainerNote
                    .Include("Note.NoteType")
                    .Include("Note.User")
                    .Where(n =>
                        ((trainer.UserId != UserId) || n.Note.CreatedByUserId == UserId) &&
                        n.TrainerId == TrainerId)
                    .OrderByDescending(x => x.Note.DateCreated)
                    .Select(n => new TrainerNotesJSON
                    {
                        Date = n.Note.DateCreated != null ? (DateTime)n.Note.DateCreated : DateTime.Now,
                        Text = n.Note.Note1,
                        User = n.Note.User.Name,
                        Type = n.Note.NoteType.Name
                    }).ToList();
            }
        }

        // POST api/<controller>
        public void Post([FromBody] FormDataCollection formBody)
        {
            TrainerNote trainerNote = new TrainerNote();
            var formData = formBody;
            var noteText = StringTools.GetString("Note", ref formData);
            var trainerId = StringTools.GetInt("TrainerId", ref formData);

            if (!string.IsNullOrEmpty(noteText))
            {
                Note note = new Note
                {
                    CreatedByUserId = StringTools.GetInt("UserId", ref formData),
                    Note1 = noteText,
                    DateCreated = DateTime.Now,
                    NoteTypeId = StringTools.GetInt("NoteTypeId", ref formData)
                };
                note.TrainerNotes.Add(new TrainerNote
                {
                    TrainerId = trainerId
                });

                atlasDB.Notes.Add(note);
                atlasDB.SaveChanges();
            }
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }
    }
}