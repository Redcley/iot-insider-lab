namespace Models.DAL
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Validation;
    using System.Linq;
    using Validation;

    public class Repository
    {
        private TodoListContext dbContext;
        private IValidationDictionary validation;

        public Repository(IValidationDictionary validation)
        {
            this.dbContext = new TodoListContext();
            this.validation = validation;
        }

        public DbSet<T> Entity<T>()
            where T : class
        {
            return this.dbContext.Set<T>();
        }

        public void Insert<T>(T entity) where T : class
        {
            this.dbContext.Set<T>().Add(entity);
        }

        public void Update<T>(T entity) where T : class
        {
            this.dbContext.Entry(entity).State = EntityState.Modified;
        }

        public void Delete<T>(int key) where T : class
        {
            var item = this.dbContext.Set<T>().Find(key);

            this.dbContext.Set<T>().Remove(item);
        }

        public bool Save()
        {
            try
            {
                this.dbContext.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                foreach (var validationError in ex.EntityValidationErrors.SelectMany(s => s.ValidationErrors))
                {
                    this.validation.AddError(validationError.PropertyName, validationError.ErrorMessage);
                }

                return false;
            }
            catch (Exception ex)
            {
                this.validation.AddError(ex);

                return false;
            }

            return true;
        }
    }
}