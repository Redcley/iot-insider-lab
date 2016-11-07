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
    /// Immutable container for a single simulated device.
    /// </summary>
    public class Device
    {
        public Device
            (
                string deviceId,
                string primaryKey,
                string deviceName,
                string address,
                string city,
                string stateProvince,
                string postalCode,
                DateTime activeFrom,
                DateTime activeTo,
                string timezone,
                string assignedCampaignId,
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
            DeviceId           = deviceId;
            PrimaryKey         = primaryKey;
            DeviceName         = deviceName;
            Address            = address;
            City               = city;
            StateProvince      = stateProvince;
            PostalCode         = postalCode;
            ActiveFrom         = activeFrom;
            ActiveTo           = activeTo;
            Timezone           = timezone;
            AssignedCampaignId = assignedCampaignId;
            CountBias          = countBias;
            AngerBias          = angerBias;
            ContemptBias       = contemptBias;
            DisgustBias        = disgustBias;
            FearBias           = fearBias;
            HappinessBias      = happinessBias;
            NeutralBias        = neutralBias;
            SadnessBias        = sadnessBias;
            SurpriseBias       = surpriseBias;
        }
        public string DeviceId { get; }
        public string PrimaryKey { get; }
        public string DeviceName { get; }
        public string Address { get; }
        public string City { get; }
        public string StateProvince { get; }
        public string PostalCode { get; }
        public DateTime ActiveFrom { get; }
        public DateTime ActiveTo { get; }
        public string Timezone { get; }
        public string AssignedCampaignId { get; }
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

    /// <summary>
    /// Immutable container of biases of a simulated ad.
    /// </summary>
    public class SimulatedAdInfo
    {
        public SimulatedAdInfo
            (
                string adId,
                string adName,
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
            AdId = adId;
            AdName = adName;
            AngerBias = angerBias;
            ContemptBias = contemptBias;
            DisgustBias = disgustBias;
            FearBias = fearBias;
            HappinessBias = happinessBias;
            NeutralBias = neutralBias;
            SadnessBias = sadnessBias;
            SurpriseBias = surpriseBias;
        }
        public string AdId { get; }
        public string AdName { get; }
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
