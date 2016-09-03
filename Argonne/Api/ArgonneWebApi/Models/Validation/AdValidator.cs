using ArgonneWebApi.Models.Dto;
using FluentValidation;

namespace ArgonneWebApi.Models.Validation
{
    public class AdValidator : AbstractValidator<AdDto>
    {
        public AdValidator()
        {
            RuleFor(x => x.AdName)
                .NotEmpty()//.WithMessage("Ad Name cannot be empty.")
                .Length(1, 100);//.WithMessage("Ad Name cannot be more than 100 characters.");

            RuleFor(x => x.Url).NotEmpty();
        }
    }
}
