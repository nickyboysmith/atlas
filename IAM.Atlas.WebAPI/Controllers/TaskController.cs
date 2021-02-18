using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using IAM.Atlas.Data;
using System.Web.Http;
using System.Data.Entity;
using System.Net.Http.Formatting;
using System.Web.Http.ModelBinding;


namespace IAM.Atlas.WebAPI.Controllers
{
    public class TaskController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/task/getTaskSummaryByUser/{UserId}")]
        public List<vwTaskSummaryByUser> GetTaskSummaryByUser(int UserId)
        {
            var taskSummaryList = atlasDBViews.vwTaskSummaryByUsers.Where(ts => ts.UserId == UserId).ToList();
            return taskSummaryList;
        }

        [HttpGet]
        [Route("api/task/GetTasksByOrganisationAndUser/{OrganisationId}/{UserId}")]
        public List<vwTaskByOrganisationAndUser> GetTasksByOrganisationAndUser(int OrganisationId, int UserId)
        {
            var tasks = atlasDBViews.vwTaskByOrganisationAndUsers
                                .Where(t => t.UserId == UserId)
                                .ToList();
            return tasks;
        }

        [HttpGet]
        [Route("api/task/CompletedTask/{taskId}/{taskForUserId}/{completedByUserId}")]
        public int CompletedTask(int taskId, int taskForUserId, int completedByUserId)
        {
            var completedTask = new TaskCompletedForUser();
            completedTask.TaskId = taskId;
            completedTask.CompletedByUserId = completedByUserId;
            completedTask.UserId = taskForUserId;
            completedTask.DateCompleted = DateTime.Now;
            atlasDB.TaskCompletedForUsers.Add(completedTask);
            atlasDB.SaveChanges();
            return completedTask.Id;
        }

