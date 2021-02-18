using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models.UserSearchHistoryJSON
{
    public class UserSearchHistoryJSON
    {
        public string interfaceId { get; set; }
        public string creationDate { get; set; }
        public string name { get; set; }
        public string value { get; set; }
    }
}