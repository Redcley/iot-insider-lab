using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Devices.Enumeration;
using Windows.Devices.I2c;
using Windows.Foundation;

namespace I2CNeoPixelDriver
{
    public class PixelDriver
    {
        private string i2cBusName;

        private const ushort controllerAddress = 0x0030;

        private const byte ControlRegister = 0xFF;

        private bool available = false; 

        bool isAvailable
        {
            get
            {
                return available;
            }
        }

        private I2cDevice i2c;

        public PixelDriver(string i2cBusName)
        {
            this.i2cBusName = i2cBusName;
        }

        /// <summary>
        /// Initialize the Mpl3115a2 device.
        /// </summary>
        /// <returns>
        /// Async operation object.
        /// </returns>
        public IAsyncOperation<bool> BeginAsync()
        {
            return this.BeginAsyncHelper().AsAsyncOperation<bool>();
        }

        public void SetColor(byte Red, byte Green, byte Blue)
        {
            byte[] data = new byte[] { PixelDriver.ControlRegister, 0x01, Red, Green, Blue };
            this.i2c.Write(data);
        }

        private async Task<bool> BeginAsyncHelper()
        {
            try
            {
                string advancedQuerySyntax = I2cDevice.GetDeviceSelector(this.i2cBusName);
                DeviceInformationCollection deviceInformationCollection = await DeviceInformation.FindAllAsync(advancedQuerySyntax);
                string deviceId = deviceInformationCollection[0].Id;

                I2cConnectionSettings neopixelConnection = new I2cConnectionSettings(controllerAddress);
                neopixelConnection.BusSpeed = I2cBusSpeed.FastMode;
                neopixelConnection.SharingMode = I2cSharingMode.Shared;

                this.i2c = await I2cDevice.FromIdAsync(deviceId, neopixelConnection);
            } catch (Exception e)
            {
                Debug.WriteLine("Unhandled exception: " + e.ToString());
                throw e;
            }

            if (null == this.i2c)
            {
                available = false;
                return false;
            }
            else
            {
                byte[] data = new byte[] { PixelDriver.ControlRegister, 0x01, 0x0, 0x0, 0x0 };
                available = true;
                this.i2c.Write(data);

                return this.isAvailable;
            }
        }
    }
}
