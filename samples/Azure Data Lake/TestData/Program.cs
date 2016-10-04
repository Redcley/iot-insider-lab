//------------------------------------------------------------------------------
// <copyright file="SQLServer.cs" company="http://www.microsoft.com">
//   MIT License Copyright © 2016 by Microsoft Corporation.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//------------------------------------------------------------------------------

using System;

using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;

namespace Microsoft.IoTInsiderLab.Azure.ADLTestData
{
    /// <summary>
    /// Converts IoTLabWeather data into flat files for Azure Data Lake tests.
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {
            // Our connection string:
            var connectionString =
                "Server=tcp:iotlab.database.windows.net,1433;Database=IoTLabWeather;User ID=client;Password=IoTLab.2016;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;";

            // Our SQL: we read all date up to and including yesterday.
            var sql =
                "SELECT LocationCode"                                          +
                      ",ObservedOn"                                            +
                      ",Wind"                                                  +
                      ",Visibility"                                            +
                      ",Weather"                                               +
                      ",TemperatureAir"                                        +
                      ",Dewpoint"                                              +
                      ",RelativeHumidity"                                      +
                      ",PressureAltimeter"                                     +
                      ",SkyConditionsCleansed "                                +
                "FROM   Observations "                                         +
                "WHERE  ObservedOn BETWEEN"                                    +
               $"            '{DateTime.Now.AddDays(-7).ToShortDateString()}'" +
                "             AND"                                             +
               $"            '{DateTime.Now.ToShortDateString()}'"             +
                "ORDER BY"                                                     +
                "       YEAR(ObservedOn), MONTH(ObservedOn), DAY(ObservedOn)," +
                "       LocationCode, ObservedOn";

            // Main loop: read and write the weather data.
            // Per industry practice, we define, but in this case not open, the writer first.
            StreamWriter writer = null;

            // This will be our trigger for change of the output file.
            string current = null;

            using (var cmd = new SqlCommand())
            {
                cmd.Connection = new SqlConnection(connectionString);

                try
                {
                    cmd.Connection.Open();
                }
                catch (Exception ex)
                {
                    // This is just a placeholder for a break:
                    throw;
                }

                // Read weather data.
                cmd.CommandText = sql;
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        // These values must not be null. If they are nulls, we replace them by spaces.
                        var locationCode = reader.GetString  (reader.GetOrdinal("LocationCode"));
                        var observedOn   = reader.GetDateTime(reader.GetOrdinal("ObservedOn"));
                        var wind         = reader.GetString  (reader.GetOrdinal("Wind"));
                        var weather      = reader.GetString  (reader.GetOrdinal("Weather"));

                        // These may be, although they should not be:
                        var visibility = string.Empty;
                        try
                        {
                            visibility = reader.GetDecimal(reader.GetOrdinal("Visibility")).ToString();
                        }
                        catch { /* no problem */ }

                        var skyConditions = string.Empty;
                        try
                        {
                            skyConditions = reader.GetString(reader.GetOrdinal("SkyConditionsCleansed"));
                        }
                        catch { /* no problem */ }

                        var dewpoint = string.Empty;
                        try
                        {
                            dewpoint = reader.GetDecimal(reader.GetOrdinal("Dewpoint")).ToString();
                        }
                        catch { /* no problem */ }

                        var humidity = string.Empty;
                        try
                        {
                            humidity = reader.GetDecimal(reader.GetOrdinal("RelativeHumidity")).ToString();
                        }
                        catch { /* no problem */ }

                        var temperature = string.Empty;
                        try
                        {
                            temperature = reader.GetDecimal(reader.GetOrdinal("TemperatureAir")).ToString();
                        }
                        catch { /* no problem */ }

                        var pressure = string.Empty;
                        try
                        {
                            pressure = reader.GetDecimal(reader.GetOrdinal("PressureAltimeter")).ToString();
                        }
                        catch { /* no problem */ }

                        // Check whether the day changed.
                        if (observedOn.ToShortDateString() != current)
                        {
                            // It did.
                            // Check whether we were writing a file for the previous day.
                            if (current != null)
                            {
                                // We did. Close that file.
                                writer.Flush();
                                writer.Close();
                            }

                            // The new date is the current one.
                            current = observedOn.ToShortDateString();
                            var y   = (observedOn.Year.ToString().Length < 2)  ? "0" + observedOn.Year.ToString()  : observedOn.Year.ToString();
                            var m   = (observedOn.Month.ToString().Length < 2) ? "0" + observedOn.Month.ToString() : observedOn.Month.ToString();
                            var d   = (observedOn.Day.ToString().Length < 2)   ? "0" + observedOn.Day.ToString()   : observedOn.Day.ToString();
                            writer  = new StreamWriter($"..\\..\\..\\files\\ADLTestWeather_{y}_{m}_{d}.csv");
                        }

                        // Now we are ready to write this row.
                        writer.WriteLine($"{Quote(locationCode)},{Quote(observedOn.ToString())},{Quote(wind)},{Quote(visibility)},{Quote(weather)}," +
                                         $"{Quote(skyConditions)},{Quote(temperature)},{Quote(dewpoint)},{Quote(humidity)},{Quote(pressure)}");
                    }
                }

                // We have to flush the last output file.
                writer?.Flush();
                writer?.Close();
            }
        }

        private static string Quote(string s) => $"\"{s}\""; 
    }
}
