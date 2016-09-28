//-------------------------------------------------------------------------
// <copyright file="SimulatedDevices.cs" company="http://www.microsoft.com">
//   MIT License Copyright © 2016 by Microsoft Corporation.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Diagnostics;
using System.Data.SqlClient;

using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;

using Microsoft.IoTInsiderLab.Argonne.Common;

namespace Microsoft.IoTInsiderLab.Argonne.SimulatedDevices
{
    public partial class SimulatedDevices : Form
    {
        // IMPLEMENTATION NOTE
        // As Wait in a Windows Form code is interpreted as code running and makes the app unresponsive,
        // we are using two timers that free the Forms app threads.

        #region Declarations

        // One client for each device.
        private Dictionary<string, DeviceClient> _clients = new Dictionary<string, DeviceClient>();

        // List of devices simulated by the clients.
        private Dictionary<string, Device> _simulatedDevices = new Dictionary<string, Device>();

        // Stopwatches for devices.
        private Dictionary<string, Stopwatch> _stopwatches = new Dictionary<string, Stopwatch>();

        // List of failing devices.
        private List<string> _failingDevices = new List<string>();

        // Dictionary of ads per campaign.
        private Dictionary<string, List<AdInCampaign>> _adsInCampaigns = new Dictionary<string, List<AdInCampaign>>();

        // Work queue for the timer sending messages.
        private Queue<string> _queueDeviceIds = new Queue<string>();

        // Break button state.
        private bool _wasBreak = false;

        // Context menu indicator.
        private bool _wasHitOnACell = false;

        // We want one sequence or random numbers for the entire run.
        private static Random _random = new Random();

        #endregion

        #region Constructor
        public SimulatedDevices()
        {
            InitializeComponent();
        }

        #endregion

        #region Event handlers

        private void SimulatedDevices_Load(object sender, EventArgs e)
        {
            // Show the form as it is filled.
            this.Show();
            Application.DoEvents();

            LoadDevicesAsync();
            LoadAdsInCampaignsAsync();

            // Set the timer to click almost immediately.
            timerMainLoop.Interval = 1;  // ms
            timerMainLoop.Start();
        }

        private void timerMainLoop_Tick(object sender, EventArgs e)
        {
            // Make sure that we do not reenter during execution.
            timerMainLoop.Stop();

            // Check for the break state.
            if (_wasBreak)
            {
                this.Close();
            }

            // Queue entries for the timerSendMessage timer.
            foreach (var simulatedDeviceInfo in _simulatedDevices.Values)
            {
                // This makes us send a message three out of four cases for devices with CountBias = 1.
                if (_random.NextDouble() * simulatedDeviceInfo.CountBias > .25)
                {
                    _queueDeviceIds.Enqueue(simulatedDeviceInfo.DeviceId);
                }
            }

            // Start the timerSendMessage timer almost immediately.
            timerSendMessage.Interval = 1;
            timerSendMessage.Start();
        }

        private void timerSendMessage_Tick(object sender, EventArgs e)
        {
            // Make sure that we do not reenter during execution.
            timerSendMessage.Stop();
            Application.DoEvents();

            // Check for the break state.
            if (_wasBreak)
            {
                this.Close();
            }

            // Do we have a device to simulate?
            if (_queueDeviceIds.Count > 0)
            {
                // We do - let's simulate it (if it is not 'failing').
                var deviceId = _queueDeviceIds.Dequeue();
                if (!_failingDevices.Contains(deviceId))
                {
                    SendDeviceToCloudMessagesAsync(_simulatedDevices[deviceId], _clients[deviceId]);
                }

                // Continue after a random interval.
                // Delay numbers are tweked to make the cycle ~5 s.
                Application.DoEvents();
                timerSendMessage.Interval = 1 + Convert.ToInt32(10 * _random.NextDouble());
                timerSendMessage.Start();
            }
            else
            {
                // We do not have any device to simulate in this pass.
                // Do the next pass after a random period 1-2 seconds.
                timerMainLoop.Interval = 1000 + Convert.ToInt32(1000 * _random.NextDouble());
                timerMainLoop.Start();
            }

            // Check again for the break state.
            if (_wasBreak)
            {
                this.Close();
            }

        }

