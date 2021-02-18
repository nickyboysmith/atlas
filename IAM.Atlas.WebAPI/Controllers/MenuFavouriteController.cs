using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.Data;
using System.Data.Entity.Validation;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class MenuFavouriteController : AtlasBaseController
    {
        // GET api/<controller>/5
        [AuthorizationRequired]
        public List<UserMenuFavourite> Get(int id)
        {
            var usermenufavourite = atlasDB.UserMenuFavourite.Where(umf => umf.UserId == id);
            return usermenufavourite.ToList();
        }

        // POST api/<controller>
        //public void Post([FromBody]string value)
        //[AllowCrossDomainAccess]
        public string Post(UserMenuFavourite umf)
        {

            string status = "";

             if ((!string.IsNullOrEmpty(umf.Link)) && (!string.IsNullOrEmpty(umf.Parameters)))
             {

                try
                {

                     //UserMenuFavourite umf = new UserMenuFavourite();

                    if (!atlasDB.UserMenuFavourite.Any(u => u.Title == umf.Title 
                                                            && u.UserId == umf.UserId))
                    {
                        atlasDB.UserMenuFavourite.Add(umf);
                        atlasDB.SaveChanges();
                        return status = "true";
                    }
                    else
                    {
                        return status = "false";
                    }

                    


                }
                catch (DbEntityValidationException ex)
                {
                
                    //return status = string.Join("; ", ex.EntityValidationErrors.SelectMany(x => x.ValidationErrors).Select(x => x.ErrorMessage));
                    return status = "false";

                }
            }
            else
            {
                return status = "false";
            }

        }

    }
}

// Other settings
//switch (id)
//{
//    case 1:
//        umf.UserId = 1;
//        umf.Title = "add client";
//        umf.Link = "app/components/client/add";
//        umf.Parameters = "addClientCtrl";
//        umf.Modal = true;
//        break;
//    case 2:
//        umf.UserId = 1;
//        umf.Title = "users";
//        umf.Link = "app/components/users/userListView";
//        umf.Parameters = "UsersCtrl";
//        umf.Modal = true;
//        break;
//    case 3:
//        umf.UserId = 1;
//        umf.Title = "login";
//        umf.Link = "app/components/login/view";
//        umf.Parameters = "LoginCtrl";
//        umf.Modal = true;
//        break;
//    case 4:
//        umf.UserId = 1;
//        umf.Title = "changepassword";
//        umf.Link = "app/components/changePassword/changePasswordView";
//        umf.Parameters = "ChangePasswordCtrl";
//        umf.Modal = true;
//        break;
//}