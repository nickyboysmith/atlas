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
    
    public partial class ClientArchivedEmail
    {
        public int Id { get; set; }
        public System.DateTime DateTimeArchived { get; set; }
        public Nullable<System.DateTime> EmailCreationDate { get; set; }
        public Nullable<System.DateTime> EmailSentDate { get; set; }
        public string EmailSubject { get; set; }
        public string SendToAddress { get; set; }
    }
}