        private void button_Click(object sender, EventArgs e)
        {
            // Indicate the event to the timer threads.
            _wasBreak = true;
        }

        private void dataGridView_MouseDown(object sender, MouseEventArgs e)
        {
            // We handle only right click before contextMenuStrip_Opening.
            if (e.Button == MouseButtons.Right)
            {
                // If the hit is on a cell, select the row.
                var hit = dataGridView.HitTest(e.X, e.Y);
                if (hit.Type == DataGridViewHitTestType.Cell)
                {
                    dataGridView.Rows[hit.RowIndex].Selected = true;
                    _wasHitOnACell = true;
                }
                else
                {
                    _wasHitOnACell = false;
                }
            }
        }

        private void contextMenuStrip_Opening(object sender, CancelEventArgs e)
        {
            // We open the menu only over valid cells.
            if (!_wasHitOnACell)
            {
                e.Cancel = true;
                return;
            }

            var deviceId = dataGridView.SelectedRows[0].Cells[0].Value.ToString();
            if (_failingDevices.Contains(deviceId))
            {
                // This is a failing device and we can make it run normally.
                contextMenuStrip.Items[0].Text = "Make work normally";
            }
            else
            {
                // This is a normally running device and we can make it fail.
                contextMenuStrip.Items[0].Text = "Make fail";
            }
        }

        private void contextMenuStrip_Click(object sender, EventArgs e)
        {
            // Tweak the foreground color.
            var deviceId = dataGridView.SelectedRows[0].Cells[0].Value.ToString();
            if (_failingDevices.Contains(deviceId))
            {
                // This is a failing device and we will make it run normally.
                for (var c = 0; c < dataGridView.SelectedRows[0].Cells.Count; c++)
                {
                    dataGridView.SelectedRows[0].Cells[c].Style.ForeColor = Color.Black;
                }

                _failingDevices.Remove(deviceId);
            }
            else
            {
                // This is a normally running device and we will make it fail.
                for (var c = 0; c < dataGridView.SelectedRows[0].Cells.Count; c++)
                {
                    dataGridView.SelectedRows[0].Cells[c].Style.ForeColor = Color.Red;
                }

                _failingDevices.Add(deviceId);
            }

            // Display the status.
            switch (_failingDevices.Count)
            {
                case 0:
                    toolStripStatusLabel.Text = "All devices are working normally.";
                    break;

                case 1:
                    toolStripStatusLabel.Text = "One device is failing.";
                    break;

                default:
                    toolStripStatusLabel.Text = $"{_failingDevices.Count} devices are failing.";
                    break;
            }
        }

        #endregion

        #region Private methods

