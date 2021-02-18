using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class NoteJSON
    {
        public int NoteId { get; set; }
        public string Text { get; set; }
        public string NoteTypeName { get; set; }
    }
}
