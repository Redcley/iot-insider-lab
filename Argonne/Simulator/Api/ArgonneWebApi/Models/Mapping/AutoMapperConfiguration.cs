using AutoMapper;

namespace ArgonneWebApi.Models.Mapping
{
    public class AutoMapperConfiguration
    {
        public static void Configure()
        {
            Mapper.Initialize(x =>
            {
                x.AddProfile<DatastoreToDtoMappingProfile>();
                x.AddProfile<DtoToDatastoreMappingProfile>();
            });
        }
    }
}
