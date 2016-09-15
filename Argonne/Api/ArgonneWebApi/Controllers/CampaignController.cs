﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq.Expressions;
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
    /// Administrator API for Campaigns
    /// </summary>
    [Produces("application/json")]
    [EnableCors("AllowCORS")]
    public class CampaignController : Controller
    {
        private IEntityRepository<Campaigns> repository;
        private IEntityRepository<AdsForCampaigns> adForCampaignRepository;
        private IEntityRepository<Devices> deviceRepository;
        private IEntityRepository<Impressions> impressionRepository;
        private IArgonneQueryContext queryContext;
        private IMapper mapper;

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="repo"></param>
        /// <param name="adCampRepo"></param>
        /// <param name="devRepo"></param>
        /// <param name="impRepo"></param>
        /// <param name="entityMapper"></param>
        public CampaignController(IEntityRepository<Campaigns> repo, 
            IEntityRepository<AdsForCampaigns> adCampRepo,
            IEntityRepository<Devices> devRepo,
            IEntityRepository<Impressions> impRepo,
            IArgonneQueryContext query,
            IMapper entityMapper)
        {
            repository = repo;
            mapper = entityMapper;
            adForCampaignRepository = adCampRepo;
            deviceRepository = devRepo;
            impressionRepository = impRepo;
            queryContext = query;
        }
        #region Campaign CRUD
        /// <summary>
        /// Get all campaigns
        /// </summary>
        /// <param name="pager">paging settings</param>
        /// <response code="200">Success</response>
        [Route("api/admin/[controller]")]
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<CampaignDto>), 200)]
        public async Task<IActionResult> GetAll([FromQuery]PagerDto pager)
        {
            return new OkObjectResult(mapper.Map<IEnumerable<Campaigns>, IEnumerable<CampaignDto>>(await repository.GetAll(Pager.FromPagerDto(pager)).ConfigureAwait(false)));
        }

        /// <summary>
        /// Get a campaign by id
        /// </summary>
        /// <param name="id">unique identifier for a campaign</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [HttpGet]
        [Route("api/admin/[controller]/{id}", Name="GetCampaign")]
        [ProducesResponseType(typeof(CampaignDto), 200)]
        public async Task<IActionResult> Get(string id)
        {
            if (string.IsNullOrEmpty(id))
                return BadRequest();

            Guid idGuid;
            if(!Guid.TryParse(id, out idGuid))
            {
                return BadRequest();
            }

            var result = mapper.Map<Campaigns, CampaignDto>(
                await repository.GetSingle(item => item.CampaignId == idGuid).ConfigureAwait(false));

            if (null == result)
                return NotFound();

            return new OkObjectResult(result);
        }


        /// <summary>
        /// Create a new Campaign
        /// </summary>
        /// <remarks>
        /// Id field does not need to be supplied, it is ignored. The unique identifier for the Campaign will be generated by the system.
        /// </remarks>
        /// <response code="201">Created</response>
        /// <response code="400">Invalid Model</response>
        [HttpPost]
        [Route("api/admin/[controller]")]
        [ProducesResponseType(typeof(CampaignDto), 201)]
        public async Task<IActionResult> Create([FromBody]CampaignDto item)
        {
            if (item == null)
            {
                return BadRequest();
            }

            var validator = new CampaignValidator();
            var validationResults = validator.Validate(item);
            if(!validationResults.IsValid)
            {
                return BadRequest(validationResults.Errors);
            }

            item.CampaignId = Guid.NewGuid();

            //TODO: Business Rule validations?

            await repository.Add(mapper.Map<CampaignDto, Campaigns>(item)).ConfigureAwait(false);

            return CreatedAtRoute("GetCampaign", new { Controller = "Campaign", id = item.CampaignId }, item);
        }

        /// <summary>
        /// Modify an existing Campaign
        /// </summary>
        /// <param name="updatedRecord">modified Campaign model</param>
        /// <remarks>
        /// Campaign Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id or Model</response>
        [HttpPut]
        [Route("api/admin/[controller]")]
        public async Task<IActionResult> Update([FromBody]CampaignDto updatedRecord)
        {
            if (updatedRecord == null)
            {
                return BadRequest();
            }

            var validator = new CampaignValidator(true);
            var validationResults = validator.Validate(updatedRecord);
            if (!validationResults.IsValid)
            {
                return BadRequest(validationResults.Errors);
            }

            var existingRecord = await repository.GetSingle(item => item.CampaignId == updatedRecord.CampaignId).ConfigureAwait(false);
            if (null == existingRecord)
                return NotFound();

            mapper.Map(updatedRecord, existingRecord);
            await repository.Update(existingRecord).ConfigureAwait(false);
            return Ok();
        }

        /// <summary>
        /// Delete an existing Campaign
        /// </summary>
        /// <param name="id">unique identifier for a Campaign</param>
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

            await repository.DeleteWhere(item => item.CampaignId == idGuid).ConfigureAwait(false);

            return Ok();
        }
        #endregion
        #region relationship - Ad
        /// <summary>
        /// Get all ads for a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [Route("api/admin/[controller]/{campaignid}/Ads", Name = "GetAds")]
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<AdInCampaignDto>), 200)]
        public async Task<IActionResult> GetAds(string campaignid)
        {
            if (string.IsNullOrEmpty(campaignid))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(campaignid, out idGuid))
            {
                return BadRequest();
            }


            var relations = await adForCampaignRepository.FindBy(item => item.CampaignId == idGuid, Pager.Default);
            if (null == relations)
                return new StatusCodeResult(500);

            var result = mapper.Map<IEnumerable<AdsForCampaigns>, IEnumerable<AdInCampaignDto>>(relations);
            return new OkObjectResult(result);
        }

        /// <summary>
        /// Get ad in a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <param name="adid">unique identifier for an ad</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// AdId must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [Route("api/admin/[controller]/{campaignid}/Ads/{adid}", Name = "GetAdInCampaign")]
        [HttpGet]
        [ProducesResponseType(typeof(AdInCampaignDto), 200)]
        public async Task<IActionResult> GetAdInCampaign(string campaignid, string adid)
        {
            if (string.IsNullOrEmpty(campaignid) || string.IsNullOrEmpty(adid))
                return BadRequest();

            Guid idGuid;
            Guid adidGuid;
            if (!Guid.TryParse(campaignid, out idGuid) || !Guid.TryParse(adid, out adidGuid))
            {
                return BadRequest();
            }


            var adInCampaign = await adForCampaignRepository.GetSingle(item => item.CampaignId == idGuid && item.AdId == adidGuid);
            if (null == adInCampaign)
                return NotFound();

            var result = mapper.Map<AdsForCampaigns, AdInCampaignDto>(adInCampaign);
            return new OkObjectResult(result);
        }

        /// <summary>
        /// Add an Ad to a Campaign
        /// </summary>
        /// <remarks>
        /// An add can be in multiple campaigns at the same time
        /// </remarks>
        /// <response code="201">Created</response>
        /// <response code="400">Invalid Model</response>
        [Route("api/admin/[controller]/Ads")]
        [HttpPost]
        [ProducesResponseType(typeof(AdInCampaignDto), 201)]
        public async Task<IActionResult> AddAdToCampaign([FromBody]AdInCampaignDto item)
        {
            if (item == null)
            {
                return BadRequest();
            }

            var validator = new AdInCampaignValidator();
            var validationResults = validator.Validate(item);
            if (!validationResults.IsValid)
            {
                return BadRequest(validationResults.Errors);
            }

            await adForCampaignRepository.Add(mapper.Map<AdInCampaignDto, AdsForCampaigns>(item)).ConfigureAwait(false);

            return CreatedAtRoute("GetAdInCampaign", new { Controller = "Campaign", id = item.CampaignId, adid = item.AdId }, item);
        }

        /// <summary>
        /// Modify properties of an existing Campaign to Ad relationship
        /// </summary>
        /// <param name="updatedRecord">modified model</param>
        /// <remarks>
        /// Campaign Id must be a valid GUID.
        /// Ad Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id or Model</response>
        [HttpPut]
        [Route("api/admin/[controller]/Ads")]
        public async Task<IActionResult> UpdateAdInCampaign([FromBody]AdInCampaignDto updatedRecord)
        {
            if (updatedRecord == null)
            {
                return BadRequest();
            }

            var validator = new AdInCampaignValidator();
            var validationResults = validator.Validate(updatedRecord);
            if (!validationResults.IsValid)
            {
                return BadRequest(validationResults.Errors);
            }

            var existingRecord = await adForCampaignRepository.GetSingle(
                item => item.CampaignId == updatedRecord.CampaignId && item.AdId == updatedRecord.AdId).ConfigureAwait(false);

            if (null == existingRecord)
                return NotFound();

            mapper.Map(updatedRecord, existingRecord);
            await adForCampaignRepository.Update(existingRecord).ConfigureAwait(false);
            return Ok();
        }

        /// <summary>
        /// Remove an ad from a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a Campaign</param>
        /// <param name="adid">unique identifier for an ad</param>
        /// <remarks>
        /// Id must be a valid GUID.
        /// AdId must be a valid GUID.
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="400">Invalid Id</response>
        [HttpDelete]
        [Route("api/admin/[controller]/{campaignid}/Ads/{adid}")]
        public async Task<IActionResult> RemoveAdFromCampaign(string campaignid, string adid)
        {
            if (string.IsNullOrEmpty(campaignid) || string.IsNullOrEmpty(adid))
                return BadRequest();

            Guid idGuid;
            Guid adGuid;
            if (!Guid.TryParse(campaignid, out idGuid) || !Guid.TryParse(adid, out adGuid))
            {
                return BadRequest();
            }

            await adForCampaignRepository.DeleteWhere(item => item.CampaignId == idGuid && item.AdId == adGuid).ConfigureAwait(false);

            return Ok();
        }
        #endregion
        #region relationship - Device
        /// <summary>
        /// Get all Devices for a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [Route("api/admin/[controller]/{campaignid}/Devices", Name = "GetDevices")]
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<Devices>), 200)]
        public async Task<IActionResult> GetDevices(string campaignid)
        {
            if (string.IsNullOrEmpty(campaignid))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(campaignid, out idGuid))
            {
                return BadRequest("invalid campaign id");
            }


            var relations = await deviceRepository.FindBy(item => item.AssignedCampaignId == idGuid, Pager.Default);
            if (null == relations)
                return new StatusCodeResult(500);

            var result = mapper.Map<IEnumerable<Devices>, IEnumerable<DeviceDto>>(relations);
            return new OkObjectResult(result);
        }

        /// <summary>
        /// Add a Device to a Campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <param name="deviceid">unique identifier for a device</param>
        /// <remarks>
        /// A device can only be in one campaign at a time.
        /// If a device is already in another campaign when this is called it will be removed from the old campaign.
        /// </remarks>
        /// <response code="201">Created</response>
        /// <response code="400">Invalid Model</response>
        /// <response code="404">Not Found</response>
        [Route("api/admin/[controller]/{campaignid}/Devices/{deviceid}")]
        [HttpPost]
        public async Task<IActionResult> AddDeviceToCampaign(string campaignid, string deviceid)
        {
            if (string.IsNullOrEmpty(campaignid) || string.IsNullOrEmpty(deviceid))
            {
                return BadRequest();
            }

            Guid idGuid;
            Guid deviceGuid;
            if (!Guid.TryParse(campaignid, out idGuid) || !Guid.TryParse(deviceid, out deviceGuid))
            {
                return BadRequest();
            }

            var device = await deviceRepository.GetSingle(item => item.DeviceId == deviceGuid).ConfigureAwait(false);
            if (null == device)
            {
                return NotFound("device not found");
            }

            var campaign = await repository.GetSingle(item => item.CampaignId == idGuid).ConfigureAwait(false);
            if (null == campaign)
            {
                return NotFound("campaign not found");
            }

            device.AssignedCampaignId = campaign.CampaignId;

            await deviceRepository.Update(device).ConfigureAwait(false);

            return Ok();
        }

        /// <summary>
        /// Remove a device from a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a Campaign</param>
        /// <param name="deviceid">unique identifier for a device</param>
        /// <remarks>
        /// Id must be a valid GUID.
        /// DeviceId must be a valid GUID.
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="400">Invalid Id</response>
        /// <response code="404">Not Found</response>
        [HttpDelete]
        [Route("api/admin/[controller]/{campaignid}/Devices/{deviceid}")]
        public async Task<IActionResult> RemoveDeviceFromCampaign(string campaignid, string deviceid)
        {
            if (string.IsNullOrEmpty(campaignid) || string.IsNullOrEmpty(deviceid))
                return BadRequest();

            Guid idGuid;
            Guid deviceGuid;
            if (!Guid.TryParse(campaignid, out idGuid) || !Guid.TryParse(deviceid, out deviceGuid))
            {
                return BadRequest();
            }

            var device = await deviceRepository.GetSingle(item => item.DeviceId == deviceGuid).ConfigureAwait(false);
            if (null == device)
            {
                return NotFound();//"device not found");
            }

            device.AssignedCampaignId = null;
            await deviceRepository.Update(device).ConfigureAwait(false);
            return Ok();
        }
        #endregion
        #region relationship - Impression
        /// <summary>
        /// Get All Impressions for a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <param name="pager">paging settings</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [Route("api/admin/[controller]/{campaignid}/Impressions", Name = "GetImpressionsForCampaign")]
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ImpressionDto>), 200)]
        public async Task<IActionResult> GetImpressions(string campaignid, [FromQuery]PagerDto pager)
        {
            if (string.IsNullOrEmpty(campaignid))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(campaignid, out idGuid))
            {
                return BadRequest("invalid campaign id");
            }

            var relations = await impressionRepository.FindBy(item => item.CampaignId == idGuid,
                Pager.FromPagerDto(pager), item => item.FacesForImpressions);

            if (null == relations)
                return new StatusCodeResult(500);

            var result = mapper.Map<IEnumerable<Impressions>, IEnumerable<ImpressionDto>>(relations);
            return new OkObjectResult(result);
        }

        /// <summary>
        /// Get All Impressions for a campaign
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <param name="after">timestamp for start of series</param>
        /// <param name="pager">paging settings</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [Route("api/admin/[controller]/{campaignid}/Impressions/After", Name = "GetImpressionsForCampaignAfter")]
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ImpressionDto>), 200)]
        public async Task<IActionResult> GetImpressionsAfter(string campaignid, [FromQuery]PagerDto pager, [FromQuery]DateTime? after = null)
        {
            if (string.IsNullOrEmpty(campaignid))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(campaignid, out idGuid))
            {
                return BadRequest("invalid campaign id");
            }

            Expression<Func<Impressions, bool>> predicate = item => item.CampaignId == idGuid;
            if (null != after)
            {
                predicate = item => item.CampaignId == idGuid && item.InsertTimestamp > after;
            }

            var sorter = new Order<Impressions, DateTime>
            {
                OrderByDirection = Order<Impressions, DateTime>.Direction.Descending,
                KeySelector = item => item.InsertTimestamp
            };

            var relations = await impressionRepository.FindByOrdered(predicate,
                Pager.FromPagerDto(pager), sorter, item => item.FacesForImpressions);

            if (null == relations)
                return new StatusCodeResult(500);

            var result = mapper.Map<IEnumerable<Impressions>, IEnumerable<ImpressionDto>>(relations);
            return new OkObjectResult(result);
        }
        #endregion
        #region relationship - Emotion
        /// <summary>
        /// Get the highest scoring (average) emotion for a campaign during an interval of time
        /// </summary>
        /// <param name="campaignid">unique identifier for a campaign</param>
        /// <param name="pager">paging settings</param>
        /// <param name="start">timestamp for start of series</param>
        /// <param name="end">timestamp for end of series</param>
        /// <remarks>
        /// Id must be a valid GUID
        /// </remarks>
        /// <response code="200">Success</response>
        /// <response code="404">Not Found</response>
        /// <response code="400">Invalid Id</response>
        [Route("api/admin/[controller]/{campaignid}/emotions/strongest", Name = "GetHighestEmotionForCampaign")]
        [HttpGet]
        [ProducesResponseType(typeof(string), 200)]
        public async Task<IActionResult> GetHighestScoringEmotion(string campaignid, 
            [FromQuery]PagerDto pager,
            [FromQuery]DateTime? start = null, 
            [FromQuery]DateTime? end = null)
        {
            if (string.IsNullOrEmpty(campaignid))
                return BadRequest();

            Guid idGuid;
            if (!Guid.TryParse(campaignid, out idGuid))
            {
                return BadRequest("invalid campaign id");
            }

            //if start and end are not supplied then treat as "for all time"
            if(null == start)
                start = DateTime.UtcNow - TimeSpan.FromDays(365*10);

            if(null == end)
                end = DateTime.UtcNow + TimeSpan.FromDays(1);

            var campaignIdParam = new SqlParameter("@CampaignId", idGuid);
            var startDateParam = new SqlParameter("@dateFrom", start);
            var endDateParam = new SqlParameter("@dateTo", end);

            var result = await queryContext.Query<CampaignEmotion>("GetHighestAverageScoresForCampaigns @CampaignId,@dateFrom,@dateTo", campaignIdParam,
                startDateParam, endDateParam).ConfigureAwait(false);
            return new OkObjectResult(result);
        }

        #endregion
    }
}
