using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class VenueImageMapJSON
    {
        public string OriginalFileName { get; set; }
        public string FileName { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int OrganisationId { get; set; }
        public int VenueId { get; set; }
        public int UserId { get; set; }
        public int DocumentId { get; set; }
    }
}
