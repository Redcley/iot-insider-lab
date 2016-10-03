using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace ArgonneWebApi.Repositories
{
    public interface IEntityRepository<T> where T : class, new()
    {
        Task<IEnumerable<T>> AllIncluding(Pager pager = null, params Expression<Func<T, object>>[] includeProperties);
        Task<IEnumerable<T>> GetAll(Pager pager = null);
        Task<int> Count();

        Task<T> GetSingle(Expression<Func<T, bool>> predicate);
        Task<T> GetSingle(Expression<Func<T, bool>> predicate, params Expression<Func<T, object>>[] includeProperties);
        Task<IEnumerable<T>> FindBy(Expression<Func<T, bool>> predicate, Pager pager = null);
        Task<IEnumerable<T>> FindBy(Expression<Func<T, bool>> predicate, Pager pager = null, params Expression<Func<T, object>>[] includeProperties);
        Task<IEnumerable<T>> FindByOrdered<TKey>(Expression<Func<T, bool>> predicate, Pager pager, Order<T, TKey> order, params Expression<Func<T, object>>[] includeProperties);
        Task Add(T entity);
        Task Update(T entity);
        Task Delete(T entity);
        Task DeleteWhere(Expression<Func<T, bool>> predicate);
    }
}
