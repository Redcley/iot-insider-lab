using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(ArgonneDashboard.Startup))]
namespace ArgonneDashboard
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            
        }
    }
}
