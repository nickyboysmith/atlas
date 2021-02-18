using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class OldLetterTemplateJSON
    {
        public int Id { get; set; }
        public string FileName { get; set; }
        public string Title { get; set; }
        public string Notes { get; set; }
        public string ActionName { get; set; }
        public int? ActionId { get; set; }
        public int? DocumentTemplateId { get; set; }
        public DateTime? LastUpdated { get; set; }
    }
}