        private async void LoadAdsInCampaignsAsync()
        {
            // Get the simulated devices. They have entries in the BiasesForDevices table.
            // As this is always run in Visual Studio in debug mode, we do not have to handle errors programmatically.
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = new SqlConnection(Common.ConnectionStrings.Database);
                try
                {
                    cmd.Connection.Open();
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("Error opening SQL connection: " + ex.Message);
                    // Put a breakpoint on this line:
                    return;
                }

                cmd.CommandText =
                "SELECT c.CampaignId " +
                "      ,a.AdId " +
                "      ,AdName " +
                "      ,Sequence " +
                "      ,Duration " +
                "      ,FirstImpression " +
                "      ,ImpressionInterval " +
                "      ,AngerBias " +
                "      ,ContemptBias " +
                "      ,DisgustBias " +
                "      ,FearBias " +
                "      ,HappinessBias " +
                "      ,NeutralBias " +
                "      ,SadnessBias " +
                "      ,SurpriseBias " +
                "FROM   AdsForCampaigns afc " +
                "       INNER JOIN Campaigns c " +
                "               ON c.CampaignId = afc.CampaignId " +
                "       INNER JOIN Ads a " +
                "               ON a.AdId = afc.AdId " +
                "       INNER JOIN BiasesForAds b " +
                "               ON b.AdId = a.AdId " +
                "ORDER BY c.CampaignId, Sequence";

                using (var reader = cmd.ExecuteReader())
                {
                    while (await reader.ReadAsync())
                    {
                        var adInCampaign = new AdInCampaign
                            (
                                campaignId:         reader.GetGuid(reader.GetOrdinal  ("CampaignId")).ToString(),
                                adId:               reader.GetGuid(reader.GetOrdinal  ("AdId")).ToString(),
                                adName:             reader.GetString(reader.GetOrdinal("AdName")),
                                sequence:           reader.GetInt16(reader.GetOrdinal ("Sequence")),
                                duration:           reader.GetInt16(reader.GetOrdinal ("Duration")),
                                firstImpression:    reader.GetInt16(reader.GetOrdinal ("FirstImpression")),
                                impressionInterval: reader.GetInt16(reader.GetOrdinal ("ImpressionInterval")),
                                angerBias:          reader.GetDouble(reader.GetOrdinal("AngerBias")),
                                contemptBias:       reader.GetDouble(reader.GetOrdinal("ContemptBias")),
                                disgustBias:        reader.GetDouble(reader.GetOrdinal("DisgustBias")),
                                fearBias:           reader.GetDouble(reader.GetOrdinal("FearBias")),
                                happinessBias:      reader.GetDouble(reader.GetOrdinal("HappinessBias")),
                                neutralBias:        reader.GetDouble(reader.GetOrdinal("NeutralBias")),
                                sadnessBias:        reader.GetDouble(reader.GetOrdinal("SadnessBias")),
                                surpriseBias:       reader.GetDouble(reader.GetOrdinal("SurpriseBias"))
                            );

                        // Add this ad to the dictionary.
                        // If needed, create a new key.
                        if (!_adsInCampaigns.Keys.Contains(adInCampaign.CampaignId))
                        {
                            _adsInCampaigns.Add(adInCampaign.CampaignId, new List<AdInCampaign>());
                        }

                        _adsInCampaigns[adInCampaign.CampaignId].Add(adInCampaign);
                    }
                }
            }
        }

        private async void LoadDevicesAsync()
        {
            // Get the simulated devices. They have entries in the BiasesForDevices table.
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = new SqlConnection(Common.ConnectionStrings.Database);
                try
                {
                    cmd.Connection.Open();
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("Error opening SQL connection: " + ex.Message);
                    // Put a breakpoint on this line:
                    return;
                }

                cmd.CommandText =
                "SELECT * " +
                "FROM   BiasesForDevices b " +
                "       INNER JOIN Devices d " +
                "               ON d.DeviceId = b.DeviceId";

                using (var reader = cmd.ExecuteReader())
                {
                    while (await reader.ReadAsync())
                    {
                        var device = new Device
                            (
                                deviceId:      reader.GetGuid(reader.GetOrdinal    ("DeviceId")).ToString(),
                                primaryKey:    reader.GetString(reader.GetOrdinal  ("PrimaryKey")),
                                deviceName:    reader.GetString(reader.GetOrdinal  ("DeviceName")),
                                address:       reader.GetString(reader.GetOrdinal  ("Address")),
                                city:          reader.GetString(reader.GetOrdinal  ("City")),
                                stateProvince: reader.GetString(reader.GetOrdinal  ("StateProvince")),
                                postalCode:    reader.GetString(reader.GetOrdinal  ("PostalCode")),
                                activeFrom:    reader.GetDateTime(reader.GetOrdinal("ActiveFrom")),
                                activeTo:      reader.GetDateTime(reader.GetOrdinal("ActiveTo")),
                                timezone:      reader.GetString(reader.GetOrdinal  ("Timezone")),
                                countBias:     reader.GetDouble(reader.GetOrdinal  ("CountBias")),
                                angerBias:     reader.GetDouble(reader.GetOrdinal  ("AngerBias")),
                                contemptBias:  reader.GetDouble(reader.GetOrdinal  ("ContemptBias")),
                                disgustBias:   reader.GetDouble(reader.GetOrdinal  ("DisgustBias")),
                                fearBias:      reader.GetDouble(reader.GetOrdinal  ("FearBias")),
                                happinessBias: reader.GetDouble(reader.GetOrdinal  ("HappinessBias")),
                                neutralBias:   reader.GetDouble(reader.GetOrdinal  ("NeutralBias")),
                                sadnessBias:   reader.GetDouble(reader.GetOrdinal  ("SadnessBias")),
                                surpriseBias:  reader.GetDouble(reader.GetOrdinal  ("SurpriseBias")),
                                assignedCampaignId:
                                               reader.IsDBNull(reader.GetOrdinal("AssignedCampaignId"))
                                               ? string.Empty
                                               : reader.GetGuid(reader.GetOrdinal("AssignedCampaignId")).ToString()
                            );

                        // Add this device to its private collections.
                        _simulatedDevices.Add(device.DeviceId, device);
                        _clients.Add(device.DeviceId,
                                     DeviceClient.Create("IoTLabArgonneIoTHub.azure-devices.net",
                                                         new DeviceAuthenticationWithRegistrySymmetricKey(device.DeviceId, device.PrimaryKey)));

                        // Add this device to the grid.
                        dataGridView.Rows.Add(new string[]
                            {
                                device.DeviceId,
                                device.DeviceName,
                                device.Address,
                                device.City,
                                device.StateProvince,
                                device.PostalCode
                            } );
                    }

                    // This should not be needed but it is:
                    reader.Close();
                }
            }

