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
    
    public partial class FreqAskedQuestion
    {
        public FreqAskedQuestion()
        {
            this.FreqAskedQuestionAnswers = new HashSet<FreqAskedQuestionAnswer>();
            this.FreqAskedQuestionGroupItems = new HashSet<FreqAskedQuestionGroupItem>();
            this.FreqAskedQuestionOwners = new HashSet<FreqAskedQuestionOwner>();
        }
    
        public int Id { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public Nullable<int> CreatedByUserId { get; set; }
        public Nullable<bool> Disabled { get; set; }
    
        public virtual ICollection<FreqAskedQuestionAnswer> FreqAskedQuestionAnswers { get; set; }
        public virtual ICollection<FreqAskedQuestionGroupItem> FreqAskedQuestionGroupItems { get; set; }
        public virtual ICollection<FreqAskedQuestionOwner> FreqAskedQuestionOwners { get; set; }
        public virtual User User { get; set; }
    }
}
