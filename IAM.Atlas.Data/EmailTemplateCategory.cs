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
    
    public partial class EmailTemplateCategory
    {
        public EmailTemplateCategory()
        {
            this.EmailTemplates = new HashSet<EmailTemplate>();
            this.EmailTemplateCategoryColumns = new HashSet<EmailTemplateCategoryColumn>();
        }
    
        public int Id { get; set; }
        public string Code { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int DataViewId { get; set; }
    
        public virtual DataView DataView { get; set; }
        public virtual ICollection<EmailTemplate> EmailTemplates { get; set; }
        public virtual ICollection<EmailTemplateCategoryColumn> EmailTemplateCategoryColumns { get; set; }
    }
}