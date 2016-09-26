using Microsoft.Analytics.Interfaces;
using Microsoft.Analytics.Types.Sql;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace U_SQL
{
    public static class Helpers
    {
        // We use this method in the U-SQL code page.
        public static string Reverse(string s)
        {
            // This could be done in a single statement...
            var charArray = s.ToCharArray();
            Array.Reverse(charArray);
            return new string(charArray);
        }
    }
}
