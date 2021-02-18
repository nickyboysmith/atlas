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
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class TrainerCourseTypeCategoryController : AtlasBaseController
    {




        /// <summary>
        /// Processes the adding and removing of CourseTypes to Trainers
        /// </summary>
        /// <param name="formBody"></param>
        /// <returns></returns>
        // POST api/<controller>
        public string Post([FromBody] FormDataCollection formBody)
        {
            var status = "";
            var trainerId = 0;
            var formData = formBody;
            var courseTypeName = StringTools.GetString("courseTypeName", ref formData);
            if (!string.IsNullOrEmpty(courseTypeName))
            {
                if (int.TryParse(formBody["trainerId"], out trainerId)) {
                    try {
                        var practical = false;
                        var theory = false;
                        if (courseTypeName.EndsWith(" (Theory)")) {
                            theory = true;
                        }
                        else if(courseTypeName.EndsWith(" (Practical)"))
                        {
                            practical = true;
                        }
                        //
                        if (formBody["action"] == "add")
                        {
                            var courseTypeId = 0;
                            if (int.TryParse(formBody["courseTypeId"], out courseTypeId)) {
                                
                                // is there an existing trainerCourseType entry that is storing the trainer's theory and practical records?
                                TrainerCourseType trainerCourseType = atlasDB.TrainerCourseType
                                                                        .Where(tct => tct.TrainerId == trainerId && tct.CourseTypeId == courseTypeId)
                                                                        .FirstOrDefault();

                                if (trainerCourseType == null)  // no existing record
                                {
                                    trainerCourseType = new TrainerCourseType();
                                    trainerCourseType.CourseTypeId = courseTypeId;
                                    trainerCourseType.TrainerId = trainerId;
                                    if (practical)
                                    {
                                        trainerCourseType.ForPractical = true;
                                    }
                                    if (theory)
                                    {
                                        trainerCourseType.ForTheory = true;
                                    }
                                    atlasDB.TrainerCourseType.Add(trainerCourseType);
                                }
                                else
                                {
                                    if (practical)
                                    {
                                        trainerCourseType.ForPractical = true;
                                    }
                                    if (theory)
                                    {
                                        trainerCourseType.ForTheory = true;
                                    }
                                    var entry = atlasDB.Entry(trainerCourseType);
                                    entry.State = System.Data.Entity.EntityState.Modified;
                                }
                            }
                            else {
                                status = "No associated courseTypeId";
                            }
                        }

                        // 
                        if (formBody["action"] == "remove")
                        {
                            var courseTypeId = 0;
                            var userId = 0;

                            if (int.TryParse(formBody["courseTypeId"], out courseTypeId)) {
                                if (int.TryParse(formBody["userId"], out userId)) {
                                    TrainerCourseType trainerCourseType = atlasDB.TrainerCourseType
                                                                        .Where(tct => tct.TrainerId == trainerId && tct.CourseTypeId == courseTypeId)
                                                                        .FirstOrDefault();
                                    if (trainerCourseType != null)
                                    {
                                        if (practical)
                                        {
                                            trainerCourseType.ForPractical = false;
                                        }
                                        if (theory)
                                        {
                                            trainerCourseType.ForTheory = false;
                                        }
                                        var dbEntry = atlasDB.Entry(trainerCourseType);
                                        if (trainerCourseType.ForTheory || trainerCourseType.ForPractical)
                                        {
                                            // we need to update the record.
                                            dbEntry.State = System.Data.Entity.EntityState.Modified;
                                        }
                                        else
                                        {
                                            // both forTheory and forPractical are false so we can delete the record.
                                            dbEntry.State = System.Data.Entity.EntityState.Deleted;
                                        }
                                    }
                                    else
                                    {
                                        status = "Course Type couldn't be found.";
                                    }
                                }
                                else {
                                    status = "No associated userId";
                                }
                            }
                            else {
                                status = "No associated courseTypeId";
                            }
                        }

                        atlasDB.SaveChanges();

                        status = "success";

                    }
                    catch (DbEntityValidationException ex) {
                        status = "There has been an error saving your details: " + ex.Message;
                    }
                }
                else {
                    status = "Trainer Id was not a number.";
                }
            }
            else
            {
                status = "Course Type name couldn't be found.";
            }
            return status;
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