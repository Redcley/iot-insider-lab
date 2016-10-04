using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ArgonneDashboard.Extensions
{
    public static class HttpExtensions
    {
        public static bool IsReleaseBuild(this HtmlHelper helper)
        {
#if DEBUG
            return false;
#else
    return true;
#endif
        }
    }
}