using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class DataViewController : AtlasBaseController
    {
        protected FormDataCollection formData;

        /// <summary>
        /// Check if the requesting user is an administrator and return specific system data view
        /// </summary>
        /// <param name="dataViewId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        [Route("api/dataView/GetDataView/{dataViewId}/{userId}")]
        public object GetDataView(int dataViewId, int userId)
        {
            if (atlasDB.SystemAdminUsers.Count(u => u.UserId == userId) > 0)
            {
                return atlasDB.DataViews
                        .Include("User")
                        .Include("User1")
                        .Where(dv => dv.Id == dataViewId)
                        .ToList()
                        .Select(d => new
                        {
                            Id = d.Id,
                            Name = d.Name,
                            Title = d.Title,
                            Description = d.Description,
                            Enabled = d.Enabled.HasValue ? d.Enabled.Value : false,
                            Created = d.DateAdded.ToString(),
                            Createdby = d.User.LoginId,
                            Updated = d.DateUpdated.HasValue ? d.DateUpdated.ToString() : "Never Updated",
                            Updatedby = d.UpdatedByUserId.HasValue ? d.User1.LoginId.ToString() : "N/A"
                        });
            }
            else
            {
                return "";
            }
        }

        /// <summary>
        /// Check if the requesting user is an administrator and return specific system data view columns
        /// </summary>
        /// <param name="dataViewId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        [Route("api/dataView/getcolumnsfordataview/{dataViewId}/{userId}")]
        public object GetColumnsForDataView(int dataViewId, int userId)
        {
            if (atlasDB.SystemAdminUsers.Count(u => u.UserId == userId) > 0)
            {
                return atlasDB.DataViewColumns
                        .Where(dv => dv.DataViewId == dataViewId)
                        .ToList()
                        .Select(d => new
                        {
                            Name = d.Name
                        });
            }
            else
            {
                return "";
            }
        }

        /// <summary>
        /// Return all system data views if the requesting user is an administrator 
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        [Route("api/dataView/{userId}")]
        public object Get(int userId)
        {
            if (atlasDB.SystemAdminUsers.Count(u => u.UserId == userId) > 0)
            {
                return atlasDB.DataViews
                        .ToList()
                        .Select(d => new
                        {
                            Id = d.Id,
                            Title = d.Title,
                            Name = d.Name
                        });
            }
            else
            {
                return "";
            }
        }

        //POST: api/dataView
        public string Post([FromBody] FormDataCollection formBody)
        {
            this.formData = formBody;

            if (formBody.Count() > 0)
            {
                var id = StringTools.GetInt("Id", ref formData);
                var userid = StringTools.GetInt("UserId", ref formData);
                var title = StringTools.GetString("Title", ref formData);
                var description = StringTools.GetString("Description", ref formData);
                var enabled = StringTools.GetBool("Enabled", ref formData);
                var name = StringTools.GetString("Name", ref formData);
                var dataView = new DataView();

                if (!this.verifyNameAndTitle(name, title, id))
                {
                    return "Unable to save - please ensure that the name and title are unique and 6 or more characters long.";
                }
                if (id > 0 && userid > 0)
                {
                    //treat as an existing venue
                    dataView = atlasDB.DataViews
                                      .Where(v => v.Id == id).First();

                    //Persist DataView Table Data
                    dataView.Title = title;
                    dataView.Name = name;
                    dataView.Description = description;
                    dataView.Enabled = enabled;
                    dataView.UpdatedByUserId = userid;
                    dataView.DateUpdated = DateTime.Now;
                    atlasDB.SaveChanges();
                    return "Data View Saved!";
                }
                else
                {
                    //Treat as a new Data View
                    dataView.Title = title;
                    dataView.Name = name;
                    dataView.Description = description;
                    dataView.AddedByUserId = userid;
                    dataView.DateAdded = DateTime.Now;
                    atlasDB.DataViews.Add(dataView);
                    atlasDB.SaveChanges();
                    return "Data View Added!";
                }
            }
            else
            {
                return "An Error Ocurred whilst saving the Data View. Please inform your support contact.";
            }
        }

        private bool verifyNameAndTitle(string name, string title, int id)
        {
            if ((atlasDB.DataViews.Count(dv => (dv.Name == name || dv.Title == title) && dv.Id != id) > 0)
                || name.Length < 6
                || title.Length < 6)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
    }
}