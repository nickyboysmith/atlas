using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using IAM.Atlas.WebAPI.Controllers;

namespace IAM.Atlas.WebAPI.Test.Controllers
{
    [TestClass]
    public class TestAtlasBaseController
    {

        [TestMethod]
        public void SubmitAValidEmail_ReturnsTrue()
        {
            var email = "test@test.com";
            var controller = new AtlasBaseController();
            var result = controller.IsValidEmail(email);

            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void SubmitAnInvalidEmail_ReturnsFalse()
        {
            var email = "test~test.com";
            var controller = new AtlasBaseController();
            var result = controller.IsValidEmail(email);

            Assert.AreEqual(false, result);
        }

    }
}
