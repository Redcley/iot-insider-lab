//-------------------------------------------------------------------------
// <copyright file="Common.cs" company="http://www.microsoft.com">
//   MIT License Copyright © 2016 by Microsoft Corporation.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.IoTInsiderLab.Argonne.Common
{
    /// <summary>
    /// Constatnts used by other projects in this solution.
    /// </summary>
    public static class ConnectionStrings
    {
        // Selfexplanatory...
        public static string IoTHub
        {
            get
            {
                return "HostName=IoTLabArgonneIoTHub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=MH8bpYXF98gpqQgzFJMQKnijwSJMCdPElltOhoqiQtA=";
            }
        }
        public static string Database
        {
            get
            {
                return "Server=tcp:IoTLabArgonne.database.windows.net,1433;Database=IoTLabArgonne;User ID=client;Password=IoTLab.2016;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;";
            }
        }
    }
}
