using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TypeLite;
//using TypeLite;

namespace Models
{
    [TsClass]
    public class List
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public int Id { get; set; }
        public string Name { get; set; }
        public virtual ICollection<Task> Tasks { get; set; }
        [NotMapped]
        public int Count { get; set; }
        [NotMapped]
        public int CountEnded { get; set; }
    }
}
