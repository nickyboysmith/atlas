using IAM.Atlas.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseInterpreterController : AtlasBaseController
    {
        string nonDORSCourseMessage = "Not a DORS Course.";

        // GET api/<controller>/5
        public string Get()
        {
            return "value";
        }
        
        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formBody)   
        {

            var courseId = 0;
            var InterpreterId = 0;
            var userId = 0;

            // Try parse the CourseId
            if (Int32.TryParse(formBody["courseId"], out courseId)) {
            } else {
                return "There was an error verifying your course. Please retry.";
            }

            // Try parse the InterpreterId
            if (Int32.TryParse(formBody["InterpreterId"], out InterpreterId)) {
            } else {
                return "There was an error verifying the Interpreter. Please retry.";
            }

            // Try parse the UserId
            if (Int32.TryParse(formBody["userId"], out userId)) {
            } else {
                return "There was an error verifying the user. Please retry.";
            }

            var checkInterpreterExists = atlasDB.Interpreters.Any(theInterpreter => theInterpreter.Id == InterpreterId);
            if (!checkInterpreterExists) {
                return "There was an error verifying the Interpreter. Please retry.";
            }

            var checkCourseExists = atlasDB.Course.Any(theCourse => theCourse.Id == courseId);
            if (!checkCourseExists) {
                return "There was an error verifying your the course. Please retry.";
            }

            var courseInterpreters =
                atlasDB.CourseInterpreters.Where(
                    theInterpreter =>
                        theInterpreter.CourseId == courseId
                        && theInterpreter.InterpreterId == InterpreterId
                ).ToList();

            var courseDates =
                atlasDB.CourseDate.Where(cd =>
                        cd.CourseId == courseId).ToList();


            if (formBody["action"] == "selectedInterpretersForPractical")
            {
                if (courseInterpreters.Count == 0)
                {
                    foreach (var courseDate in courseDates)
                    {
                        CourseInterpreter newCourseInterpreter = new CourseInterpreter();
                        newCourseInterpreter.InterpreterId = InterpreterId;
                        newCourseInterpreter.CourseId = courseId;
                        newCourseInterpreter.CourseDateId = courseDate.Id;
                        newCourseInterpreter.DateCreated = DateTime.Now;
                        newCourseInterpreter.CreatedByUserId = userId;
                        newCourseInterpreter.BookedForPractical = true;
                        atlasDB.CourseInterpreters.Add(newCourseInterpreter);
                    }
                }
                else
                {
                    foreach (var courseInterpreter in courseInterpreters)
                    {
                        courseInterpreter.BookedForPractical = true;
                        atlasDB.CourseInterpreters.Attach(courseInterpreter);
                        var courseInterpreterEntry = atlasDB.Entry(courseInterpreter);
                        courseInterpreterEntry.State = System.Data.Entity.EntityState.Modified;
                    }
                }
            }
            else if (formBody["action"] == "selectedInterpretersForTheory")
            {
                if (courseInterpreters.Count == 0)
                {
                    foreach (var courseDate in courseDates)
                    {
                        CourseInterpreter newCourseInterpreter = new CourseInterpreter();
                        newCourseInterpreter.InterpreterId = InterpreterId;
                        newCourseInterpreter.CourseId = courseId;
                        newCourseInterpreter.CourseDateId = courseDate.Id;
                        newCourseInterpreter.DateCreated = DateTime.Now;
                        newCourseInterpreter.CreatedByUserId = userId;
                        newCourseInterpreter.BookedForTheory = true;

                        atlasDB.CourseInterpreters.Add(newCourseInterpreter);
                    }
                }
                else
                {
                    foreach (var courseInterpreter in courseInterpreters)
                    {
                        courseInterpreter.BookedForTheory = true;
                        atlasDB.CourseInterpreters.Attach(courseInterpreter);
                        var courseInterpreterEntry = atlasDB.Entry(courseInterpreter);
                        courseInterpreterEntry.State = System.Data.Entity.EntityState.Modified;
                    }
                }
            }
            else if (formBody["action"] == "availableInterpretersForPractical")
            {
                foreach (var courseInterpreter in courseInterpreters)
                {
                    if (courseInterpreter.BookedForTheory == false)
                    {
                        atlasDB.CourseInterpreters.Attach(courseInterpreter);
                        var courseInterpreterEntry = atlasDB.Entry(courseInterpreter);
                        courseInterpreterEntry.State = System.Data.Entity.EntityState.Deleted;
                    }
                    else
                    {
                        courseInterpreter.BookedForPractical = false;
                        atlasDB.CourseInterpreters.Attach(courseInterpreter);
                        var courseInterpreterEntry = atlasDB.Entry(courseInterpreter);
                        courseInterpreterEntry.State = System.Data.Entity.EntityState.Modified;
                    }
                }
            }
            else if (formBody["action"] == "availableInterpretersForTheory")
            {
                foreach (var courseInterpreter in courseInterpreters)
                {
                    if (courseInterpreter.BookedForPractical == false)
                    {
                        atlasDB.CourseInterpreters.Attach(courseInterpreter);
                        var courseInterpreterEntry = atlasDB.Entry(courseInterpreter);
                        courseInterpreterEntry.State = System.Data.Entity.EntityState.Deleted;
                    }
                    else
                    {
                        courseInterpreter.BookedForTheory = false;
                        atlasDB.CourseInterpreters.Attach(courseInterpreter);
                        var courseInterpreterEntry = atlasDB.Entry(courseInterpreter);
                        courseInterpreterEntry.State = System.Data.Entity.EntityState.Modified;
                    }
                }
            }


            atlasDB.SaveChanges();

            var message = "Interpreters updated.";

            return message;
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