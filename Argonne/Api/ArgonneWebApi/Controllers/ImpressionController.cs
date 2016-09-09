//using System;
//using System.Collections.Generic;
//using System.Threading.Tasks;
//using ArgonneWebApi.Models.Datastore;
//using ArgonneWebApi.Models.Dto;
//using ArgonneWebApi.Models.Validation;
//using ArgonneWebApi.Repositories;
//using AutoMapper;
//using Microsoft.AspNetCore.Mvc;
//
//namespace ArgonneWebApi.Controllers
//{
//    /// <summary>
//    /// Administrator API for Impressions
//    /// </summary>
//    [Produces("application/json")]
//    public class ImpressionController : Controller
//    {
//        private IEntityRepository<Impressions> repository;
//        private IMapper mapper;
//
//        /// <summary>
//        /// Constructor
//        /// </summary>
//        /// <param name="repo"></param>
//        /// <param name="entityMapper"></param>
//        public ImpressionController(IEntityRepository<Impressions> repo, IMapper entityMapper)
//        {
//            repository = repo;
//            mapper = entityMapper;
//        }
//
//        /// <summary>
//        /// Get all Impressions
//        /// </summary>
//        /// <response code="200">Success</response>
//        [HttpGet]
//        [Route("api/admin/[controller]")]
//        [ProducesResponseType(typeof(IEnumerable<ImpressionDto>), 200)]
//        public async Task<IActionResult> GetAll()
//        {
//            return new OkObjectResult(mapper.Map<IEnumerable<Impressions>, IEnumerable<ImpressionDto>>(await repository.GetAll().ConfigureAwait(false)));
//        }
//
//        /// <summary>
//        /// Get a Impression by id
//        /// </summary>
//        /// <param name="id">unique identifier for a Impression</param>
//        /// <response code="200">Success</response>
//        /// <response code="404">Not Found</response>
//        /// <response code="400">Invalid Id</response>
//        [Route("api/admin/[controller]/{id}", Name = "GetImpression")]
//        [ProducesResponseType(typeof(ImpressionDto), 200)]
//        public async Task<IActionResult> Get(long id)
//        { 
//            var result = mapper.Map<Impressions, ImpressionDto>(
//                await repository.GetSingle(item => item.ImpressionId == id).ConfigureAwait(false));
//
//            if (null == result)
//                return NotFound();
//
//            return new OkObjectResult(result);
//        }
//    }
//}
