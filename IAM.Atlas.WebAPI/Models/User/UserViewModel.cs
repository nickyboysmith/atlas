using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class CurrentUserJSON
    {
        public string userId { get; set; }
        public string name { get; set; }
        public string loginStatus { get; set; }
        public AdminMenuGroup[] adminMenuGroups { get; set; }
    }

    public class CurrentUserRolesJSON
    {
        public int UserId { get; set; }
        public bool IsSystemAdministrator { get; set; }
        public bool IsAdministrator { get; set; }
        public bool IsOrgUser { get; set; }
        public bool IsSupportStaff { get; set; }
        public bool IsClient { get; set; }
        public bool IsTrainer { get; set; }
        public string OrganisationName { get; set; }
        public int OrganisationId { get; set; }
    }

    public class CurrentUserExtendedRolesJSON
    {
        public int UserId { get; set; }
        public bool IsAllowedAccessToTaskPanel { get; set; }
        public bool IsAllowedToCreateTasks { get; set; }
        public bool CanSeeMeters { get; set; }
    }

    public class AdminMenuGroup
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public AdminMenuItem[] adminMenuItems { get; set; }
    }

    public class AdminMenuItem
    {              
        public string Title { get; set; }
        public string Description { get; set; }
        public string Modal { get; set; }
        public string Disabled { get; set; }
        public string Url { get; set; }
        public string Controller { get; set; }
        public string Parameters { get; set; }
        public string Class { get; set; }
    }

}