//-------------------------------------------------------------------------
// <copyright file="Classes.cs" company="http://www.microsoft.com">
//   Copyright © 2016 by Microsoft Corporation. All rights reserved.
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

    public class Impression
    {
        /// <summary>
        /// Immutable container of scores for an impression.
        /// </summary>
        public Impression
            (
                SimulatedDeviceInfo simulatedDeviceInfo,
                Face[] faces
            )
        {
            this.deviceId      = simulatedDeviceInfo.DeviceId;
            this.faces         = faces;
            this.messageType   = "impression";
            this.messageId     = Guid.NewGuid().ToString();
            this.timestamp     = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
            this.displayedAdId = "3149351f-3c9e-4d0a-bfa5-d8caacfd77f2";
        }
        public string deviceId { get; }
        public string messageType { get; }
        public string messageId { get; }
        public string timestamp { get; }
        public string displayedAdId { get; }
        public Face[] faces { get; }
    }

    /// <summary>
    /// Immutable container for a single face.
    /// </summary>
    public class Face
    {
        public Face
            (
                int ageBias,
                double genderBias,
                Scores scores,
                string deviceId,
                Random random
            )
        {
            // We either use an existing face ID or generate a new one.
            // We get null device ID if the face is unrecognizable.
            if (deviceId == null || random.NextDouble() > .07)
            {
                // Simpler case: we generate a new ID.
                var id = Guid.NewGuid().ToString();
                this.faceId = id.Substring(0, id.IndexOf("-"));
            }
            else
            {
                // We get a randomly selected existing ID.
                var ids = new List<string>();
                using (var cmd = new SqlCommand())
                {
                    cmd.Connection = new SqlConnection(Common.ConnectionStrings.Database);
                    cmd.Connection.Open();

                    // BiasesForDevices contains only rows for which we have postal codes.
                    cmd.CommandText =
                        "SELECT DISTINCT FaceId " +
                        "FROM   FacesForImpressions f " +
                        "       INNER JOIN Impressions i " +
                        "               ON i.ImpressionId = f.ImpressionId " +
                        $"WHERE DeviceId = '{deviceId}'"
                        ;

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ids.Add(reader.GetString(0));
                        }
                    }

                    this.faceId = ids[random.Next(0, ids.Count)];
                }
            }

            this.age    = ageBias + Convert.ToInt32(65 * random.NextDouble());
            this.gender = random.NextDouble() > genderBias ? "male" : "female";
            this.scores = scores;
        }
        public string faceId { get; }
        public int age { get; }
        public string gender { get; }
        public Scores scores { get; }
    }

    /// <summary>
    /// Immutable container of scores for a face.
    /// </summary>
    public class Scores
    {
        public Scores
            (
                SimulatedDeviceInfo simulatedDeviceInfo,
                Random random
            )
        {
            // Calculate biased random values.
            anger     = random.NextDouble() * simulatedDeviceInfo.AngerBias;
            contempt  = random.NextDouble() * simulatedDeviceInfo.ContemptBias;
            disgust   = random.NextDouble() * simulatedDeviceInfo.DisgustBias;
            fear      = random.NextDouble() * simulatedDeviceInfo.FearBias;
            happiness = random.NextDouble() * simulatedDeviceInfo.HappinessBias;
            neutral   = random.NextDouble() * simulatedDeviceInfo.NeutralBias;
            sadness   = random.NextDouble() * simulatedDeviceInfo.SadnessBias;
            surprise  = random.NextDouble() * simulatedDeviceInfo.SurpriseBias;

            // As these values are random, they should add to less than 1.
            var delta = 1.0 - anger - contempt - disgust - fear
                            - happiness - neutral - sadness - surprise;

            // We will add this delta to a randomly selected positive or neutral score.
            // We slightly favor Happiness which gets 4 out of 10.
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
        public double anger { get; }
        public double contempt { get; }
        public double disgust { get; }
        public double fear { get; }
        public double happiness { get; }
        public double neutral { get; }
        public double sadness { get; }
        public double surprise { get; }
    }

    /// <summary>
    /// Immutable container of biases of a single simulated device.
    /// </summary>
    public class SimulatedDeviceInfo
    {
        public SimulatedDeviceInfo
            (
                string deviceId,
                string primaryKey,
                double countBias,
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
            DeviceId      = deviceId;
            PrimaryKey    = primaryKey;
            CountBias     = countBias;
            AngerBias     = angerBias;
            ContemptBias  = contemptBias;
            DisgustBias   = disgustBias;
            FearBias      = fearBias;
            HappinessBias = happinessBias;
            NeutralBias   = neutralBias;
            SadnessBias   = sadnessBias;
            SurpriseBias  = surpriseBias;
        }
        public string DeviceId { get; }
        public string PrimaryKey { get; }
        public double CountBias { get; }
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
