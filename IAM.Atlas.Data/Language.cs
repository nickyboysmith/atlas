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
    
    public partial class Language
    {
        public Language()
        {
            this.OrganisationLanguage = new HashSet<OrganisationLanguage>();
            this.CourseInterpreterLanguages = new HashSet<CourseInterpreterLanguage>();
            this.InterpreterLanguages = new HashSet<InterpreterLanguage>();
        }
    
        public int Id { get; set; }
        public string EnglishName { get; set; }
        public string NativeName { get; set; }
        public string ISO_Code { get; set; }
        public Nullable<bool> Disabled { get; set; }
    
        public virtual ICollection<OrganisationLanguage> OrganisationLanguage { get; set; }
        public virtual ICollection<CourseInterpreterLanguage> CourseInterpreterLanguages { get; set; }
        public virtual ICollection<InterpreterLanguage> InterpreterLanguages { get; set; }
    }
}