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

                    // We may hit this on the first Impression - we need to check.
                    switch (ids.Count)
                    {
                        case 0:
                        case 1:
                            var id = Guid.NewGuid().ToString();
                            this.faceId = id.Substring(0, id.IndexOf("-"));
                            break;

                        default:
                            this.faceId = ids[random.Next(0, ids.Count)];
                            break;
                    }
                }
            }

            this.age    = ageBias + Convert.ToInt32(25 * random.NextDouble());
            this.gender = random.NextDouble() > genderBias ? "male" : "female";
            this.scores = scores;
            if (this.age > 80)
            {
                this.age = this.age / 2;
            }
        }
        public string faceId { get; }
        public int age { get; }
        public string gender { get; }
        public Scores scores { get; }
    }
}
