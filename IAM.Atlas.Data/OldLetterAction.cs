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
    
    public partial class OldLetterAction
    {
        public OldLetterAction()
        {
            this.OldLetterTemplates = new HashSet<OldLetterTemplate>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
    
        public virtual ICollection<OldLetterTemplate> OldLetterTemplates { get; set; }
    }
}