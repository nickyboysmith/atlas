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
    
    public partial class CourseClient
    {
        public CourseClient()
        {
            this.CourseClientRemoveds = new HashSet<CourseClientRemoved>();
        }
    
        public int Id { get; set; }
        public int CourseId { get; set; }
        public int ClientId { get; set; }
        public System.DateTime DateAdded { get; set; }
        public int AddedByUserId { get; set; }
        public Nullable<decimal> TotalPaymentDue { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public bool EmailReminderSent { get; set; }
        public bool SMSReminderSent { get; set; }
        public Nullable<decimal> TotalPaymentMade { get; set; }
        public Nullable<System.DateTime> PaymentDueDate { get; set; }
        public Nullable<System.DateTime> LastPaymentMadeDate { get; set; }
    
        public virtual Client Client { get; set; }
        public virtual Course Course { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
        public virtual ICollection<CourseClientRemoved> CourseClientRemoveds { get; set; }
    }
}