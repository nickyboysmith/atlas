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
    
    public partial class CourseLocked
    {
        public int Id { get; set; }
        public int CourseId { get; set; }
        public System.DateTime AfterDate { get; set; }
        public string Reason { get; set; }
        public int UpdatedByUserId { get; set; }
    
        public virtual Course Course { get; set; }
        public virtual User User { get; set; }
    }
}