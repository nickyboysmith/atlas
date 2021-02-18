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

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class AdministrationMenuController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/adminMenu/GetMenuGroups/{userId}")]
        [HttpGet]
        public object GetMenuGroups(int userId)
        {
           
            return atlasDB.AdministrationMenuGroups
                .ToList()
                .Select(mg => new
                {
                    Id = mg.Id,
                    Title = mg.Title,
                    Description = mg.Description
                });

        }

        [AuthorizationRequired]
        [Route("api/adminMenu/GetMenuGroupItems/{menuGroupId}")]
        [HttpGet]
        public object GetMenuGroupItems(int menuGroupId)
        {

            return atlasDB.AdministrationMenuGroupItem
                .Include("AdministrationMenuItem")
                .Where(amgi => amgi.AdminMenuGroupId == menuGroupId)
                .ToList()
                .Select(mi => new
                {
                    Id = mi.AdministrationMenuItem.Id,
                    Title = mi.AdministrationMenuItem.Title,
                    Description = mi.AdministrationMenuItem.Description,

                });
        }

        [AuthorizationRequired]
        [Route("api/adminMenu/GetMenuGroupItemDetails/{menuGroupItemId}")]
        [HttpGet]
        public object Get(int menuGroupItemId)
        {

            return atlasDB.AdministrationMenuGroupItem
                .Include("AdministrationMenuItem")
                .Where(amgi => amgi.AdminMenuItemId == menuGroupItemId)
                .ToList()
                .Select(mi => new
                {
                    Id = mi.AdministrationMenuItem.Id,
                    Title = mi.AdministrationMenuItem.Title,
                    Url = mi.AdministrationMenuItem.Url,
                    Description = mi.AdministrationMenuItem.Description,
                    Modal = mi.AdministrationMenuItem.Modal,
                    Disabled = mi.AdministrationMenuItem.Disabled,
                    Controller = mi.AdministrationMenuItem.Controller,
                    Parameters = mi.AdministrationMenuItem.Parameters,
                    Class = mi.AdministrationMenuItem.Class
                });
        }


        [AuthorizationRequired]
        [Route("api/adminMenu/SaveMenuItemDetail")]
        [HttpPost]
        public string SaveMenuItemDetail([FromBody] FormDataCollection formBody)
        {        

            var selectedMenuGroup = StringTools.GetInt("selectedMenuGroup", ref formBody);
            var selectedMenuItem = StringTools.GetInt("selectedMenuItem", ref formBody);
            
            var administrationMenuItem = formBody.ReadAs<AdministrationMenuItem>();

            // Validate the properties here
            // Check Title not empty maybe

            if (!string.IsNullOrEmpty(administrationMenuItem.Title))
            {


                if (administrationMenuItem.Id > 0) // update
                {
                    atlasDB.AdministrationMenuItem.Attach(administrationMenuItem);
                    var entry = atlasDB.Entry(administrationMenuItem);
                    entry.State = System.Data.Entity.EntityState.Modified;
                }
                else
                {

                    atlasDB.AdministrationMenuItem.Add(administrationMenuItem);

                    AdministrationMenuGroupItem administrationMenuGroupItem = new AdministrationMenuGroupItem();

                    administrationMenuGroupItem.AdminMenuGroupId = selectedMenuGroup;
                    administrationMenuGroupItem.AdminMenuItemId = administrationMenuGroupItem.Id;
                    administrationMenuGroupItem.SortNumber = 0; // default to something

                    atlasDB.AdministrationMenuGroupItem.Add(administrationMenuGroupItem);

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
                            Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }
            }
            else
            {
                throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden) 
                        {
                            Content = new StringContent("The server is unable to process the request due to invalid data."),
                            ReasonPhrase = "Title is empty."
                        }
                    );
            }

            return administrationMenuItem.Id.ToString();
        }


        [AuthorizationRequired]
        [Route("api/adminMenu/SaveMenuGroup")]
        [HttpPost]
        public string SaveMenuGroup([FromBody] FormDataCollection formBody)
        {

            var administrationMenuGroup = formBody.ReadAs<AdministrationMenuGroup>();

            // Validate the properties here
            // Check Title not empty maybe

            if (!string.IsNullOrEmpty(administrationMenuGroup.Title))
            {

                var adminMenuGroupExists = atlasDB.AdministrationMenuGroups.Where(amg => amg.Title == administrationMenuGroup.Title).FirstOrDefault();

                if (adminMenuGroupExists == null)
                {

                    AdministrationMenuGroup AdministrationMenuGroupToAdd = new AdministrationMenuGroup();

                    AdministrationMenuGroupToAdd.Title = administrationMenuGroup.Title;
                    AdministrationMenuGroupToAdd.Description = administrationMenuGroup.Title;
                    AdministrationMenuGroupToAdd.ParentGroupId = null; // set defaults
                    AdministrationMenuGroupToAdd.SortNumber = null; // set defaults

                    atlasDB.AdministrationMenuGroups.Add(administrationMenuGroup);



                    try
                    {
                        atlasDB.SaveChanges();
                    }
                    catch (DbEntityValidationException ex)
                    {
                        throw new HttpResponseException(
                            new HttpResponseMessage(HttpStatusCode.InternalServerError)
                            {
                                Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                                ReasonPhrase = "We can't process your request."
                            }
                        );
                    }
                }
                else
                {

                }
            }
            else
            {
                throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("The server is unable to process the request due to invalid data."),
                            ReasonPhrase = "Title is empty."
                        }
                    );
            }

            return "success";

        }




    }
}


