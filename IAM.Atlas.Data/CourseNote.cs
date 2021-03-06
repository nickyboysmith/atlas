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
    
    public partial class CourseNote
    {
        public int Id { get; set; }
        public int CourseId { get; set; }
        public int CourseNoteTypeId { get; set; }
        public string Note { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public int CreatedByUserId { get; set; }
        public Nullable<bool> Removed { get; set; }
        public bool OrganisationOnly { get; set; }
    
        public virtual CourseNoteType CourseNoteType { get; set; }
        public virtual Course Course { get; set; }
        public virtual User User { get; set; }
    }
}
