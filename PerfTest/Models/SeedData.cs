using Microsoft.EntityFrameworkCore;

namespace PerfTest;

public static class SeedData
{
    public static void Initialize(IServiceProvider serviceProvider)
    {
        using (var context = new DataContext(serviceProvider.GetRequiredService<DbContextOptions<DataContext>>()))
        {
            context.Database.EnsureCreated();

            // Look for any entries.
            if (context.AccessLog.Any())
            {
                return;   // DB has been seeded
            }
            context.AccessLog.AddRange(
                new AccessLog
                {
                    ID = 1,
                    Name = "Item 1",
                },
                new AccessLog
                {
                    ID = 2,
                    Name = "Item 2",
                }
            );
            context.SaveChanges();
        }
    }
}
