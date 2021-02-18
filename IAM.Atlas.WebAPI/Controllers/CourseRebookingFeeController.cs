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
    public class CourseRebookingFeeController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/CourseRebookingFee/GetCourseTypeRebookingFee/{CourseTypeId}/{CourseTypeCategoryId}")]
        [HttpGet]

        public object Get(int CourseTypeId, int? CourseTypeCategoryId)

        {

            var courseRebookingFees = atlasDBViews.vwCourseTypeRebookingFeeDetails
            .Where(
                ctfd =>
                    ctfd.CourseTypeId == CourseTypeId
                    && ctfd.CourseTypeCategoryId == CourseTypeCategoryId
            )
            .Select(
                courseRebookingFee => new CourseRebookingFeeSummary
                {
                    CourseTypeRebookingFeeId = courseRebookingFee.CourseTypeRebookingFeeId,
                    CourseTypeCategoryRebookingFeeId = courseRebookingFee.CourseTypeCategoryRebookingFeeId,
                    EffectiveDate = courseRebookingFee.EffectiveDate,
                    Condition = courseRebookingFee.ConditionNumber,
                    DaysBefore = courseRebookingFee.DaysBefore,
                    CourseRebookingFee = courseRebookingFee.RebookingFee,
                    IsSelected = true
                }
            )
            .OrderByDescending(courseRebookingFee => courseRebookingFee.EffectiveDate).ThenBy(courseRebookingFee => courseRebookingFee.Condition).ToList();

            if (courseRebookingFees.Count() > 0)
            {
                
                var effectiveDates = (

                    from crf in courseRebookingFees
                    select new 
                    {
                        EffectiveDate = crf.EffectiveDate

                    }
                    ).Distinct();


                // copy the date objects as modifying courseRebookingFees
                datetimes = new List<DateTime>();
                foreach (var effectiveDate in effectiveDates)
                {
                    datetimes.Add((DateTime)effectiveDate.EffectiveDate);
                }
                
                try
                {
                    
                   
                    foreach (var effectiveDate in datetimes)
                    {

                        var MaxCondition = courseRebookingFees.Where(x => x.EffectiveDate == effectiveDate).Max(x => x.Condition);

                        while (MaxCondition < 5)
                        {

                            MaxCondition++;

                            CourseRebookingFeeSummary courseRebookingFeeSummary = new CourseRebookingFeeSummary();

                            courseRebookingFeeSummary.EffectiveDate = effectiveDate;
                            courseRebookingFeeSummary.Condition = MaxCondition;
                            courseRebookingFeeSummary.IsSelected = false;

                            courseRebookingFees.Add(courseRebookingFeeSummary);

                        }
                    }
                }
                catch (Exception ex)
                {
                   
                }
                
            }
            return courseRebookingFees;
        }
        
        [AuthorizationRequired]
        [Route("api/CourseRebookingFee/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;
     

            var EffectiveDate = StringTools.GetDate("EffectiveDate", ref formData);
            var OrganisationId = StringTools.GetInt("OrganisationId", ref formData);
            var AddedByUserId = StringTools.GetInt("AddedByUserId", ref formData);
            var CourseTypeId = StringTools.GetInt("CourseTypeId", ref formData);
            var CourseTypeCategoryId = StringTools.GetInt("CourseTypeCategoryId", ref formData);

            int MAX_CONDITION_RULE_COUNT = 5;
            int CONDITION_COUNT_OVERRIDE = 1;

            bool isSelectedForAdd = true;

            DateTime DateAdded = DateTime.Now;

            if (CourseTypeCategoryId == 0)
            {
                // Add new CourseTypeRebookingFees
                // Remove any existing CourseTypeRebookingFees
                
                var removeCourseTypeRebookingFees = atlasDBViews.vwCourseTypeRebookingFeeDetails
                   .Where(
                       ctfd =>
                           ctfd.CourseTypeId == CourseTypeId
                           && (ctfd.CourseTypeCategoryId == CourseTypeCategoryId || ctfd.CourseTypeCategoryId == null)
                           && ctfd.EffectiveDate == EffectiveDate
                   )
                   .Select(
                       courseRebookingFee => new
                       {
                           CourseTypeRebookingFeeId = courseRebookingFee.CourseTypeRebookingFeeId,
                           CourseTypeCategoryRebookingFeeId = courseRebookingFee.CourseTypeCategoryRebookingFeeId

                       }
                   ).ToList();

                if (removeCourseTypeRebookingFees.Count() != 0)
                {
                    foreach (var removeCourseTypeRebookingFee in removeCourseTypeRebookingFees)
                    {
                        CourseTypeRebookingFee courseTypeRebookingFee = atlasDB.CourseTypeRebookingFees.Find(removeCourseTypeRebookingFee.CourseTypeRebookingFeeId);

                        if (courseTypeRebookingFee != null)
                        {
                            atlasDB.CourseTypeRebookingFees.Remove(courseTypeRebookingFee);
                            atlasDB.Entry(courseTypeRebookingFee).State = EntityState.Deleted;
                        }
                       
                    }
                }

                // Add the New courseTypeRebookingFee

                for (int a = 0; a < MAX_CONDITION_RULE_COUNT; a = a + 1)
                {

                    var addCourseTypeRebookingFees = (from fb in formBody
                                                      where fb.Key.Contains("courseRebookingFee[" + a + "]")
                                                      select new { fb.Key, fb.Value });

                    if (addCourseTypeRebookingFees != null)
                    {

                        CourseTypeRebookingFee addCourseTypeRebookingFeeObject = new CourseTypeRebookingFee();

                        addCourseTypeRebookingFeeObject.OrganisationId = OrganisationId;
                        addCourseTypeRebookingFeeObject.CourseTypeId = CourseTypeId;
                        addCourseTypeRebookingFeeObject.EffectiveDate = EffectiveDate;
                        addCourseTypeRebookingFeeObject.Disabled = false;
                        addCourseTypeRebookingFeeObject.AddedByUserId = AddedByUserId;
                        addCourseTypeRebookingFeeObject.DateAdded = DateAdded;

                        foreach (var addCourseTypeRebookingFee in addCourseTypeRebookingFees)
                        {

                            if (addCourseTypeRebookingFee.Key == "courseRebookingFee[" + a + "][IsSelected]")
                            {
                                isSelectedForAdd = Boolean.Parse(addCourseTypeRebookingFee.Value);
                            }
                            if (addCourseTypeRebookingFee.Key == "courseRebookingFee[" + a + "][Condition]")
                            {
                                addCourseTypeRebookingFeeObject.ConditionNumber = Int32.Parse(addCourseTypeRebookingFee.Value);
                            }
                            if (addCourseTypeRebookingFee.Key == "courseRebookingFee[" + a + "][CourseRebookingFee]")
                            {
                                if (string.IsNullOrEmpty(addCourseTypeRebookingFee.Value))
                                {
                                    addCourseTypeRebookingFeeObject.RebookingFee = 0;
                                }
                                else { addCourseTypeRebookingFeeObject.RebookingFee = Decimal.Parse(addCourseTypeRebookingFee.Value); }
                            }
                            if (addCourseTypeRebookingFee.Key == "courseRebookingFee[" + a + "][DaysBefore]")
                            {
                                if (string.IsNullOrEmpty(addCourseTypeRebookingFee.Value))
                                {
                                    addCourseTypeRebookingFeeObject.DaysBefore = 0;
                                }
                                else
                                {
                                    addCourseTypeRebookingFeeObject.DaysBefore = Int32.Parse(addCourseTypeRebookingFee.Value);
                                }
                            }
                        }

                        if (isSelectedForAdd)
                        {
                            // Although the Condition Number is set above, 
                            // it's possible that they may not be sequentially set 
                            // override the condition number and ensure they are sequential
                            addCourseTypeRebookingFeeObject.ConditionNumber = CONDITION_COUNT_OVERRIDE++;

                            atlasDB.CourseTypeRebookingFees.Add(addCourseTypeRebookingFeeObject);
                        }

                    }
                }

            }

            else // Add new CourseTypeCategoryRebookingFees
            {
                // Remove any existing CourseTypeCategoryRebookingFees

                var removeCourseTypeCategoryRebookingFees = atlasDBViews.vwCourseTypeRebookingFeeDetails
                   .Where(
                       ctfd =>
                           ctfd.CourseTypeId == CourseTypeId
                           && ctfd.CourseTypeCategoryId == CourseTypeCategoryId
                           && ctfd.EffectiveDate == EffectiveDate
                   )
                   .Select(
                       courseRebookingFee => new
                       {
                           CourseTypeRebookingFeeId = courseRebookingFee.CourseTypeRebookingFeeId,
                           CourseTypeCategoryRebookingFeeId = courseRebookingFee.CourseTypeCategoryRebookingFeeId

                       }
                   ).ToList();

                if (removeCourseTypeCategoryRebookingFees.Count() != 0)
                {
                    foreach (var removeCourseTypeRebookingFee in removeCourseTypeCategoryRebookingFees)
                    {
                        CourseTypeCategoryRebookingFee courseTypeCategoryRebookingFee = atlasDB.CourseTypeCategoryRebookingFees.Find(removeCourseTypeRebookingFee.CourseTypeCategoryRebookingFeeId);

                        if (courseTypeCategoryRebookingFee != null)
                        {
                            atlasDB.CourseTypeCategoryRebookingFees.Remove(courseTypeCategoryRebookingFee);
                            atlasDB.Entry(courseTypeCategoryRebookingFee).State = EntityState.Deleted;
                        }
               
                    }
                }


                // Add the New courseTypeRebookingFee

                for (int a = 0; a < MAX_CONDITION_RULE_COUNT; a = a + 1)
                {

                    var addCourseTypeCategoryRebookingFees = (from fb in formBody
                                                              where fb.Key.Contains("courseRebookingFee[" + a + "]")
                                                              select new { fb.Key, fb.Value });

                    if (addCourseTypeCategoryRebookingFees != null)
                    {

                        CourseTypeCategoryRebookingFee addCourseTypeCategoryRebookingFeeObject = new CourseTypeCategoryRebookingFee();

                        addCourseTypeCategoryRebookingFeeObject.OrganisationId = OrganisationId;
                        addCourseTypeCategoryRebookingFeeObject.CourseTypeId = CourseTypeId;
                        addCourseTypeCategoryRebookingFeeObject.CourseTypeCategoryId = CourseTypeCategoryId;
                        addCourseTypeCategoryRebookingFeeObject.EffectiveDate = EffectiveDate;
                        addCourseTypeCategoryRebookingFeeObject.Disabled = false;
                        addCourseTypeCategoryRebookingFeeObject.AddedByUserId = AddedByUserId;
                        addCourseTypeCategoryRebookingFeeObject.DateAdded = DateAdded;

                        foreach (var addCourseTypeCategoryRebookingFee in addCourseTypeCategoryRebookingFees)
                        {

                            if (addCourseTypeCategoryRebookingFee.Key == "courseRebookingFee[" + a + "][IsSelected]")
                            {
                                isSelectedForAdd = Boolean.Parse(addCourseTypeCategoryRebookingFee.Value);
                            }
                            if (addCourseTypeCategoryRebookingFee.Key == "courseRebookingFee[" + a + "][Condition]")
                            {
                                addCourseTypeCategoryRebookingFeeObject.ConditionNumber = Int32.Parse(addCourseTypeCategoryRebookingFee.Value);
                            }
                            if (addCourseTypeCategoryRebookingFee.Key == "courseRebookingFee[" + a + "][CourseRebookingFee]")
                            {
                                if (string.IsNullOrEmpty(addCourseTypeCategoryRebookingFee.Value))
                                {
                                    addCourseTypeCategoryRebookingFeeObject.RebookingFee = 0;
                                }
                                else { addCourseTypeCategoryRebookingFeeObject.RebookingFee = Decimal.Parse(addCourseTypeCategoryRebookingFee.Value); }
                            }
                            if (addCourseTypeCategoryRebookingFee.Key == "courseRebookingFee[" + a + "][DaysBefore]")
                            {
                                if (string.IsNullOrEmpty(addCourseTypeCategoryRebookingFee.Value))
                                {
                                    addCourseTypeCategoryRebookingFeeObject.DaysBefore = 0;
                                }
                                else
                                {
                                    addCourseTypeCategoryRebookingFeeObject.DaysBefore = Int32.Parse(addCourseTypeCategoryRebookingFee.Value);
                                }
                            }
                        }

                        if (isSelectedForAdd)
                        {
                            // Although the Condition Number is set above, 
                            // it's possible that they may not be sequentially set 
                            // override the condition number and ensure they are sequential
                            addCourseTypeCategoryRebookingFeeObject.ConditionNumber = CONDITION_COUNT_OVERRIDE++;

                            atlasDB.CourseTypeCategoryRebookingFees.Add(addCourseTypeCategoryRebookingFeeObject);
                        }

                    }
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
        [Route("api/CourseRebookingFee/CancelCourseRebookingFee")]
        [HttpPost]
        public void CancelCourseRebookingFee([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;

            var UserId = StringTools.GetInt("UserId", ref formBody);

            var courseTypeCategoryRebookingFeeIds = (from fb in formBody
                                 where fb.Key.Contains("CourseTypeCategoryRebookingFeeId")
                                 select new { fb.Key, fb.Value });

            var courseTypeRebookingFeeIds = (from fb in formBody
                                                     where fb.Key.Contains("CourseTypeRebookingFeeId")
                                                     select new { fb.Key, fb.Value });

            DateTime DisabledDate = DateTime.Now;


            if (courseTypeRebookingFeeIds.Count() != 0)
            {
                
                foreach (var courseTypeRebookingFeeId in courseTypeRebookingFeeIds)
                {
                    CourseTypeRebookingFee courseTypeRebookingFee = atlasDB.CourseTypeRebookingFees.Find(Int32.Parse(courseTypeRebookingFeeId.Value));

                    if (courseTypeRebookingFee != null)
                    {

                        atlasDB.CourseTypeRebookingFees.Attach(courseTypeRebookingFee);
                        var entry = atlasDB.Entry(courseTypeRebookingFee);

                        courseTypeRebookingFee.Disabled = true;
                        atlasDB.Entry(courseTypeRebookingFee).Property("Disabled").IsModified = true;

                        courseTypeRebookingFee.DisabledByUserId = UserId;
                        atlasDB.Entry(courseTypeRebookingFee).Property("DisabledByUserId").IsModified = true;

                        courseTypeRebookingFee.DateDisabled = DisabledDate;
                        atlasDB.Entry(courseTypeRebookingFee).Property("DateDisabled").IsModified = true;
                    }
                }

            }
            else if (courseTypeCategoryRebookingFeeIds.Count() != 0)
            {

                foreach (var courseTypeCategoryRebookingFeeId in courseTypeCategoryRebookingFeeIds)
                {

                    CourseTypeCategoryRebookingFee courseTypeCategoryRebookingFee = atlasDB.CourseTypeCategoryRebookingFees.Find(Int32.Parse(courseTypeCategoryRebookingFeeId.Value));

                    if (courseTypeCategoryRebookingFee != null)
                    {

                        atlasDB.CourseTypeCategoryRebookingFees.Attach(courseTypeCategoryRebookingFee);
                        var entry = atlasDB.Entry(courseTypeCategoryRebookingFee);

                        courseTypeCategoryRebookingFee.Disabled = true;
                        atlasDB.Entry(courseTypeCategoryRebookingFee).Property("Disabled").IsModified = true;

                        courseTypeCategoryRebookingFee.DisabledByUserId = UserId;
                        atlasDB.Entry(courseTypeCategoryRebookingFee).Property("DisabledByUserId").IsModified = true;

                        courseTypeCategoryRebookingFee.DateDisabled = DisabledDate;
                        atlasDB.Entry(courseTypeCategoryRebookingFee).Property("DateDisabled").IsModified = true;
                    }


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


        public List<DateTime> datetimes { get; set; }

        public class CourseRebookingFeeSummary
        {
            public int? CourseTypeRebookingFeeId { get; set; }
            public int? CourseTypeCategoryRebookingFeeId { get; set; }
            public DateTime? EffectiveDate { get; set; }
            public int? Condition { get; set; }
            public int? DaysBefore { get; set; }
            public decimal? CourseRebookingFee { get; set; }
            public bool IsSelected { get; set; }
        }
    }
}
