using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class UserJSON
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string LoginId { get; set; }
        public string Email { get; set; }
    }
}
