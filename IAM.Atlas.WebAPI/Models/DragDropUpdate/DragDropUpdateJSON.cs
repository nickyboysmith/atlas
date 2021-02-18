using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    /// <summary>
    /// This class is the format used by the dragDropUpdate shared controller in the front end for displaying 
    /// the items in the multiselect list boxes.
    /// 
    /// Used so server side code doesn't just return an object.
    /// </summary>
    public class DragDropUpdateJSON
    {
        public int Id { get; set; }
        public string Name { get; set; }

        public DragDropUpdateJSON()
        {

        }

        public DragDropUpdateJSON(int Id, string Name)
        {
            this.Id = Id;
            this.Name = Name;
        }
    }
}