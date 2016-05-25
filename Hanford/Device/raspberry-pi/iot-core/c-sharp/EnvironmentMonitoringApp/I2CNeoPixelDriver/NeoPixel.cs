using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Devices.Enumeration;
using Windows.Devices.I2c;
using Windows.Foundation;

namespace Redcley.Sensors.I2C.NeoPixelDriver
{
    public enum PixelColor
    {
        Red,
        Orange,
        Yellow,
        Green,
        Indigo,
        Blue,
        Purple,
        Black
    };

    public class PixelDriver
    {

        public string Color
        {
            get
            {
                switch (pixelColor)
                {
                    case PixelColor.Blue:
                        return "blue";
                    case PixelColor.Green:
                        return "green";
                    case PixelColor.Orange:
                        return "orange";
                    case PixelColor.Purple:
                        return "purple";
                    case PixelColor.Red:
                        return "red";
                    case PixelColor.Yellow:
                        return "yellow";
                    case PixelColor.Black:
                        return "black";
                }

                return "black";
            }
        }

        public bool Enabled
        {
            get
            {
                if (PixelColor.Black == pixelColor)
                    return false;
                else
                    return true;
            }
        }

        private PixelColor pixelColor;


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
            pixelColor = PixelColor.Black;
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

        public void SetColor(string color)
        {
            switch (color)
            {
                case "blue":
                    SetColor(PixelColor.Blue);
                    break;
                case "green":
                    SetColor(PixelColor.Green);
                    break;
                case "orange":
                    SetColor(PixelColor.Orange);
                    break;
                case "purple":
                    SetColor(PixelColor.Purple);
                    break;
                case "red":
                    SetColor(PixelColor.Red);
                    break;
                case "yellow":
                    SetColor(PixelColor.Yellow);
                    break;
                case "black":
                    SetColor(PixelColor.Black);
                    break;
            }

        }

        public void SetColor(PixelColor color)
        {
            pixelColor = color;

            switch (pixelColor)
            {
                case PixelColor.Blue:
                    SetColor(0,0,255);
                    break;
                case PixelColor.Green:
                    SetColor(0,255,0);
                    break;
                case PixelColor.Orange:
                    SetColor(255, 153, 51);
                    break;
                case PixelColor.Purple:
                    SetColor(139, 0, 204);
                    break;
                case PixelColor.Red:
                    SetColor(255, 0, 0);
                    break;
                case PixelColor.Yellow:
                    SetColor(255, 255, 0);
                    break;
                case PixelColor.Black:
                    SetColor(0, 0, 0);
                    break;
            }
        }

        public void SetColor(byte Red, byte Green, byte Blue)
        {
            byte[] data = new byte[] { PixelDriver.ControlRegister, 0x01, Red, Green, Blue };
            this.i2c.Write(data);
        }

        private async Task<bool> BeginAsyncHelper()
        {
            if (this.i2c == null)
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
                }
                catch (Exception e)
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
            return this.isAvailable;
        }
    }
}
