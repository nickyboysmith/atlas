using System;
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is used to return a light weight serialized JSON object to client views
    /// 
    /// </summary>
    public class ClientLockJSON
    {
        public int ClientId { get; set; }
        public bool IsReadOnly { get; set; }
        public bool IsLockedByCurrentUser { get; set; }
        public string LockedByUserName { get; set; }
    }
}