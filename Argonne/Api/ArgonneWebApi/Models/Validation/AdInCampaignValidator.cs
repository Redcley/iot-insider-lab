using System;
using ArgonneWebApi.Models.Dto;
using FluentValidation;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace ArgonneWebApi.Models.Validation
{
    public class AdInCampaignValidator : AbstractValidator<AdInCampaignDto>
    {
        public AdInCampaignValidator()
        {
            RuleFor(x => x.CampaignId).NotEmpty();
            RuleFor(x => x.AdId).NotEmpty();
            RuleFor(x => x.Duration).GreaterThan((short)0);
        }
    }
}
