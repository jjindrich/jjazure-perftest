using Microsoft.AspNetCore.Mvc;

namespace PerfTest.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TestSimpleController : ControllerBase
    {

        private readonly ILogger<TestController> _logger;

        public TestSimpleController(ILogger<TestController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public ObjectResult Get()
        {
            return Ok("{\"status\":\"ok\"}");
        }
    }
}
