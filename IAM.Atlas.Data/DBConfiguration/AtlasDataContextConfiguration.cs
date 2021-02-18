using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.SqlServer;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Data.DBConfiguration
{
    public class AtlasDataContextConfiguration : DbConfiguration
    {
        public AtlasDataContextConfiguration()
        {
            SetExecutionStrategy("System.Data.SqlClient", () => new SqlAzureExecutionStrategy(6, TimeSpan.FromSeconds(5)));
        }
    }
}
