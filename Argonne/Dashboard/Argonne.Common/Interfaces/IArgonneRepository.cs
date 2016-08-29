using Argonne.Common.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Argonne.Common.Interfaces
{
    public interface IArgonneRepository
    {
        /// <summary>
        /// Get all campaign
        /// </summary>
        /// <returns></returns>
        ICollection<Campaign> GetAllCampaigns();

        /// <summary>
        /// Get the details of the campaign
        /// </summary>
        /// <param name="compaignId"></param>
        /// <returns></returns>
        Campaign GetCampaign(int compaignId);

        /// <summary>
        /// Creates or updates the campaign
        /// </summary>
        /// <param name="campaign"></param>
        /// <returns></returns>
        Campaign SaveCampaign(Campaign campaign);

        bool DeleteCampaign(int campaignId);
    }
}
