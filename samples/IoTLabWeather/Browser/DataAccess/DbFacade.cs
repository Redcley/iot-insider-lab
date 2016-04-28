//-------------------------------------------------------------------------
// <copyright file="DbFacade.cs" company="http://www.microsoft.com">
//   Copyright © 2016 by Microsoft Corporation. All rights reserved.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

namespace IoTLabWeather.DataAccess
{
    /// <summary>
    // Database facade of the IoTLabWeather demo application.
    /// </summary>
    public class DbFacade : IDisposable
    {
        #region Declarations 

        SqlCommand _cmd = new SqlCommand();

        #endregion

        #region Constructor

        public DbFacade(string connectionString) 
        {
            // Errors are handled by the caller.
            _cmd.Connection = new SqlConnection(connectionString);
            _cmd.Connection.Open();
        }

        #endregion

        #region Public methods

        /// <summary>
        /// Returns a list of locations ordered by state and location name.
        /// </summary>
        /// <returns>List of locations.</returns>
        public List<Location> GetLocations() 
        {
            var list = new List<Location>();

            try
            {
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandText = "GetLocations";
                _cmd.Parameters.Clear();

                var reader = _cmd.ExecuteReader();
                while (reader.Read())
                {
                    var location = new Location();
                    location.Code = reader["LocationCode"].ToString();
                    location.Name = reader["Location"].ToString();
                    location.State = reader["State"].ToString();

                    list.Add(location);
                }
            }
            catch (Exception ex)
            {
                // TODO
                //HandleException(ex);
            }

            return list;
        }

        /// <summary>d
        /// Persists one observation for a given location.
        /// </summary>
        /// <param name="observation"></param>
        /// <returns>True if success, False if failed.</returns>
        public bool PersistObservation(Observation observation) 
        {

            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "PersistObservation";
            _cmd.Parameters.Clear();
            _cmd.Parameters.Add(new SqlParameter("@locationCode",      observation.LocationCode));
            _cmd.Parameters.Add(new SqlParameter("@observedOn",        observation.ObservedOn));
            _cmd.Parameters.Add(new SqlParameter("@wind",              observation.Wind));
            _cmd.Parameters.Add(new SqlParameter("@visibility",        observation.Visibility));
            _cmd.Parameters.Add(new SqlParameter("@weather",           observation.Weather));
            _cmd.Parameters.Add(new SqlParameter("@skyConditions",     observation.SkyConditions));
            _cmd.Parameters.Add(new SqlParameter("@temperatureAir",    observation.TemperatureAir));
            _cmd.Parameters.Add(new SqlParameter("@dewpoint",          observation.Dewpoint));
            _cmd.Parameters.Add(new SqlParameter("@relativeHumidity",  observation.RelativeHumidity));
            _cmd.Parameters.Add(new SqlParameter("@windChill",         observation.WindChill));
            _cmd.Parameters.Add(new SqlParameter("@heatIndex",         observation.HeatIndex));
            _cmd.Parameters.Add(new SqlParameter("@pressureAltimeter", observation.PressureAltimeter));
            _cmd.Parameters.Add(new SqlParameter("@pressureSeaLevel",  observation.PressureSeaLevel));
            _cmd.Parameters.Add(new SqlParameter("@precipitation1hr",  observation.Precipitation1hr));
            _cmd.Parameters.Add(new SqlParameter("@precipitation3hr",  observation.Precipitation3hr));
            _cmd.Parameters.Add(new SqlParameter("@precipitation6hr",  observation.Precipitation6hr));

            // We have to catch execution errors; therefore -
            try
            {
                //return ((int)_cmd.ExecuteScalar() == 0);
                var errorCode = (int)_cmd.ExecuteScalar();
                if (errorCode != 0)
                {
                    Debug.WriteLine( $"{observation.LocationCode} observed on {observation.ObservedOn} error {errorCode}" );
                }
                return errorCode == 0;
            }
            catch (Exception ex)
            {
                Debug.WriteLine( $"{observation.LocationCode} observed on {observation.ObservedOn}: {ex.Message}" );
                return false;
            }
        }

        #endregion

        #region Implementation of IDisposable 

        bool _disposed = false;

        // A derived class should not be able to override this method. 
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            // Check to see if Dispose has already been called. 
            if (!this._disposed)
            {
                // If disposing equals true, we dispose all managed resources. 
                if (disposing)
                {
                    // This is needed to handle errors in the constructor.
                    try
                    {
                        _cmd.Connection.Close();
                    }
                    finally
                    {
                        _cmd.Dispose();
                    }
                }

                // Note that disposing has been done.
                _disposed = true;
            }
        }

        #endregion
    }
}
