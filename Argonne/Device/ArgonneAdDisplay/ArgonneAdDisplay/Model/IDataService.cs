using System.Threading.Tasks;

namespace ArgonneAdDisplay.Model
{
    public interface IDataService
    {
        Task<DataItem> GetData();
    }
}