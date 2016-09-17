using ArgonneService;
using ArgonneService.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;

namespace ArgonneDashboard.ApiControllers
{
    //[Produces("application/json")]
    public class CampaignController : ApiController
    {       
        //[HttpGet()]
        //[Route("{campaignId}/impressions/aggregate")]
        //[ProducesResponseType(typeof(IEnumerable<DeviceDto>), 200)]
        [ActionName("aggregate")]
        public async Task<IList<AdAggregateData>> GetCampaignAggregate(string id)
        {
            using (ArgonneServiceClient client = new ArgonneServiceClient())
            {
                client.BaseUri = new Uri("http://localhost:44685");
                var result = await client.ApiAdminCampaignByCampaignidImpressionsAggregateGetWithOperationResponseAsync(id);

                // todo: exception handling

                return result.Body;
            }
        }

        // POST api/<controller>
        public void Post([FromBody]string value)
        {
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }
    }
}