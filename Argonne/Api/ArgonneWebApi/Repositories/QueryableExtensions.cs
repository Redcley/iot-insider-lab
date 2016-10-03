using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ArgonneWebApi.Repositories
{
    public static class QueryableExtensions
    {
        public static IQueryable<T> Page<T>(this IQueryable<T> query, Pager pager)
        {
            var retval = query;
            if (null == pager)
                return retval;

            if (null != pager.Skip)
            {
                retval = retval.Skip(pager.Skip.Value);
            }

            if (null != pager.Take)
            {
                retval = retval.Take(pager.Take.Value);
            }
            return retval;
        }

        public static IQueryable<T> Sort<T, TKey>(this IQueryable<T> query, Order<T,TKey> order)
        {
            if (null == order)
                return query;

            if (order.OrderByDirection == Order<T, TKey>.Direction.Ascending)
            {
                return query.OrderBy(order.KeySelector);
            }

            return query.OrderByDescending(order.KeySelector);
        }
    }
}
