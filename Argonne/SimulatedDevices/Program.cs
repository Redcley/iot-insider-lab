//-------------------------------------------------------------------------
// <copyright file="Program.cs" company="http://www.microsoft.com">
//   MIT License Copyright © 2016 by Microsoft Corporation.
//   Written by Jan Machat (Redcley LLC).
// </copyright>
//-------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

using Microsoft.IoTInsiderLab.Argonne.SimulatedDevices;

namespace Microsoft.IoTInsiderLab.Argonne.Program
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            try
            {
                Application.Run(new Microsoft.IoTInsiderLab.Argonne.SimulatedDevices.SimulatedDevices());
            }
            catch (Exception ex)
            {
                // Put a breakpoint here
            }
        }
    }
}
