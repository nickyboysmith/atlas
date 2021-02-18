using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Netcall
{
    // used to save the courseId to the db but another model AccountDetail is actually returned to netcall (without courseId)
    public class AccountDetailWithCourseId
    {
        public string Result { get; set; }
        public string ResultDescription { get; set; }
        public string ClientID { get; set; }
        public int AmountToPay { get; set; }
        public DateTime CourseDateTime { get; set; }
        public string CourseVenue { get; set; }
        public string ShopperReference { get; set; }
        public int? CourseId { get; set; }

        public AccountDetail RemoveCourseId()
        {
            var accountDetail = new AccountDetail();
            accountDetail.Result = this.Result;
            accountDetail.ResultDescription = this.ResultDescription;
            accountDetail.ClientID = this.ClientID;
            accountDetail.AmountToPay = this.AmountToPay;
            accountDetail.CourseDateTime = this.CourseDateTime;
            accountDetail.CourseVenue = this.CourseVenue;
            accountDetail.ShopperReference = this.ShopperReference;

            return accountDetail;
        }
    }
}
