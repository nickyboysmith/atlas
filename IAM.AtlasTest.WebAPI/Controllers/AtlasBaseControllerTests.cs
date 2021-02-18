using Microsoft.VisualStudio.TestTools.UnitTesting;
using IAM.Atlas.WebAPI.Controllers;

namespace IAM.AtlasTest.WebAPI.Controllers
{
    [TestClass]
    public class AtlasBaseControllerTests
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
