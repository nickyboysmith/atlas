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
    
    public partial class TrainerNote
    {
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public int NoteId { get; set; }
    
        public virtual Trainer Trainer { get; set; }
        public virtual Note Note { get; set; }
    }
}
