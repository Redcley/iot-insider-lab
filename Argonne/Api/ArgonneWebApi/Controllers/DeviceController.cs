using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ArgonneWebApi.Models.Datastore;
using ArgonneWebApi.Models.Dto;
using ArgonneWebApi.Models.Validation;
using ArgonneWebApi.Repositories;
using AutoMapper;
using Microsoft.AspNetCore.Mvc;

namespace ArgonneWebApi.Controllers
{
    [Route("api/admin/[controller]")]
    public class DeviceController : Controller
    {
        private IEntityRepository<Devices> deviceRepository;
        private IMapper mapper;

        public DeviceController(IEntityRepository<Devices> deviceRepo, IMapper entityMapper)
        {
            deviceRepository = deviceRepo;
            mapper = entityMapper;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return new OkObjectResult(mapper.Map<IEnumerable<Devices>, IEnumerable<DeviceDto>>(await deviceRepository.GetAll().ConfigureAwait(false)));
        }

        [HttpGet("{id}", Name = "GetDevice")]
        public async Task<IActionResult> Get(string id)
        {
            if (string.IsNullOrEmpty(id))
                return BadRequest();

            Guid idGuid;
            if(!Guid.TryParse(id, out idGuid))
            {
                return BadRequest();
            }

            var result = mapper.Map<Devices, DeviceDto>(
                await deviceRepository.GetSingle(item => item.DeviceId == idGuid).ConfigureAwait(false));

            if (null == result)
                return NotFound();

            return new OkObjectResult(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody]DeviceDto item)
        {
            if (item == null)
            {
                return BadRequest();
            }

            var validator = new DeviceValidator();
            var validationResults = validator.Validate(item);
            if(!validationResults.IsValid)
            {
                return BadRequest(validationResults.Errors);
            }

            item.DeviceId = Guid.NewGuid();

            await deviceRepository.Add(mapper.Map<DeviceDto, Devices>(item)).ConfigureAwait(false);

            return CreatedAtRoute("GetDevice", new { Controller = "Device", id = item.DeviceId }, item);
        }


        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody]DeviceDto updatedRecord)
        {
            if (string.IsNullOrEmpty(id))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(id, out idGuid))
            {
                return BadRequest();
            }

            if (updatedRecord == null)
            {
                return BadRequest();
            }

            var validator = new DeviceValidator();
            var validationResults = validator.Validate(updatedRecord);
            if (!validationResults.IsValid)
            {
                return BadRequest(validationResults.Errors);
            }

            var existingRecord = await deviceRepository.GetSingle(item => item.DeviceId == idGuid).ConfigureAwait(false);
            if (null == existingRecord)
                return NotFound();
            updatedRecord.DeviceId = idGuid;

            mapper.Map<DeviceDto, Devices>(updatedRecord, existingRecord);
            await deviceRepository.Update(existingRecord).ConfigureAwait(false);
            return Ok();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            if (string.IsNullOrEmpty(id))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(id, out idGuid))
            {
                return BadRequest();
            }

            await deviceRepository.DeleteWhere(item => item.DeviceId == idGuid).ConfigureAwait(false);

            return Ok();
        }
    }
}
