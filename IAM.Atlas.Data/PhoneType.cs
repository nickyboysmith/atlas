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
    
    public partial class PhoneType
    {
        public PhoneType()
        {
            this.ClientPhones = new HashSet<ClientPhone>();
            this.TrainerPhone = new HashSet<TrainerPhone>();
            this.InterpreterPhones = new HashSet<InterpreterPhone>();
        }
    
        public int Id { get; set; }
        public string Type { get; set; }
    
        public virtual ICollection<ClientPhone> ClientPhones { get; set; }
        public virtual ICollection<TrainerPhone> TrainerPhone { get; set; }
        public virtual ICollection<InterpreterPhone> InterpreterPhones { get; set; }
    }
}