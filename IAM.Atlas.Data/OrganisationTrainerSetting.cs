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
    
    public partial class OrganisationTrainerSetting
    {
        public int Id { get; set; }
        public int OrganisationId { get; set; }
        public bool AutoGenerateTrainerCourseReference { get; set; }
        public bool LetAtlasSystemGenerateUniqueNumber { get; set; }
        public bool ReferencesStartWithCourseTypeCode { get; set; }
        public string StartAllReferencesWith { get; set; }
        public bool ReferenceEditable { get; set; }
        public System.DateTime DateCreated { get; set; }
        public int CreatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
    
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
    }
}
