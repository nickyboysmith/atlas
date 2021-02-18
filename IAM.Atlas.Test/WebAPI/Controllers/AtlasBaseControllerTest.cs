using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using IAM.Atlas.WebAPI.Controllers;

namespace IAM.Atlas.Test.WebAPI.Controllers
{
    [TestClass]
    class AtlasBaseControllerTest
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
