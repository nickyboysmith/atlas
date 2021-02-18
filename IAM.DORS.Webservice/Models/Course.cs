using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.DORS.Webservice.Models
{
    public class Course
    {
        public int Availability { get; set; }
        public int Capacity { get; set; }
        public DateTime DateTime { get; set; }
        public int Id { get; set; }
        public string Title { get; set; }
        public int ForceContractId { get; set; }
        public int SiteId { get; set; }
        public string TutorForename { get; set; }
        public string TutorSurname { get; set; }
        public List<TrainerLicence> TrainerList { get; set; }
        public int[] AttendeeList { get; set; }
    }
}
