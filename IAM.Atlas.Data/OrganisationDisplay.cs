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
    
    public partial class OrganisationDisplay
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string DisplayName { get; set; }
        public int OrganisationId { get; set; }
        public Nullable<bool> HasLogo { get; set; }
        public Nullable<bool> ShowLogo { get; set; }
        public string LogoAlignment { get; set; }
        public Nullable<bool> ShowDisplayName { get; set; }
        public string DisplayNameAlignment { get; set; }
        public Nullable<bool> HasBorder { get; set; }
        public string BorderColour { get; set; }
        public string BackgroundColour { get; set; }
        public string FontColour { get; set; }
        public int SystemFontId { get; set; }
        public int ChangedByUserId { get; set; }
        public Nullable<System.DateTime> DateChanged { get; set; }
        public string ImageFilePath { get; set; }
    
        public virtual Organisation Organisation { get; set; }
        public virtual SystemFont SystemFont { get; set; }
        public virtual User User { get; set; }
    }
}
