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
    
    public partial class NetcallPayment
    {
        public int Id { get; set; }
        public int NetcallRequestId { get; set; }
        public Nullable<int> PaymentId { get; set; }
    
        public virtual NetcallRequest NetcallRequest { get; set; }
        public virtual Payment Payment { get; set; }
    }
}
