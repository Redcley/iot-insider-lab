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
    public class Impression
    {
        /// <summary>
        /// Immutable container of scores for an impression.
        /// </summary>
        public Impression
            (
                string displayedAdId,
                Device device,
                Face[] faces
            )
        {
            this.deviceId      = device.DeviceId;
            this.messageType   = "impression";
            this.messageId     = Guid.NewGuid().ToString();
            this.timestamp     = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
            this.campaignId    = device.AssignedCampaignId;
            this.displayedAdId = displayedAdId;
            this.faces         = faces;
        }
        public string deviceId { get; }
        public string messageType { get; }
        public string messageId { get; }
        public string timestamp { get; }
        public string campaignId { get; }
        public string displayedAdId { get; }
        public Face[] faces { get; }
    }
}