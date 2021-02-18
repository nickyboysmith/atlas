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
    
    public partial class Interpreter
    {
        public Interpreter()
        {
            this.CourseInterpreters = new HashSet<CourseInterpreter>();
            this.InterpreterEmails = new HashSet<InterpreterEmail>();
            this.InterpreterLanguages = new HashSet<InterpreterLanguage>();
            this.InterpreterLocations = new HashSet<InterpreterLocation>();
            this.InterpreterNotes = new HashSet<InterpreterNote>();
            this.InterpreterOrganisations = new HashSet<InterpreterOrganisation>();
            this.InterpreterPhones = new HashSet<InterpreterPhone>();
            this.InterpreterAvailabilityDates = new HashSet<InterpreterAvailabilityDate>();
        }
    
        public int Id { get; set; }
        public string Title { get; set; }
        public string FirstName { get; set; }
        public string Surname { get; set; }
        public string OtherNames { get; set; }
        public string DisplayName { get; set; }
        public Nullable<System.DateTime> DateOfBirth { get; set; }
        public int GenderId { get; set; }
        public bool Disabled { get; set; }
        public System.DateTime DateCreated { get; set; }
        public int CreatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
    
        public virtual ICollection<CourseInterpreter> CourseInterpreters { get; set; }
        public virtual Gender Gender { get; set; }
        public virtual ICollection<InterpreterEmail> InterpreterEmails { get; set; }
        public virtual ICollection<InterpreterLanguage> InterpreterLanguages { get; set; }
        public virtual ICollection<InterpreterLocation> InterpreterLocations { get; set; }
        public virtual ICollection<InterpreterNote> InterpreterNotes { get; set; }
        public virtual ICollection<InterpreterOrganisation> InterpreterOrganisations { get; set; }
        public virtual ICollection<InterpreterPhone> InterpreterPhones { get; set; }
        public virtual ICollection<InterpreterAvailabilityDate> InterpreterAvailabilityDates { get; set; }
    }
}