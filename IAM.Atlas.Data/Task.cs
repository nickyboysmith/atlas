//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace IAM.Atlas.Data
{
    using System;
    using System.Collections.Generic;
    
    public partial class Task
    {
        public Task()
        {
            this.TaskCompletedForUsers = new HashSet<TaskCompletedForUser>();
            this.TaskForOrganisations = new HashSet<TaskForOrganisation>();
            this.TaskForUsers = new HashSet<TaskForUser>();
            this.TaskNotes = new HashSet<TaskNote>();
            this.TaskRelatedToClients = new HashSet<TaskRelatedToClient>();
            this.TaskRelatedToCourses = new HashSet<TaskRelatedToCourse>();
            this.TaskRelatedToTrainers = new HashSet<TaskRelatedToTrainer>();
            this.TaskRemovedFromOrganisations = new HashSet<TaskRemovedFromOrganisation>();
            this.TaskRemovedFromUsers = new HashSet<TaskRemovedFromUser>();
        }
    
        public int Id { get; set; }
        public int TaskCategoryId { get; set; }
        public string Title { get; set; }
        public Nullable<int> PriorityNumber { get; set; }
        public System.DateTime DateCreated { get; set; }
        public int CreatedByUserId { get; set; }
        public Nullable<System.DateTime> DeadlineDate { get; set; }
        public bool TaskClosed { get; set; }
        public Nullable<int> ClosedByUserId { get; set; }
        public Nullable<System.DateTime> DateClosed { get; set; }
    
        public virtual TaskCategory TaskCategory { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
        public virtual ICollection<TaskCompletedForUser> TaskCompletedForUsers { get; set; }
        public virtual ICollection<TaskForOrganisation> TaskForOrganisations { get; set; }
        public virtual ICollection<TaskForUser> TaskForUsers { get; set; }
        public virtual ICollection<TaskNote> TaskNotes { get; set; }
        public virtual ICollection<TaskRelatedToClient> TaskRelatedToClients { get; set; }
        public virtual ICollection<TaskRelatedToCourse> TaskRelatedToCourses { get; set; }
        public virtual ICollection<TaskRelatedToTrainer> TaskRelatedToTrainers { get; set; }
        public virtual ICollection<TaskRemovedFromOrganisation> TaskRemovedFromOrganisations { get; set; }
        public virtual ICollection<TaskRemovedFromUser> TaskRemovedFromUsers { get; set; }
    }
}
