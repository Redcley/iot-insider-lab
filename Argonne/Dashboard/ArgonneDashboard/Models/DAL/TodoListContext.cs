using Models;
using System.Data.Entity;
using System.Data.Entity.ModelConfiguration.Conventions;

namespace Models.DAL
{
    public class TodoListContext : DbContext
    {
        public TodoListContext() : base("TodoListContext")
        {
        }

        public DbSet<List> Lists { get; set; }
        public DbSet<Task> Tasks { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Conventions.Remove<PluralizingTableNameConvention>();
        }
    }
}
