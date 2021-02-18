using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Web;
using System.Configuration;
using IAM.Atlas.WebAPI.Classes;
using System.IO;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.DocumentManagement;
using System.Net.Http.Headers;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DocumentInformationController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/DocumentInformation/GetCourseDocumentInformation/{courseId}")]
        public object GetCourseDocumentInformation(int courseId)
        {
            var courseDocumentInformations = atlasDB.CourseDocuments
                                                    .Where(cd => cd.CourseId == courseId)
                                                    .Select(cd => new
                                                    {
                                                        cd.DocumentId,
                                                        cd.CourseId,
                                                        DocumentTitle = cd.Document.Title,
                                                        cd.Document.FileName,
                                                        LastModified = cd.Document.DateUpdated > cd.Document.DateAdded ? cd.Document.DateUpdated : cd.Document.DateAdded,
                                                        UpdatedByName = cd.Document.User.Name,
                                                        cd.Document.FileSize,
                                                        DocumentType = cd.Document.Type
                                                    })
                                                    .ToList();

            return courseDocumentInformations;
        }

        [AuthorizationRequired]
        [Route("api/DocumentInformation/GetClientDocumentInformation/{clientId}")]
        public object GetClientDocumentInformation(int clientId)
        {
            var clientDocumentInformation = atlasDB.ClientDocuments
                                                    .Where(cd => cd.ClientId == clientId)
                                                    .Select(cd => new
                                                    {
                                                        cd.DocumentId,
                                                        cd.ClientId,
                                                        DocumentTitle = cd.Document.Title,
                                                        cd.Document.FileName,
                                                        LastModified = cd.Document.DateUpdated > cd.Document.DateAdded ? cd.Document.DateUpdated : cd.Document.DateAdded,
                                                        UpdatedByName = cd.Document.User.Name,
                                                        cd.Document.FileSize,
                                                        DocumentType = cd.Document.Type
                                                    })
                                                    .ToList();

            return clientDocumentInformation;
        }
    }
}