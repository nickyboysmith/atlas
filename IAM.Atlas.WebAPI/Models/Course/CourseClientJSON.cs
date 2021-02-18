using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class CourseClientJSON
    {
        public string ClientId { get; set; }
        public string ClientTitle { get; set; }
        public string ClientName { get; set; }
        public DateTime DateAdded { get; set; }
        public string AddedByUser { get; set; }
        public decimal TotalAmountPaid { get; set; }
        public DateTime? LastPaymentDate { get; set; }
        public decimal Outstanding { get; set; }


        public CourseClientJSON(Data.vwClientsWithinCourse clientCourseData)
        {
            ClientId = clientCourseData.ClientId.ToString();
            ClientTitle = clientCourseData.ClientTitle;
            ClientName = clientCourseData.ClientName;
            DateAdded = clientCourseData.DateClientAdded;
            if (clientCourseData.OnlineBooking == true)
            {
                AddedByUser = "Online Client";
            }
            else
            {
                AddedByUser = clientCourseData.ClientAddedByUser;
            }
            TotalAmountPaid = clientCourseData.TotalAmountPaidByClient.HasValue ? clientCourseData.TotalAmountPaidByClient.Value : (decimal)0.00;
            if (clientCourseData.ClientLastPaymentDate.HasValue)
            {
                LastPaymentDate = (DateTime)clientCourseData.ClientLastPaymentDate.Value;
            }
            Outstanding = clientCourseData.ClientAmountOutstanding.HasValue ? clientCourseData.ClientAmountOutstanding.Value : (decimal)0.00;
        }

        public CourseClientJSON(Data.CourseClient courseClient, IEnumerable<Data.CourseClientPayment> courseClientPayments)
        {
            ClientId = courseClient.Client.Id.ToString();
            ClientTitle = courseClient.Client.Title;
            ClientName = courseClient.Client.DisplayName;
            DateAdded = courseClient.DateAdded;
            AddedByUser = courseClient.User.Name;
            if (courseClientPayments != null && courseClientPayments.ToList().Count > 0)
            {
                var LastPayment = courseClientPayments.OrderByDescending(cp => cp.Payment.DateCreated).First();
                if (LastPayment != null)
                {
                    if (LastPayment.Payment != null)
                    {
                        LastPaymentDate = (DateTime)LastPayment.Payment.DateCreated;
                    }
                }
                TotalAmountPaid = courseClientPayments.Where(cp => cp.Payment.AuthCode == "OK").Sum(cp => cp.Payment.Amount);
            }
        }
    }
}