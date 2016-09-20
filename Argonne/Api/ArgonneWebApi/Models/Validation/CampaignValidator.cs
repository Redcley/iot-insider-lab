using System;
using ArgonneWebApi.Models.Dto;
using FluentValidation;

namespace ArgonneWebApi.Models.Validation
{
    public class CampaignValidator : AbstractValidator<CampaignDto>
    {
        public CampaignValidator(bool checkId = false)
        {
            if (checkId)
            {
                RuleFor(x => x.CampaignId).NotEmpty();
            }

            RuleFor(x => x.CampaignName)
                .NotEmpty()//.WithMessage("Campaign Name cannot be empty.")
                .Length(1, 100);//.WithMessage("Campaign Name cannot be more than 100 characters.");
        }
    }
}
