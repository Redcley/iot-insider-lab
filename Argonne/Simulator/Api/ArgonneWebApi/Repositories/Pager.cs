
using ArgonneWebApi.Models.Dto;

namespace ArgonneWebApi.Repositories
{
    public class Pager
    {
        public const int DefaultPageSize = 100;
        public static Pager Default = new Pager(null, DefaultPageSize);
        
        public int? Take { get; set; }
        public int? Skip { get; set; }

        public Pager(int? pageNumber, int? pageSize)
        {
            if (null != pageSize)
            {
                Take = pageSize;
                if (null != pageNumber)
                {
                    Skip = pageNumber * pageSize;
                }
            }
            else
            {
                Take = DefaultPageSize;
            }
        }

        public static Pager FromPagerDto(PagerDto pager)
        {
            return new Pager(pager.PageNumber, pager.PageSize);
        }
    }
}
