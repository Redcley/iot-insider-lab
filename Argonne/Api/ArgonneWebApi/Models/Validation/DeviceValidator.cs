using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ArgonneWebApi.Models.Dto;
using FluentValidation;

namespace ArgonneWebApi.Models.Validation
{
    public class DeviceValidator : AbstractValidator<DeviceDto>
    {
        public DeviceValidator()
        {
            RuleFor(x => x.DeviceName)
                .NotEmpty()//.WithMessage("Device Name cannot be empty.")
                .Length(1, 100);//.WithMessage("Device Name cannot be more than 100 characters.");

            RuleFor(x => x.PrimaryKey).NotEmpty().Length(1, 100);
            RuleFor(x => x.Address).Length(0, 100);
            RuleFor(x => x.Address2).Length(0, 100);
            RuleFor(x => x.Address3).Length(0, 100);
            RuleFor(x => x.City).Length(0, 100);
            RuleFor(x => x.StateProvince).Length(0, 50);
            RuleFor(x => x.PostalCode).Length(0, 50);

        }
    }
}
