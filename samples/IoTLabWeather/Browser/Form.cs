
//-------------------------------------------------------------------------
// <copyright file="Form.cs" company="http://www.microsoft.com">
//   Copyright © 2016 by Microsoft Corporation. All rights reserved.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Configuration;
using System.Diagnostics;
using System.Xml;
using System.Xml.Linq;

using IoTLabWeather.DataAccess;

namespace Browser
{
    public partial class BrowserForm : Form
    {
        #region Declarations

        private Queue<string> _connectionStrings = new Queue<string>();
        private string _connectionString;

        private Queue<string> _queue = new Queue<string>();
        private int _retries = 0;

        private Stopwatch _stopwatch = new Stopwatch();
        private long _numberOfTrips = 0,
                     _totalMs = 0;

        #endregion

        public BrowserForm()
        {
            InitializeComponent();
        }

        private void BrowserForm_Load(object sender, EventArgs e)
        {
            this.Show();
            this.Refresh();

            // Connection strings are in App.config.
            _connectionStrings.Enqueue(ConfigurationManager.ConnectionStrings[0].ToString());
            _connectionStrings.Enqueue(ConfigurationManager.ConnectionStrings[1].ToString());

            // Start processing on the first connection.
            GetLocations();
        }

        private void webBrowser_Navigated(object sender, WebBrowserNavigatedEventArgs e)
        {
            // We have to check for the first navigation.
            // If the sender is null, this is a call from the Load event handler.
            if (sender != null)
            {
                // Process the document that we received.
                // Code of the location is in the tag of the control (see below).
                // If the processing fails, we likely got a malformed document.
                if (!ProcessDocument(webBrowser.Tag.ToString(), webBrowser.DocumentText) & ++_retries <= 5)
                {
                    // Retry the same URL.
                    webBrowser.Navigate(webBrowser.Url);
                    return;
                };
            }

            // Do we have a location to process?
            if (_queue.Count == 0)
            {
                // Display round trip time and reset counters.
                Debug.WriteLine(_connectionString);
                Debug.WriteLine($"Average db round trip took {_totalMs / _numberOfTrips} ms.");
                _totalMs = _numberOfTrips = 0;

                // Do we have another connection to update?
                if (_connectionStrings.Count > 0)
                {
                    GetLocations();
                }
                else
                {
                    // We do not - get out.
                    Close();
                    return;
                }
            }

            // We do: queue is not empty. Submit request for the next location.
            // We keep the location (code) in the tag of the control.
            webBrowser.Tag = _queue.Dequeue();
            var uri = "http://w1.weather.gov/data/obhistory/" + webBrowser.Tag.ToString() + ".html";
            _retries = 0;
            webBrowser.Navigate(uri);
        }

        private void GetLocations()
        {
            // Keep the connection string for future reference.
            _connectionString = _connectionStrings.Dequeue();

            using (var facade = new DbFacade(_connectionString))
            {
                // Enqueue all locations.
                foreach (var location in facade.GetLocations())
                {
                    _queue.Enqueue(location.Code);
                }
            }

            // Trigger the first navigation by pretending that the previous one finished.
            webBrowser_Navigated(null, null);
        }

        private bool ProcessDocument(string code, string document)
        {
            // We care about our users...
            Application.DoEvents();

            // This often fails if we get a malformed page.
            try
            {
                // Find a skipped "en español".
                document = document.Substring(document.IndexOf("en espa&ntilde;ol"));

                // Now skip everything preceding the main table.
                document = document.Substring(document.IndexOf("<table "));

                // Now we will drop the footer. It has its own table.
                document = document.Substring(0, document.IndexOf("National Weather Service"));
                document = document.Substring(0, document.LastIndexOf("<table "));
            }
            catch (Exception ex)
            {
                return false;
            }

            // Now we will clip the table tags.
            //document = document.Substring(document.IndexOf("<tr "));
            //document = document.Substring(0, document.LastIndexOf("</table"));

            // We have to handle breaks - they do not have a closing tag.
            // We replace them by pipe characters.
            document = document.Replace("<br>", "|").Replace("<BR>", "|");

            // Now the remaining nasties:
            document = document.Replace("&ordm;", String.Empty);
            document = document.Replace("&deg;", String.Empty);

            var xml = from r
                      in XElement.Parse(document).Elements("tr")
                      select r;

            // We handle the table row by row.
            using (var facade = new DbFacade(_connectionString))
            {
                foreach (var row in xml)
                {
                    // We have to skip headers. They have different color.
                    if (!row.ToString().Contains("bgcolor=\"#b0c4de\""))
                    {
                        // Again, we use LINQ to parse XML.
                        var columns = from c
                                      in XElement.Parse(row.ToString()).Elements("td")
                                      select c;

                        // We need values stripped of <td> tags.
                        var list = new List<string>();
                        foreach (var item in columns)
                        {
                            // 'NA' means that value is not available, i.e., empty.
                            list.Add(item.Value.ToString().Trim() == "NA" ? string.Empty : item.Value.ToString().Trim());
                        }

                        // We have to pass values in the appropriate container.
                        var observation = new Observation();

                        // We saved the location code in the tag of the browser.
                        observation.LocationCode = webBrowser.Tag.ToString();

                        // We have to rely on ordinal positions.
                        // We have to make a few assumptions about date: we have neither year nor month,
                        // only the day of the observation.
                        // For now we assume -
                        var yyyy = "2016";

                        // If the day is greater than today's day, date is in the past month.
                        var mm = Convert.ToInt32(list[0]) <= DateTime.Now.Day ? DateTime.Now.Month.ToString() : (DateTime.Now.Month - 1).ToString();

                        observation.ObservedOn = $"{yyyy}-{mm}-{list[0]} {list[1]}";
                        observation.Wind = list[2];
                        observation.Visibility = list[3];
                        observation.Weather = list[4];
                        observation.SkyConditions = list[5];
                        observation.TemperatureAir = list[6];
                        observation.Dewpoint = list[7];
                        observation.Temperature6hrMax = list[8];
                        observation.Temperature6hrMin = list[9];
                        observation.RelativeHumidity = list[10];
                        observation.WindChill = list[11];
                        observation.HeatIndex = list[12];
                        observation.PressureAltimeter = list[13];
                        observation.PressureSeaLevel = list[14];
                        observation.Precipitation1hr = list[15];
                        observation.Precipitation3hr = list[16];
                        observation.Precipitation6hr = list[17];

                        // Measure performance.
                        _stopwatch.Reset();
                        _stopwatch.Start();

                        // Errors are handled by the facade.
                        facade.PersistObservation(observation);

                        // Store performance data.
                        _stopwatch.Stop();
                        _totalMs += _stopwatch.ElapsedMilliseconds;
                        _numberOfTrips++;
                    }
                }
            }

            return true;
        }
    }
}
