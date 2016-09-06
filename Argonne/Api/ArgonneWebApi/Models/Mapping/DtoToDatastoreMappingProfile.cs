using System;
using ArgonneWebApi.Models.Datastore;
using ArgonneWebApi.Models.Dto;
using AutoMapper;

namespace ArgonneWebApi.Models.Mapping
{
    public class DtoToDatastoreMappingProfile : Profile
    {
        [Obsolete]
        protected override void Configure()
        {
            CreateMap<DeviceDto, Devices>()
                //.ForMember(dest => dest.Address, opt => opt.MapFrom(src => null == src.Address ? string.Empty : src.Address))
                .AfterMap((src, dst) => 
                    {
                        if (null == dst.Address)
                            dst.Address = string.Empty;
                        if (null == dst.Address2)
                            dst.Address2 = string.Empty;
                        if (null == dst.Address3)
                            dst.Address3 = string.Empty;
                        if (null == dst.PrimaryKey)
                            dst.PrimaryKey = string.Empty;
                        if (null == dst.DeviceName)
                            dst.DeviceName = string.Empty;
                        if (null == dst.City)
                            dst.City = string.Empty;
                        if (null == dst.StateProvince)
                            dst.StateProvince = string.Empty;
                        if (null == dst.PostalCode)
                            dst.PostalCode = string.Empty;
                    });

            CreateMap<CampaignDto, Campaigns>()
                .AfterMap((src, dst) =>
                {
                    if (null == dst.CampaignName)
                        dst.CampaignName = string.Empty;
                });

            CreateMap<AdDto, Ads>()
                .AfterMap((src, dst) =>
                {
                    if (null == dst.AdName)
                        dst.AdName = string.Empty;
                });

            CreateMap<ImpressionDto, Impressions>();
            CreateMap<AdInCampaignDto, AdsForCampaigns>();
            CreateMap<FaceForImpressionDto, FacesForImpressions>();
        }
    }
}

