using System.Collections.Generic;

namespace Models.DAL
{
    public class TodoListInitializer : System.Data.Entity.DropCreateDatabaseIfModelChanges<TodoListContext>
    {
        protected override void Seed(TodoListContext context)
        {
            var lists = new List<List>
            {
                new List { Id=1, Name = "List1" },
                new List { Id=2, Name = "List2" },
            };

            lists.ForEach(s => context.Lists.Add(s));
            context.SaveChanges();

            var tasks = new List<Task>
            {
                new Task { Id=1, ListId=1, Name = "Task0101" },
                new Task { Id=2, ListId=1, Name = "Task0102" },
                new Task { Id=3, ListId=1, Name = "Task0103" },
                new Task { Id=4, ListId=2, Name = "Task0201" },
                new Task { Id=5, ListId=2, Name = "Task0202" },
            };

            tasks.ForEach(s => context.Tasks.Add(s));
            context.SaveChanges();
        }
    }
}
