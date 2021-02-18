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
    
    public partial class SMSService
    {
        public SMSService()
        {
            this.OrganisationPreferredSMSServices = new HashSet<OrganisationPreferredSMSService>();
            this.SMSServiceNotes = new HashSet<SMSServiceNote>();
            this.SMSServiceCredentials = new HashSet<SMSServiceCredential>();
            this.ScheduledSMS = new HashSet<ScheduledSM>();
            this.SMSServiceSendingFailures = new HashSet<SMSServiceSendingFailure>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<System.DateTime> DateLastUsed { get; set; }
    
        public virtual ICollection<OrganisationPreferredSMSService> OrganisationPreferredSMSServices { get; set; }
        public virtual ICollection<SMSServiceNote> SMSServiceNotes { get; set; }
        public virtual ICollection<SMSServiceCredential> SMSServiceCredentials { get; set; }
        public virtual ICollection<ScheduledSM> ScheduledSMS { get; set; }
        public virtual ICollection<SMSServiceSendingFailure> SMSServiceSendingFailures { get; set; }
    }
}
