using Microsoft.Data.SqlClient;

namespace coffee_shop
{
    public class Dbhelper
    {
        private readonly string _connStr;
        public Dbhelper(IConfiguration config)
            => _connStr = config.GetConnectionString("DefaultConnection")!;

        public SqlConnection GetConnection() => new SqlConnection(_connStr);
    }
}
