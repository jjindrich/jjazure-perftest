using Microsoft.EntityFrameworkCore;

namespace PerfTest;

public class DataContext : DbContext
{
    public DataContext(DbContextOptions<DataContext> options) : base(options)
    {
    }

    public DbSet<AccessLog> AccessLog { get; set; }

    /*
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
          base.OnModelCreating(modelBuilder);

          modelBuilder.Entity<AccessLog>(entity =>
          {
            entity.HasKey(e => e.ID);
            entity.Property(e => e.Name).IsRequired();
          });
        }
      }
    */
}
