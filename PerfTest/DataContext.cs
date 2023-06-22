using Microsoft.EntityFrameworkCore;

namespace PerfTest;

public class DataContext : DbContext
{
    public DataContext(DbContextOptions<DataContext> options) : base(options)
    {
    }

    public DbSet<AccessLog> AccessLog { get; set; }
}
