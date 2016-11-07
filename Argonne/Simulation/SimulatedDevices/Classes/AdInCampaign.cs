//-------------------------------------------------------------------------
// <copyright file="Classes.cs" company="http://www.microsoft.com">
//   MIT License copyright © 2016 by Microsoft Corporation.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Data.SqlClient;

namespace Microsoft.IoTInsiderLab.Argonne.SimulatedDevices
{
    /// <summary>
    /// Immutable container of biases for an ad.
    /// </summary>
    public class AdInCampaign
    {
        public AdInCampaign
            (
                string campaignId,
                string adId,
                string adName,
                short  sequence,
                short  duration,
                short  firstImpression,
                short  impressionInterval,
                double angerBias,
                double contemptBias,
                double disgustBias,
                double fearBias,
                double happinessBias,
                double neutralBias,
                double sadnessBias,
                double surpriseBias
            )
        {
            CampaignId         = campaignId;
            AdId               = adId;
            AdName             = adName;
            Sequence           = sequence;
            Duration           = duration;
            FirstImpression    = firstImpression;
            ImpressionInterval = impressionInterval;
            AngerBias          = angerBias;
            ContemptBias       = contemptBias;
            DisgustBias        = disgustBias;
            FearBias           = fearBias;
            HappinessBias      = happinessBias;
            NeutralBias        = neutralBias;
            SadnessBias        = sadnessBias;
            SurpriseBias       = surpriseBias;
        }
        public string CampaignId { get; }
        public string AdId { get; }
        public string AdName { get; }
        public short Sequence { get; }
        public short Duration { get; }
        public short FirstImpression { get; }
        public short ImpressionInterval { get; }
        public double AngerBias { get; }
        public double ContemptBias { get; }
        public double DisgustBias { get; }
        public double FearBias { get; }
        public double HappinessBias { get; }
        public double NeutralBias { get; }
        public double SadnessBias { get; }
        public double SurpriseBias { get; }
    }
}
