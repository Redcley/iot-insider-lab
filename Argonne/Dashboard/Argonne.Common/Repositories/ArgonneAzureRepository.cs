using Argonne.Common.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Argonne.Common.Models;

namespace Argonne.Common.Repositories
{
    public class ArgonneAzureRepository : IArgonneRepository
    {
        public bool DeleteCampaign(int campaignId)
        {
            throw new NotImplementedException();
        }

        public ICollection<Campaign> GetAllCampaigns()
        {
            throw new NotImplementedException();
        }

        public Campaign GetCampaign(int compaignId)
        {
            throw new NotImplementedException();
        }

        public Campaign SaveCampaign(Campaign campaign)
        {
            throw new NotImplementedException();
        }
    }
}
