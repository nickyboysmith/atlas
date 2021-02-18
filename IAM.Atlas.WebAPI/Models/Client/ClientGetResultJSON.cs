using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    //public class ClientGetResultJSON
    //{
    //    int Id;
    //    string Title;
    //    bool IsMysteryShopper;
    //    string FirstName;
    //    string OtherNames;
    //    string Surname;
    //    string DisplayName;
    //    DateTime? DateOfBirth;
    //    int? LockedByUserId;
    //    string LockedByUserName;
    //    string ReferringAuthority;
    //    List<ClientMarkedForDelete> ClientMarkedForDeletions;
    //    List<ClientPreviousId> ClientPreviousIds;
    //    List<ClientIdentifier> ClientUniqueIdentifier;
    //    List<CourseInformationJSON> CourseInformation;
    //    object Addresses = theClient.ClientLocations.Select(
    //                        address => new
    //                        {
    //                            address.Location.Address,
    //                            address.Location.PostCode
    //                        }
    //                    ),
    //                    Emails = theClient.ClientEmails.Select(
    //                        email => new
    //                        {
    //                            email.Email.Address
    //                        }
    //                    ),
    //                    Licences = theClient.ClientLicences.Select(
    //                        licence => new
    //                        {
    //                            Type = licence.DriverLicenceTypeId,
    //                            TypeName = licence.DriverLicenceType.Name,
    //                            Number = licence.LicenceNumber,
    //                            ExpiryDate = licence.LicenceExpiryDate,
    //                            PhotocardExpiryDate = licence.LicencePhotoCardExpiryDate

    //                        }
    //                    ),
    //                    PhoneNumbers = theClient.ClientPhones.Select(
    //                        phone => new
    //                        {
    //                            Number = phone.PhoneNumber,
    //                            NumberType = phone.PhoneType.Type
    //                        }
    //                    ),
    //                    SMSConfirmed = theClient.SMSConfirmed == null ? false : (bool)theClient.SMSConfirmed,
    //                    EmailedConfirmed = theClient.EmailedConfirmed == null ? false : (bool)theClient.EmailedConfirmed,
    //                    EmailCourseReminders = theClient.EmailCourseReminders == null ? false : (bool)theClient.EmailCourseReminders,
    //                    SMSCourseReminders = theClient.SMSCourseReminders == null ? false : (bool)theClient.SMSCourseReminders
    //                }
    //}

//    public class CourseInformationJSON
//    {
//        int CourseId;
//        string Reference;
//        string CourseType;
//    DateTime CourseDate;
//      bool IsDORSCourse;
//                                ClientRemoved = theCourse.Course.CourseClientRemoveds.Any(ccr => ccr.ClientId == id && ccr.DateAddedToCourse == theCourse.DateAdded),
//                                AmountPaid = theCourse.Course.CourseClientPayments.ToList().Where(x => x.ClientId == id).Count() > 0 ?
//                                             theCourse.Course.CourseClientPayments.ToList().Where(x => x.ClientId == id).Sum(y => y.Payment.Amount) :
//                                             0,


//                                AmountOutstanding = (theCourse.Course.CourseClients.ToList()
//                                                                    .OrderByDescending(cc => cc.Id)
//                                                                    .FirstOrDefault()
//                                                                    .TotalPaymentDue.HasValue?
//                                                    (decimal)theCourse.Course.CourseClients
//                                                                                .OrderByDescending(cc => cc.Id)
//                                                                                .FirstOrDefault()
//                                                                                .TotalPaymentDue :
//                                                    (decimal)0.00)
//                                                     -
//                                                    (theCourse.Course.CourseClientPayments
//                                                                    .ToList()
//                                                                    .Where(x => x.ClientId == id)
//                                                                    .Count() > 0 ?
//                                                    theCourse.Course.CourseClientPayments.ToList()
//                                                                                            .Where(x => x.ClientId == id)
//                                                                                            .Sum(y => y.Payment.Amount) :
//                                                                                            0),
//                                PaymentDueDate = theCourse.PaymentDueDate,
//                                DORSDetails = theClient.ClientDORSDatas.Select(
//                                    dorsDetails => new
//                                    {
//                                        DORSReference = dorsDetails.DORSAttendanceRef,
//                                        Region = dorsDetails.ReferringAuthority,
//                                        ReferralDate = dorsDetails.DateReferred
//}
//                                )
//                            }
//    }
}
