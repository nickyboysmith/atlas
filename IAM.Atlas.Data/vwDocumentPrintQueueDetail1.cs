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
    
    public partial class vwDocumentPrintQueueDetail1
    {
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int DocumentId { get; set; }
        public string Document { get; set; }
        public Nullable<System.DateTime> DocumentDateAdded { get; set; }
        public string DocumentType { get; set; }
        public string QueueInformation { get; set; }
        public int CreatedByUserId { get; set; }
        public string CreatedByUser { get; set; }
    }
}