        [HttpGet]
        [Route("api/task/AssignTaskToUser/{TaskId}/{UserId}/{AssigningUserId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="TaskId"></param>
        /// <param name="UserId"></param>
        /// <param name="AssigningUserId"></param>
        /// <returns>true if successful, exception if not</returns>
        public bool AssignTaskToUser(int TaskId, int UserId, int AssigningUserId)
        {
            
            // check that the task isn't already assigned to this user
            var alreadyExistingTaskForUser = atlasDB.TaskForUsers
                                                    .Where(tfu => tfu.TaskId == TaskId && tfu.UserId == UserId)
                                                    .FirstOrDefault();
            if (alreadyExistingTaskForUser == null)
            {
                // create an entry into taskremovedfromuser for the assigning user id
                // TODO: should we only do this when not an org admin user?
                var taskRemovedFromUser = new TaskRemovedFromUser();
                taskRemovedFromUser.DateRemoved = DateTime.Now;
                taskRemovedFromUser.RemovedByUserId = AssigningUserId;
                taskRemovedFromUser.TaskId = TaskId;
                taskRemovedFromUser.UserId = AssigningUserId;

                var taskForUser = new TaskForUser();
                taskForUser.UserId = UserId;
                taskForUser.TaskId = TaskId;
                taskForUser.AssignedByUserId = AssigningUserId;
                taskForUser.DateAdded = DateTime.Now;
                try
                {
                    atlasDB.TaskRemovedFromUsers.Add(taskRemovedFromUser);
                    atlasDB.TaskForUsers.Add(taskForUser);
                    atlasDB.SaveChanges();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
            else
            {
                throw new Exception("This task already has this user assigned to it.");
            }
            
            return true;
        }

        [HttpPost]
        [Route("api/task")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="formBody"></param>
        /// <returns>The id of the newly added task entity</returns>
        public int Post([FromBody] FormDataCollection formBody)
        {
            var id = -1;
            var addTaskForm = formBody.ReadAs<AddTaskForm>();
            try
            {
                if (addTaskForm.valid())
                {
                    var task = new Task();
                    task.Title = addTaskForm.Title;
                    task.DateCreated = DateTime.Now;
                    task.DeadlineDate = addTaskForm.DeadlineDate;
                    task.PriorityNumber = addTaskForm.PriorityNumber;
                    task.TaskCategoryId = addTaskForm.TaskCategoryId;
                    task.CreatedByUserId = addTaskForm.CreatedByUserId;
                    task.TaskClosed = false;
                    if(addTaskForm.OrganisationId != null)
                    {
                        var taskForOrganisation = new TaskForOrganisation();
                        taskForOrganisation.OrganisationId = (int) addTaskForm.OrganisationId;
                        task.TaskForOrganisations.Add(taskForOrganisation);
                    }
                    else
                    {
                        if (addTaskForm.TaskAssignedToUserId != null)
                        {
                            var taskForUser = new TaskForUser();
                            taskForUser.AssignedByUserId = addTaskForm.CreatedByUserId;
                            taskForUser.DateAdded = DateTime.Now;
                            taskForUser.UserId = (int) addTaskForm.TaskAssignedToUserId;
                            task.TaskForUsers.Add(taskForUser);
                        }
                    }
                    if (!string.IsNullOrEmpty(addTaskForm.Notes))
                    {
                        var note = new Note();
                        var taskNote = new TaskNote();

                        note.DateCreated = DateTime.Now;
                        note.CreatedByUserId = addTaskForm.CreatedByUserId;
                        note.Note1 = addTaskForm.Notes;
                        taskNote.Note = note;
                        task.TaskNotes.Add(taskNote);
                    }
                    if(addTaskForm.TaskRelatedToClientId != null)
                    {
                        var taskRelatedToClient = new TaskRelatedToClient();
                        taskRelatedToClient.ClientId = (int)addTaskForm.TaskRelatedToClientId;
                        task.TaskRelatedToClients.Add(taskRelatedToClient);
                    }
                    if(addTaskForm.TaskRelatedToCourseId != null)
                    {
                        var taskRelatedToCourse = new TaskRelatedToCourse();
                        taskRelatedToCourse.CourseId = (int)addTaskForm.TaskRelatedToCourseId;
                        task.TaskRelatedToCourses.Add(taskRelatedToCourse);
                    }
                    if (addTaskForm.TaskRelatedToTrainerId != null)
                    {
                        var taskRelatedToTrainer = new TaskRelatedToTrainer();
                        taskRelatedToTrainer.TrainerId = (int)addTaskForm.TaskRelatedToTrainerId;
                        task.TaskRelatedToTrainers.Add(taskRelatedToTrainer);
                    }
                    
                    atlasDB.Tasks.Add(task);
                    atlasDB.SaveChanges();

                    id = task.Id;
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return id;
        }

        /// <summary>
        /// This is the "add task" form's data (UI project) as an object
        /// </summary>
        class AddTaskForm
        {
            public string Title { get; set; }
            public DateTime? DeadlineDate {get;set;}
            public string DeadlineTime { get; set; }
            public int? PriorityNumber { get; set; }
            public int TaskCategoryId { get; set; }
            public int CreatedByUserId { get; set; }
            public int? OrganisationId { get; set; }
            public int? TaskAssignedToUserId { get; set; }
            public int? TaskRelatedToClientId { get; set; }
            public int? TaskRelatedToCourseId { get; set; }
            public int? TaskRelatedToTrainerId { get; set; }
            public string Notes { get; set; }

            // is the form valid?
            public bool valid()
            {
                string errorMessage = "";
                if (TaskCategoryId < 0)
                {
                    errorMessage = "Please choose a Task Category.";
                }
                else
                {
                    if (string.IsNullOrEmpty(Title))
                    {
                        errorMessage = "Please enter a title.";
                    }
                    else
                    {
                        if (Title.Length < 4)
                        {
                            errorMessage = "Please enter a longer title.";
                        }
                        else
                        {
                            if (CreatedByUserId < 0)
                            {
                                errorMessage = "Creating User Id not passed through.";
                            }
                            else 
                            {
                                if (OrganisationId == null && TaskAssignedToUserId == null)
                                {
                                    errorMessage = "Not an Organisation Task or a User task.";
                                }
                                else
                                {
                                    if(OrganisationId != null && TaskAssignedToUserId != null)
                                    {
                                        errorMessage = "Not an Organisation Task or a User task.";
                                    }
                                }
                            }
                        }
                        
                    }
                }
                if (!string.IsNullOrEmpty(errorMessage))
                {
                    throw new Exception(errorMessage);
                }
                return true;
            }
        }
    }
}