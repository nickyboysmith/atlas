using System;
using System.Web;

namespace IAM.Atlas.WebAPI.Models.Payment
{
    public class PaymentOrderReference
    {
        public string CourseReference { get; set; }
        public string Region { get; set; }
        public int ClientId { get; set; }

        private int maxLength = 80;

        public string GeneratedOrderReference
        {
            get
            {
                //OrderReference can only be 80 characters (Barclays SmartPay Restriction)
                //This algorithm was agreed by BA
                var encodedRegion = HttpUtility.HtmlEncode(Region);
                var encodedCourseReference = HttpUtility.HtmlEncode(CourseReference);

                int courseReferenceLength = maxLength - string.Format("{0}|{1}|{2}|"
                                                            , String.IsNullOrEmpty(encodedRegion) == true ? "Unallocated" : encodedRegion
                                                            , ClientId == 0 ? "Unallocated" : ClientId.ToString()
                                                            , DateTime.Now.ToString("yyyyMMddHHmm")).Length;

                var useableCourseReference = encodedCourseReference != null && encodedCourseReference.Length > courseReferenceLength ? encodedCourseReference.Substring(0, courseReferenceLength) : encodedCourseReference;


                string orderReference = string.Format("{0}|{1}|{2}|{3}"
                        , String.IsNullOrEmpty(encodedRegion) == true ? "Unallocated" : encodedRegion
                        , String.IsNullOrEmpty(useableCourseReference) == true ? "Unallocated" : useableCourseReference
                        , ClientId == 0 ? "Unallocated" : ClientId.ToString()
                        , DateTime.Now.ToString("yyyyMMddHHmm"));
                
                return orderReference;
            }
        }
    }
}

