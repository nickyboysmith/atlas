using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{

    public class NotificationJSON
    {
        public MessageCategoryJSON[] messageCategory { get; set; }
    }

    public class MessageCategoryJSON
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string CategoryColour { get; set; }
        public MessageJSON[] message { get; set; }
    }

    public class MessageJSON
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<bool> AllUsers { get; set; }
        public DateTime DateSent { get; set; }
        public DateTime DateAcknowledged { get; set; }
    }
    
    //public class MessageJSON
    //{
    //    public int Id { get; set; }
    //    public string Title { get; set; }
    //    public string Content { get; set; }
    //    public Nullable<bool> Disabled { get; set; }
    //    public Nullable<bool> AllUsers { get; set; }
    //    public int CategoryId { get; set; }
    //    public string CategoryName { get; set; }
    //    public string CategoryColour { get; set; }
    //    public DateTime DateSent { get; set; }
    //    public DateTime DateAcknowledged { get; set; }
    //}

    //public class MessageCategoryJSON
    //{
    //    public int CategoryId { get; set; }
    //    public string CategoryName { get; set; }
    //    public string CategoryColour { get; set; }
    //}

}