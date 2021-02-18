using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System.Data.Entity;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class TaskCategoryController : AtlasBaseController
    {
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/taskCategory/getTaskCategoryByOrganisation/{OrganisationId}")]
        public List<vwTaskCategory> GetTaskCategoryByOrganisation(int OrganisationId)
        {
            var taskCategoryList = atlasDBViews.vwTaskCategories.Where(tc => tc.OrganisationId == OrganisationId).ToList();
            return taskCategoryList;
        }

        [HttpPost]
        [AuthorizationRequired]
        [Route("api/taskCategory/savetaskCategory")]
        public string SaveTaskCategory([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var TaskCategoryId = StringTools.GetInt("TaskCategoryId", ref formData);
            var TaskCategoryTitle = StringTools.GetString("TaskCategoryTitle", ref formData);
            var TaskCategoryDescription = StringTools.GetString("TaskCategoryDescription", ref formData);
            var TaskCategoryDisabled = StringTools.GetBool("TaskCategoryDisabled", ref formData);
            var TaskCategoryColourName = StringTools.GetString("TaskCategoryColourName", ref formData);
            var UpdatedByUserId = StringTools.GetInt("UpdatedByUserId", ref formData);
            var TaskEditableByOrganisation = StringTools.GetBool("TaskEditableByOrganisation", ref formData);

            string status = "";

            if (TaskEditableByOrganisation)
            {

                TaskCategory taskCategory = atlasDB.TaskCategories.Find(TaskCategoryId);

                if (taskCategory != null)
                {
                    try
                    {
                        atlasDB.TaskCategories.Attach(taskCategory);
                        var entry = atlasDB.Entry(taskCategory);

                        taskCategory.Title = TaskCategoryTitle;
                        atlasDB.Entry(taskCategory).Property("Title").IsModified = true;

                        taskCategory.Description = TaskCategoryDescription;
                        atlasDB.Entry(taskCategory).Property("Description").IsModified = true;

                        taskCategory.Disabled = TaskCategoryDisabled;
                        atlasDB.Entry(taskCategory).Property("Disabled").IsModified = true;

                        taskCategory.UpdatedByUserId = UpdatedByUserId;
                        atlasDB.Entry(taskCategory).Property("UpdatedByUserId").IsModified = true;

                        taskCategory.DateUpdated = DateTime.Now;
                        atlasDB.Entry(taskCategory).Property("DateUpdated").IsModified = true;

                        atlasDB.SaveChanges();

                        status = "Task Category Saved Successfully";
                    }

                    catch (Exception ex)
                    {
                        status = "There was an error with our service. If the problem persists please contact support";
                    }
                }
            }
            else
            {
                status = "This Task Category should not be editable.";
            }


            return status;
        }


        [HttpPost]
        [AuthorizationRequired]
        [Route("api/taskCategory/addTaskCategory")]
        public string AddTaskCategory([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var TaskCategoryTitle = StringTools.GetString("TaskCategoryTitle", ref formData);
            var TaskCategoryDescription = StringTools.GetString("TaskCategoryDescription", ref formData);
            var TaskCategoryDisabled = StringTools.GetBool("TaskCategoryDisabled", ref formData);
            var TaskCategoryColourName = StringTools.GetString("TaskCategoryColourName", ref formData);
            var CreatedByUserId = StringTools.GetInt("CreatedByUserId", ref formData);
            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            

            string status = "";

            try
            {
                if (!string.IsNullOrEmpty(TaskCategoryTitle) || !string.IsNullOrEmpty(TaskCategoryTitle))
                {
                    // create then add to taskcategory object
                    TaskCategory taskCategory = new TaskCategory();

                    taskCategory.Title = TaskCategoryTitle;
                    taskCategory.Description = TaskCategoryDescription;
                    taskCategory.Disabled = TaskCategoryDisabled;

                    taskCategory.ColourName = TaskCategoryColourName;

                    taskCategory.CreatedByUserId = CreatedByUserId;
                    taskCategory.DateCreated = DateTime.Now;
                    atlasDB.TaskCategories.Add(taskCategory);
                    
                    // create then add to taskcategoryfororganisation object
                    TaskCategoryForOrganisation taskCategoryForOrganisation = new TaskCategoryForOrganisation();

                    taskCategoryForOrganisation.TaskCategoryId = taskCategory.Id;
                    taskCategoryForOrganisation.OrganisationId = OrganisationId;

                    atlasDB.TaskCategoryForOrganisations.Add(taskCategoryForOrganisation);

                    atlasDB.SaveChanges();

                    status = "Task Category Saved Successfully";
                }
                else
                {
                    status = "Task Title or Description is empty.";
                }
            }
            catch (Exception ex)
            {
                status = "There was an error with our service. If the problem persists please contact support";
            }


            return status;
        }
    }
}