            // Sort the filled grid.
            dataGridView.Sort(dataGridView.Columns["DeviceName"], ListSortDirection.Ascending);
        }

        private async void SendDeviceToCloudMessagesAsync(Device device, DeviceClient deviceClient)
        {
            // Find which ad we are showing.
            // Do we have a stopwatch for this device?
            if (!_stopwatches.ContainsKey(device.DeviceId))
            {
                // We do not have this one - let's add it.
                _stopwatches.Add(device.DeviceId, new Stopwatch());
                _stopwatches[device.DeviceId].Start();
            }

            // Find which ad we are running.

            // Get the campaign for this device.
            // For simplicity we assume that it is the last one that was pushed to the device. 
            var campaign = device.AssignedCampaignId;

            // This tells us how many seconds elapsed since the start of the first ad.
            var elapsed = _stopwatches[device.DeviceId].ElapsedMilliseconds / 1000;

            // How many seconds since the start of the current run?
            var seconds = 0;

            // We will find the now playing ad.
            AdInCampaign currentAd = null;
            for (var i = 0; i < _adsInCampaigns[campaign].Count; i++)
            {
                // Time elapsed at the end of this ad.
                seconds += _adsInCampaigns[campaign][i].Duration;

                // Are we within?
                if (elapsed <= seconds)
                {
                    // Yes, we are: this is now playing.
                    currentAd = _adsInCampaigns[campaign][i];
                    break;
                }
            }

            // Did we find the playing ad?
            if (currentAd == null)
            {
                // No, we did not - we are out of the campaign play time.
                // Restart the cycle, which means that we are playing the first ad.
                _stopwatches[device.DeviceId].Stop();
                _stopwatches[device.DeviceId].Start();
                currentAd = _adsInCampaigns[campaign][0];
            }

            // We will have a random number of faces.
            // Probability to add the next face decreases.
            var faces = new List<Face>();
            for (var magic = .00; magic <= .70; magic += .10)
            {
                if (_random.NextDouble() > magic)
                {
                    faces.Add(new Face(Convert.ToInt32(5 + 100 * magic), .4 + magic / 6, new Scores(device, currentAd, _random), device.DeviceId, _random));
                }
            }

            var impression = new Impression(currentAd.AdId, device, faces.ToArray());
            var messageString = JsonConvert.SerializeObject(impression);

            // if the scores object is empty, we remove it.
            messageString = messageString.Replace(",\"scores\":null", string.Empty);

            var message = new Microsoft.Azure.Devices.Client.Message(Encoding.ASCII.GetBytes(messageString));
            try
            {
                await deviceClient.SendEventAsync(message).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("Cannot access a disposed object"))
                {
                    // Ignore this random error - this is just a simulation.
                }
                else
                {
                    // TODO
                }
            }
        }

        #endregion
    }
}
