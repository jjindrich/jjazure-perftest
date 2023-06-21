using Microsoft.AspNetCore.Mvc;

namespace PerfTest.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DbController : ControllerBase
    {
        private readonly DataContext _dbContext;
        private readonly ILogger<TestController> _logger;

        public DbController(ILogger<TestController> logger, DataContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;

            _dbContext.Database.EnsureCreated();
        }

        [HttpGet]
        public ObjectResult Get()
        {
            var accessLog = new AccessLog
            {
                Name = "Pokus"
            };
            _dbContext.AccessLog.Add(accessLog);
            _dbContext.SaveChanges();

            var rowsCount = _dbContext.AccessLog.Count();

            return Ok($"{{\"rowsCount\":\"{rowsCount}\"}}");
        }
    }
}
