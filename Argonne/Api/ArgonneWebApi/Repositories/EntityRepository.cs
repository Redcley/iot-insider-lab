using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace ArgonneWebApi.Repositories
{
    public class EntityRepository<T> : IEntityRepository<T>
            where T : class, new()
    {

        private ArgonneDbContext _context;

        #region Properties
        public EntityRepository(ArgonneDbContext context)
        {
            _context = context;
        }
        #endregion

        public async Task<IEnumerable<T>> GetAll(Pager pager)
        {
            return await _context.Set<T>().Page(pager).ToListAsync<T>().ConfigureAwait(false);
        }

        public async Task<int> Count()
        {
            return await _context.Set<T>().CountAsync().ConfigureAwait(false);
        }
        public async Task<IEnumerable<T>> AllIncluding(Pager pager, params Expression<Func<T, object>>[] includeProperties)
        {
            IQueryable<T> query = _context.Set<T>();
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }
            return await query.Page(pager).ToListAsync().ConfigureAwait(false);
        }

        public async Task<T> GetSingle(Expression<Func<T, bool>> predicate)
        {
            return await _context.Set<T>().Where(predicate).FirstOrDefaultAsync().ConfigureAwait(false);
        }

        public async Task<T> GetSingle(Expression<Func<T, bool>> predicate, params Expression<Func<T, object>>[] includeProperties)
        {
            IQueryable<T> query = _context.Set<T>();
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return await query.Where(predicate).FirstOrDefaultAsync().ConfigureAwait(false);
        }

        public async Task<IEnumerable<T>> FindBy(Expression<Func<T, bool>> predicate, Pager pager)
        {
            return await _context.Set<T>().Where(predicate).Page(pager).ToListAsync().ConfigureAwait(false);
        }


//        public async Task<IEnumerable<T>> FindByOrdered<TKey>(Expression<Func<T, bool>> predicate, Pager pager, Order<T, TKey> order)
//        {
//            return await _context.Set<T>().Where(predicate).Page(pager).Sort(order).ToListAsync().ConfigureAwait(false);
//        }

        public async Task<IEnumerable<T>> FindBy(Expression<Func<T, bool>> predicate, Pager pager, params Expression<Func<T, object>>[] includeProperties)
        {
            IQueryable<T> query = _context.Set<T>();
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return await query.Where(predicate).Page(pager).ToListAsync().ConfigureAwait(false);
        }

        public async Task<IEnumerable<T>> FindByOrdered<TKey>(Expression<Func<T, bool>> predicate, Pager pager, Order<T, TKey> order, params Expression<Func<T, object>>[] includeProperties)
        {
            IQueryable<T> query = _context.Set<T>();
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return await query.Where(predicate).Page(pager).Sort(order).ToListAsync().ConfigureAwait(false);
        }

        public async Task Add(T entity)
        {
            EntityEntry dbEntityEntry = _context.Entry<T>(entity);
            _context.Set<T>().Add(entity);
            await _context.SaveChangesAsync().ConfigureAwait(false);
        }

        public async Task Update(T entity)
        {
            EntityEntry dbEntityEntry = _context.Entry<T>(entity);
            dbEntityEntry.State = EntityState.Modified;
            await _context.SaveChangesAsync().ConfigureAwait(false);
        }
        public async Task Delete(T entity)
        {
            EntityEntry dbEntityEntry = _context.Entry<T>(entity);
            dbEntityEntry.State = EntityState.Deleted;
            await _context.SaveChangesAsync().ConfigureAwait(false);
        }

        public async Task DeleteWhere(Expression<Func<T, bool>> predicate)
        {
            IEnumerable<T> entities = _context.Set<T>().Where(predicate);

            foreach (var entity in entities)
            {
                _context.Entry<T>(entity).State = EntityState.Deleted;
            }
            await _context.SaveChangesAsync().ConfigureAwait(false);
        }
    }
}