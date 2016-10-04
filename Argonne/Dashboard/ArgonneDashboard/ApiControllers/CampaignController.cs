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
        const string BASE_URI = "http://api-argonne.azurewebsites.net";
        //[HttpGet()]
        //[Route("{campaignId}/impressions/aggregate")]
        //[ProducesResponseType(typeof(IEnumerable<DeviceDto>), 200)]
        [ActionName("aggregate")]
        public async Task<AdAggregateData> GetCampaignAggregate(string id)
        {
            
            using (ArgonneServiceClient client = new ArgonneServiceClient())
            {
                client.BaseUri = new Uri(BASE_URI);
                var result = await client.ApiAdminCampaignByCampaignidImpressionsAggregateGetWithOperationResponseAsync(id);
                

                // todo: exception handling

                return null;
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