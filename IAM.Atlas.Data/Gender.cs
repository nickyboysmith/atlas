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
    
    public partial class Gender
    {
        public Gender()
        {
            this.Trainers = new HashSet<Trainer>();
            this.Interpreters = new HashSet<Interpreter>();
            this.Users = new HashSet<User>();
            this.Clients = new HashSet<Client>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
    
        public virtual ICollection<Trainer> Trainers { get; set; }
        public virtual ICollection<Interpreter> Interpreters { get; set; }
        public virtual ICollection<User> Users { get; set; }
        public virtual ICollection<Client> Clients { get; set; }
    }
}
