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
    
    public partial class FreqAskedQuestionOwner
    {
        public int Id { get; set; }
        public Nullable<int> OrganistionId { get; set; }
        public Nullable<int> FreqAskedQuestionId { get; set; }
        public Nullable<bool> OwnedByAtlas { get; set; }
    
        public virtual FreqAskedQuestion FreqAskedQuestion { get; set; }
    }
}
