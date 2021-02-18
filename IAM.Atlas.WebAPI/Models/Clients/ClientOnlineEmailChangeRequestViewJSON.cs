using System;
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is used to return a light weight serialized JSON object to Client Online Email Change Request views
    /// 
    /// </summary>
    public class ClientOnlineEmailChangeRequestViewJSON
    {
        public int Id { get; set; }
        public int ClientId { get; set; }
        public string NewEmailAddress { get; set; }
        public string PreviousEmailAddress { get; set; }
        public bool EmailUpdated { get; set; }
        public string Status { get;  set; }
    }
}