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
    /// Immutable container of scores for a face.
    /// </summary>
    public class Scores
    {
        public Scores
            (
                Device device,
                AdInCampaign adInCampaign,
                Random random
            )
        {
            // Calculate biased random values.
            anger     = random.NextDouble() * (adInCampaign.AngerBias     > 1 ? adInCampaign.AngerBias     : device.AngerBias);
            contempt  = random.NextDouble() * (adInCampaign.ContemptBias  > 1 ? adInCampaign.ContemptBias  : device.ContemptBias);
            disgust   = random.NextDouble() * (adInCampaign.DisgustBias   > 1 ? adInCampaign.DisgustBias   : device.DisgustBias);
            fear      = random.NextDouble() * (adInCampaign.FearBias      > 1 ? adInCampaign.FearBias      : device.FearBias);
            happiness = random.NextDouble() * (adInCampaign.HappinessBias > 1 ? adInCampaign.HappinessBias : device.HappinessBias);
            neutral   = random.NextDouble() * (adInCampaign.NeutralBias   > 1 ? adInCampaign.NeutralBias   : device.NeutralBias);
            sadness   = random.NextDouble() * (adInCampaign.SadnessBias   > 1 ? adInCampaign.SadnessBias   : device.SadnessBias);
            surprise  = random.NextDouble() * (adInCampaign.SurpriseBias  > 1 ? adInCampaign.SurpriseBias  : device.SurpriseBias);

            // As these values are random, they may add to less than 1, which would indicate
            // that we are unable to read emotions of this simulated person.
            // To prevent this condition, we will make sure that our numbers add to at least 1. 
            var delta = 1.0 - anger - contempt - disgust - fear
                            - happiness - neutral - sadness - surprise;

            // Do our numbers add to less than 1?
            if (delta > 0)
            {
                // Yes. We add this delta to a randomly selected positive or neutral score.
                // If we have a negative slant for an ad, we tweak negative values;
                // otherwise we tweak positive ones.
                if (adInCampaign.AngerBias    > 1 ||
                    adInCampaign.ContemptBias > 1 ||
                    adInCampaign.DisgustBias  > 1 ||
                    adInCampaign.FearBias     > 1 ||
                    adInCampaign.SadnessBias  > 1)
                {
                    switch (Convert.ToInt32(10 * random.NextDouble()))
                    {
                        case 0:
                        case 1:
                        case 2:
                            anger += delta;
                            break;

                        case 3:
                        case 4:
                        case 5:
                            contempt += delta;
                            break;

                        case 6:
                        case 7:
                            disgust += delta;
                            break;

                        default:
                            sadness += delta;
                            break;
                    }
                }
                else
                {
                    switch (Convert.ToInt32(10 * random.NextDouble()))
                    {
                        case 0:
                        case 1:
                        case 2:
                            neutral += delta;
                            break;

                        case 3:
                        case 4:
                        case 5:
                            surprise += delta;
                            break;

                        default:
                            happiness += delta;
                            break;
                    }
                }
            }
        }

        public double anger { get; }
        public double contempt { get; }
        public double disgust { get; }
        public double fear { get; }
        public double happiness { get; }
        public double neutral { get; }
        public double sadness { get; }
        public double surprise { get; }
    }
}
