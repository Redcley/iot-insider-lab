﻿using System;
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
        }
    }
}
