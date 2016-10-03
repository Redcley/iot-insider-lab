﻿using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ArgonneWebApi.Models.Datastore;
using ArgonneWebApi.Models.Dto;
using ArgonneWebApi.Models.Validation;
using ArgonneWebApi.Repositories;
using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;

namespace ArgonneWebApi.Controllers
{
    /// <summary>
    /// Administrator API for Devices
    /// </summary>
    [Produces("application/json")]
    [EnableCors("AllowCORS")]
    public class DeviceController : Controller
    {
        private IEntityRepository<Devices> deviceRepository;
        private IMapper mapper;
        private const int DefaultPageSize = 100;

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="deviceRepo"></param>
        /// <param name="entityMapper"></param>
        public DeviceController(IEntityRepository<Devices> deviceRepo, IMapper entityMapper)
        {
            deviceRepository = deviceRepo;
            mapper = entityMapper;
        }

        /// <summary>
        /// Get all devices
        /// </summary>
        /// <param name="pager">paging settings</param>
        /// <response code="200">Success</response>
        [HttpGet]
        [Route("api/admin/[controller]")]
        [ProducesResponseType(typeof(IEnumerable<DeviceDto>), 200)]
        public async Task<IActionResult> GetAll([FromQuery]PagerDto pager)
        {
            return new OkObjectResult(mapper.Map<IEnumerable<Devices>, IEnumerable<DeviceDto>>(await deviceRepository.GetAll(Pager.FromPagerDto(pager)).ConfigureAwait(false)));
        }

        /// <summary>
        /// Get a device by id
        /// </summary>
        /// <param name="id">unique identifier for a device</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [HttpGet]
        [Route("api/admin/[controller]/{id}", Name="GetDevice")]
        [ProducesResponseType(typeof(DeviceDto), 200)]
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


        /// <summary>
        /// Create a new device
        /// </summary>
        /// <remarks>
        /// Id field does not need to be supplied, it is ignored. The unique identifier for the device will be generated by the system.
        /// </remarks>
        /// <response code="201">Created</response>
        /// <response code="400">Invalid Model</response>
        [HttpPost]
        [Route("api/admin/[controller]")]
        [ProducesResponseType(typeof(DeviceDto), 201)]
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

            //TODO: Business Rule validations? For example, check for existing device with same IOT Hub Primary Key.

            await deviceRepository.Add(mapper.Map<DeviceDto, Devices>(item)).ConfigureAwait(false);

            return CreatedAtRoute("GetDevice", new { Controller = "Device", id = item.DeviceId }, item);
        }

        /// <summary>
        /// Modify an existing device
        /// </summary>
        /// <param name="id">unique identifier for a device</param>
        /// <param name="updatedRecord">modified device model</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id or Model</response>
        [HttpPut]
        [Route("api/admin/[controller]/{id}")]
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

        /// <summary>
        /// Delete an existing device
        /// </summary>
        /// <param name="id">unique identifier for a device</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="400">Invalid Id</response>
        [HttpDelete]
        [Route("api/admin/[controller]/{id}")]
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
