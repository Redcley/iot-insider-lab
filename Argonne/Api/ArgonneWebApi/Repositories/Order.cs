using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace ArgonneWebApi.Repositories
{
    public class Order<T,TKey>
    {
        public enum Direction
        {
            Ascending,
            Descending
        }

        public Expression<Func<T,TKey>>  KeySelector { get; set; }
        public Direction OrderByDirection { get; set; }
    }
}
