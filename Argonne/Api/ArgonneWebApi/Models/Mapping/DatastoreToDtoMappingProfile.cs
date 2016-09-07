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
            CreateMap<Impressions, ImpressionDto>();
            CreateMap<FacesForImpressions, FaceForImpressionDto>();
            CreateMap<AdsForCampaigns, AdInCampaignDto>();
        }
    }
}
