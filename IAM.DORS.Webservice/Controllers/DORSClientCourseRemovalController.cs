using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using System.Text;
using System.Web.Http;
using System.Configuration;
using IAM.Atlas.Data;

namespace IAM.DORS.Webservice.Controllers
{
    class DORSClientCourseRemovalController
    {
        [HttpGet]
        [Route("api/DORSController/RemoveFromCourse")]

        public string removeFromCourse()
        {
            var outputMessages = new List<string>();
            var dorsControl = atlasDB.DORSControls;
            var maxPostsPerSession = (int)dorsControl.First().MaximumPostsPerSession;
            var dorsClientCourseRemoval = atlasDB.DORSClientCourseRemovals.Where(ccr => ccr.DORSNotified == false).OrderBy(ccr => ccr.DateRequested).Take(maxPostsPerSession);


            if (dorsControl.First().DORSEnabled == true)
            {
                foreach (var course in dorsClientCourseRemoval)
                {

                }
                /*
                // This Dictionary is going to be a cache of the DORS Web service connections, the Key is going to be the organisation's Id.
                var DORSWebServiceConnectionList = new Dictionary<int, DORS.Webservice.Interface>();

                foreach (var course in cancelledCourses)
                {
                    // looks in DORSConnections for the cached connection for the relevant organisation
                    DORS.Webservice.Interface dorsWebServiceConnection = null;
                    if (DORSWebServiceConnectionList.ContainsKey(course.OrganisationId))
                    {
                        dorsWebServiceConnection = DORSWebServiceConnectionList[course.OrganisationId];
                    }
                    // if it's not there then create it and add it to the cache
                    if (dorsWebServiceConnection == null)
                    {
                        var dorsConnection = course.Organisation.DORSConnections.FirstOrDefault();
                        if (dorsConnection != null)
                        {
                            dorsWebServiceConnection = new DORS.Webservice.Interface(dorsConnection.LoginName, dorsConnection.Password, useMocks);
                            DORSWebServiceConnectionList.Add(course.OrganisationId, dorsWebServiceConnection);
                        }
                        else
                        {
                            outputMessages.Add("Organisation Id " + course.OrganisationId + " doesn't have a DORSConnection entry.");
                        }
                    }
                    if (dorsWebServiceConnection != null)
                    {

                        if (dorsWebServiceConnection.CancelCourse(course.Id))
                        {
                            //update record if it exists
                            if (course.DORSCancelledCourses.Count > 0)
                            {
                                course.DORSCancelledCourses.First().DORSNotified = true;
                                course.DORSCancelledCourses.First().DateDORSNotified = DateTime.Now;
                                atlasDB.Entry(course).State = EntityState.Modified;
                                outputMessages.Add(course.Id + " Cancelled.");
                            }
                            else
                            //add record to DORSCancelledCourses if it doesn't exist
                            {
                                var dorsCancelledCourse = new DORSCancelledCourse();
                                dorsCancelledCourse.CourseId = course.Id;
                                dorsCancelledCourse.DateDORSNotified = DateTime.Now;
                                dorsCancelledCourse.DORSNotified = true;
                                atlasDB.DORSCancelledCourses.Add(dorsCancelledCourse);
                                outputMessages.Add(course.Id + " Cancelled.");
                            }

                        }
                        else
                        {
                            outputMessages.Add(course.Id + " Couldn't be cancelled.");
                        }
                    }
                }
                atlasDB.SaveChanges();
                */
            }
            else
            {
                outputMessages.Add("Not run, DORS is disabled");
            }

            StringBuilder builder = new StringBuilder();
            foreach (string outputMessage in outputMessages)
            {
                builder.Append(outputMessage).Append(" | ");
            }
            return builder.ToString();
        }
    }
}
