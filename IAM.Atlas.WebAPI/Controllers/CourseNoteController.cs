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
    public class CourseNoteController : AtlasBaseController 
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

        [Route("api/CourseNote/GetTypes")]
        public IEnumerable<CourseNoteType> GetTypes()
        {
            return atlasDB.CourseNoteType.ToList();
        }

        [Route("api/CourseNote/GetByCourseId/{Id}")]
        public IEnumerable<CourseNotesJSON> GetByCourseId(int Id)
        {
            return atlasDB.CourseNote.Where(n => n.CourseId == Id)
                //.Join(atlasDB.Users,
                //    courseNote => courseNote.CreatedByUserId,
                //    user => user.Id,
                //    (courseNote, user) => new { CourseNote = courseNote, User = user})  // note, user -> nu
                .Select(n => new CourseNotesJSON {
                    Date = n.DateCreated != null ? (DateTime) n.DateCreated : DateTime.Now,
                    Text = n.Note,
                    User = n.User.Name,
                    Type = n.CourseNoteType.Title
                })
                .OrderByDescending(
                    courseNotes => courseNotes.Date
                )
                .ToList();
        }

        // POST api/<controller>
        public void Post([FromBody] FormDataCollection formBody)
        {
            CourseNote courseNote = new CourseNote();
            var formData = formBody;
            courseNote.Note = StringTools.GetString("Note", ref formData);

            if (!string.IsNullOrEmpty(courseNote.Note))
            {
                courseNote.CreatedByUserId = StringTools.GetInt("UserId", ref formData);
                courseNote.CourseId = StringTools.GetInt("CourseId", ref formData);
                courseNote.DateCreated = DateTime.Now;
                courseNote.CourseNoteTypeId = StringTools.GetInt("NoteTypeId", ref formData);
                courseNote.OrganisationOnly = StringTools.GetBool("OrganisationOnly", ref formData);
                courseNote.Removed = false;

                atlasDB.CourseNote.Add(courseNote);
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