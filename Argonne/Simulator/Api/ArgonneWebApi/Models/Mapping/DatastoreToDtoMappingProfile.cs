using System;
using ArgonneWebApi.Models.Datastore;
using ArgonneWebApi.Models.Dto;
using AutoMapper;

namespace ArgonneWebApi.Models.Mapping
{
    public class DatastoreToDtoMappingProfile : Profile
    {
        [Obsolete]
        protected override void Configure()
        {
            CreateMap<Devices, DeviceDto>();
            CreateMap<Campaigns, CampaignDto>();
            CreateMap<Ads, AdDto>();
            
            CreateMap<FacesForImpressions, FaceForImpressionDto>();
            CreateMap<AdsForCampaigns, AdInCampaignDto>();

            CreateMap<Impressions, ImpressionDto>().ForMember(dest => dest.Faces, opt => opt.MapFrom(src => src.FacesForImpressions));
        }
    }
}
