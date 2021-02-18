using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class DocumentJSON
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Type { get; set; }
        public int FileSize { get; set; }
        public bool ClientCategory { get; set; }
        public bool TrainerCategory { get; set; }
        public bool CourseCategory { get; set; }
        public string FileName { get; set; }
        public bool MarkedForDeletion { get; set; }
        public bool Deleted { get; set; }
        public string FileContents { get; set; }
        public DateTime? LastModified { get; set; }
        public string UpdatedByName { get; set; }
    }
}
