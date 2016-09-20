using System.Collections.Generic;
using System.Threading.Tasks;

namespace ArgonneWebApi.Repositories
{
    public interface IArgonneQueryContext
    {
        Task<IEnumerable<TResult>> Query<TResult>(string query, params object[] parameters) where TResult : class;
    }
}
