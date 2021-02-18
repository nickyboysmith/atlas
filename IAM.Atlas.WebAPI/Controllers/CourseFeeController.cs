using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;
using System.Net.Http;
using System.Net;
using System.Web;
using System.Reflection;
using System.Collections.Generic;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class CourseFeeController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/CourseFee/GetCourseTypeFee/{CourseTypeId}/{CourseTypeCategoryId}")]
        [HttpGet]
        public List<CourseFeeSummary> Get(int CourseTypeId, int? CourseTypeCategoryId)
        {
            
            var courseFees = atlasDBViews.vwCourseTypeFeeDetails
            .Where(
                ctfd =>
                    ctfd.CourseTypeId == CourseTypeId
                    && ctfd.CourseTypeCategoryId == CourseTypeCategoryId
            )
            .Select(
                courseFee => new CourseFeeSummary
                {
                    CourseTypeFeeId = courseFee.CourseTypeFeeId,
                    CourseTypeCategoryFeeId = courseFee.CourseTypeCategoryFeeId,
                    EffectiveDate = courseFee.EffectiveDate,
                    CourseFee = courseFee.CourseFee,
                    BookingSupplement = courseFee.BookingSupplement,
                    PaymentDays = courseFee.PaymentDays
                }
            )
            .OrderByDescending(courseFee => courseFee.EffectiveDate).ToList();

            return courseFees;
        }

        [AuthorizationRequired]
        [Route("api/CourseFee/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {
            
            FormDataCollection formData = formBody;

            var CourseTypeCategoryFeeId = StringTools.GetInt("CourseTypeCategoryFeeId", ref formData);
            var CourseTypeFeeId = StringTools.GetInt("CourseTypeFeeId", ref formData);
            var EffectiveDate = formData.Get("EffectiveDate");
            var CourseFee = StringTools.GetDecimal("CourseFee", ref formData);
            var BookingSupplement = StringTools.GetDecimal("BookingSupplement", ref formData);
            var PaymentDays = StringTools.GetInt("PaymentDays", ref formData);

            DateTime EffDate = DateTime.Parse(EffectiveDate);

            if (CourseTypeCategoryFeeId==0)
            {

                CourseTypeFee courseTypeFee = atlasDB.CourseTypeFees.Find(CourseTypeFeeId);

                if (courseTypeFee != null)
                {

                    atlasDB.CourseTypeFees.Attach(courseTypeFee);
                    var entry = atlasDB.Entry(courseTypeFee);

                    courseTypeFee.EffectiveDate = EffDate;
                    //courseTypeFee.EffectiveDate = EffectiveDate;
                    atlasDB.Entry(courseTypeFee).Property("EffectiveDate").IsModified = true;

                    courseTypeFee.CourseFee = CourseFee;
                    atlasDB.Entry(courseTypeFee).Property("CourseFee").IsModified = true;

                    courseTypeFee.BookingSupplement = BookingSupplement;
                    atlasDB.Entry(courseTypeFee).Property("BookingSupplement").IsModified = true;

                    courseTypeFee.PaymentDays = PaymentDays;
                    atlasDB.Entry(courseTypeFee).Property("PaymentDays").IsModified = true;

                }

            }

            else if (CourseTypeFeeId == 0)
            {

                CourseTypeCategoryFee courseTypeCategoryFee = atlasDB.CourseTypeCategoryFees.Find(CourseTypeCategoryFeeId);

                if (courseTypeCategoryFee != null)
                {

                    atlasDB.CourseTypeCategoryFees.Attach(courseTypeCategoryFee);
                    var entry = atlasDB.Entry(courseTypeCategoryFee);

                    courseTypeCategoryFee.EffectiveDate = EffDate;
                    atlasDB.Entry(courseTypeCategoryFee).Property("EffectiveDate").IsModified = true;

                    courseTypeCategoryFee.CourseFee = CourseFee;
                    atlasDB.Entry(courseTypeCategoryFee).Property("CourseFee").IsModified = true;

                    courseTypeCategoryFee.BookingSupplement = BookingSupplement;
                    atlasDB.Entry(courseTypeCategoryFee).Property("BookingSupplement").IsModified = true;

                    courseTypeCategoryFee.PaymentDays = PaymentDays;
                    atlasDB.Entry(courseTypeCategoryFee).Property("PaymentDays").IsModified = true;
                }
            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }
        
        [AuthorizationRequired]
        [Route("api/CourseFee/AddCourseFee")]
        [HttpPost]
        public void Add([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;
            
            var CourseTypeId = StringTools.GetInt("CourseTypeId", ref formData);
            var CourseTypeCategoryId = StringTools.GetInt("CourseTypeCategoryId", ref formData);
           
            if (CourseTypeCategoryId == 0)
            {
                var courseTypeFee = formBody.ReadAs<CourseTypeFee>();

                courseTypeFee.DateAdded = DateTime.Now;

                atlasDB.CourseTypeFees.Add(courseTypeFee);
            }
            else
            {
                var courseTypeCategoryFee = formBody.ReadAs<CourseTypeCategoryFee>();

                courseTypeCategoryFee.DateAdded = DateTime.Now;

                atlasDB.CourseTypeCategoryFees.Add(courseTypeCategoryFee);
            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/CourseFee/CancelCourseFee")]
        [HttpPost]
        public void CancelCourseFee([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;

            var UserId = StringTools.GetInt("userId", ref formBody);
            var CourseTypeCategoryFeeId = StringTools.GetInt("CourseTypeCategoryFeeId", ref formData);
            var CourseTypeFeeId = StringTools.GetInt("CourseTypeFeeId", ref formData);

            DateTime DisabledDate = DateTime.Now;

            if (CourseTypeCategoryFeeId == 0)
            {

                CourseTypeFee courseTypeFee = atlasDB.CourseTypeFees.Find(CourseTypeFeeId);

                if (courseTypeFee != null)
                {

                    atlasDB.CourseTypeFees.Attach(courseTypeFee);
                    var entry = atlasDB.Entry(courseTypeFee);

                    courseTypeFee.Disabled = true;
                    atlasDB.Entry(courseTypeFee).Property("Disabled").IsModified = true;

                    courseTypeFee.DisabledByUserId = UserId;
                    atlasDB.Entry(courseTypeFee).Property("DisabledByUserId").IsModified = true;

                    courseTypeFee.DateDisabled = DisabledDate;
                    atlasDB.Entry(courseTypeFee).Property("DateDisabled").IsModified = true;
                }
                    
            }
            else
            {

                CourseTypeCategoryFee courseTypeCategoryFee = atlasDB.CourseTypeCategoryFees.Find(CourseTypeCategoryFeeId);

                if (courseTypeCategoryFee != null)
                {

                    atlasDB.CourseTypeCategoryFees.Attach(courseTypeCategoryFee);
                    var entry = atlasDB.Entry(courseTypeCategoryFee);

                    courseTypeCategoryFee.Disabled = true;
                    atlasDB.Entry(courseTypeCategoryFee).Property("Disabled").IsModified = true;

                    courseTypeCategoryFee.DisabledByUserId = UserId;
                    atlasDB.Entry(courseTypeCategoryFee).Property("DisabledByUserId").IsModified = true;

                    courseTypeCategoryFee.DateDisabled = DisabledDate;
                    atlasDB.Entry(courseTypeCategoryFee).Property("DateDisabled").IsModified = true;
                }
            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        public class CourseFeeSummary
        {
            public int? CourseTypeFeeId { get; set; }
            public int? CourseTypeCategoryFeeId { get; set; }
            public DateTime? EffectiveDate { get; set; }
            public decimal? CourseFee { get; set; }
            public decimal? BookingSupplement { get; set; }
            public int? PaymentDays { get; set; }
        }
    }
}
