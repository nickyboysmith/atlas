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
    
    public partial class vwTaskCategory
    {
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int TaskCategoryId { get; set; }
        public string TaskCategoryTitle { get; set; }
        public string TaskCategoryDescription { get; set; }
        public bool TaskCategoryDisabled { get; set; }
        public string TaskCategoryColourName { get; set; }
        public Nullable<bool> TaskEditableByOrganisation { get; set; }
    }
}
