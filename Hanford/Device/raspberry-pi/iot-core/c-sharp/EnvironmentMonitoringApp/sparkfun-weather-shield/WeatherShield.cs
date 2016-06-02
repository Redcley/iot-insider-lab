using System;
using System.Threading.Tasks;
using Windows.Foundation;
using Redcley.Sensors.I2C.NeoPixelDriver;
using Redcley.Sensors.I2C.BME280;
using Redcley.Sensors.I2C.Htu21d;
using Redcley.Sensors.I2C.Mpl3115a2;
using Redcley.Sensors.I2C.Interfaces;
using Windows.Data.Json;

namespace Microsoft.Maker.Sparkfun.WeatherShield
{
    public sealed class WeatherShield
    {
        private PixelDriver neoPixel;
        private BME280 bme280;
        private Htu21d htu21d;  // Humidity and temperature sensor
        private Mpl3115a2 mpl3115a2;  // Altitue, pressure and temperature sensor

        private IHumidity humiditySensor;
        private ITemperature temperatureSensor;
        private IBarometer barometricSensor;

        /// <summary>
        /// Used to signal that the device is properly initialized and ready to use
        /// </summary>
        private bool available = false;

        /// <summary>
        /// A switch to enable/disable the device;
        /// </summary>
        private bool enable = false;

        // Sensors


        /// <summary>
        /// Constructs WeatherShield with I2C bus and status LEDs identified
        /// </summary>
        /// <param name="i2cBusName"></param>
        /// <param name="ledBluePin"></param>
        /// <param name="ledGreenPin"></param>
        public WeatherShield (string i2cBusName, string jsonConfig)
        {
            JsonObject config = JsonValue.Parse(jsonConfig).GetObject();

            if (config.ContainsKey("board_config"))
            {
                JsonObject hardware = config.GetNamedObject("board_config");

                if ( hardware.ContainsKey("bme280") && (hardware.GetNamedBoolean("bme280") == true) )
                {
                    bme280 = new BME280(i2cBusName);
                }
                else
                {
                    if (hardware.ContainsKey("htu21d") && (hardware.GetNamedBoolean("htu21d") == true) )
                    {
                        htu21d = new Htu21d(i2cBusName);
                    }

                    if (hardware.ContainsKey("mpl3115a2") && (hardware.GetNamedBoolean("mpl3115a2") == true))
                    {
                        mpl3115a2 = new Mpl3115a2(i2cBusName);
                    }
                }

                if (hardware.ContainsKey("neopixel") && (hardware.GetNamedBoolean("neopixel") == true))
                    neoPixel = new PixelDriver(i2cBusName);


            }
            else
            {
                throw new ArgumentException("Supplied configuration string did not contain a Board Configuration");
            }



            if (bme280 != null)
            {
                humiditySensor = bme280;
                temperatureSensor = bme280;
                barometricSensor = bme280;
            }
            else
            {
                if (htu21d != null)
                {
                    humiditySensor = htu21d;
                    temperatureSensor = htu21d;
                }

                if (mpl3115a2 != null)
                {
                    barometricSensor = mpl3115a2;
                    if (temperatureSensor == null)
                    {
                        temperatureSensor = mpl3115a2;
                    }
                }
            }
        }

        /// <summary>
        /// Initialize the Sparkfun Weather Shield
        /// </summary>
        /// <returns>
        /// Async operation object
        /// </returns>
        public IAsyncOperation<bool> BeginAsync()
        {
            return this.BeginAsyncHelper().AsAsyncOperation<bool>();
        }

        /// <summary>
        /// Read altitude data
        /// </summary>
        /// <returns>
        /// Calculates the altitude in meters (m) using the US Standard Atmosphere 1976 (NASA) formula
        /// </returns>
        public float Altitude
        {
            get
            {
                if (barometricSensor != null) { return barometricSensor.Altitude; }
                else return 0f;
            }
        }

        /// <summary>
        /// Read dew point data
        /// </summary>
        /// <returns>
        /// Returns dew point temperature calculated as
        /// -(235.66 + 1762.39 / (log(RelativeHumidity * PartialPressure / 100) - 8.1332))
        /// </returns>
        public float DewPoint
        {
            get
            {
                if (humiditySensor != null) { return humiditySensor.DewPoint; }
                else { return 0f; }
            }
        }

        /// <summary>
        /// The current state of the shield
        /// </summary>
        public bool Enable
        {
            get { return enable; }
            set { enable = (available && value); }
        }

        /// <summary>
        /// Calculate relative humidity
        /// </summary>
        /// <returns>
        /// The relative humidity
        /// </returns>
        public float Humidity
        {
            get
            {
                if (humiditySensor != null) return humiditySensor.Humidity;
                else return 0f;
            }
        }

        /// <summary>
        /// Read pressure data
        /// </summary>
        /// <returns>
        /// The pressure in Pascals (Pa)
        /// </returns>
        public float Pressure
        {
            get
            {
                if (barometricSensor != null) return barometricSensor.Pressure;
                else return 0f;
            }
        }

        /// <summary>
        /// Calculate current temperature
        /// </summary>
        /// <returns>
        /// The temperature in Celcius (C)
        /// </returns>
        public float Temperature
        {
            get
            {
                if (temperatureSensor != null) return temperatureSensor.Temperature;
                else return 0f;
            }
        }

        public void SetColor(byte Red, byte Green, byte Blue)
        {
            if (neoPixel != null)
                neoPixel.SetColor(Red, Green, Blue);
        }

        public void SetColor(string color)
        {
            if (neoPixel != null)
                neoPixel.SetColor(color);
        }

        public string LedColor
        {
            get
            {
                if (neoPixel != null) return neoPixel.Color;
                else return "black";
            }
        }

        public bool LedEnabled
        {
            get
            {
                if (neoPixel != null) return neoPixel.Enabled;
                else return false;
            }
        }

        /// <summary>
        /// Initialize the Sparkfun Weather Shield
        /// </summary>
        /// <remarks>
        /// Setup and instantiate the I2C device objects for the HTU21D and the MPL3115A2
        /// and initialize the blue and green status LEDs.
        /// </remarks>
        private async Task<bool> BeginAsyncHelper()
        {
            if (null != humiditySensor) await humiditySensor.BeginAsync();
            if (null != barometricSensor) await barometricSensor.BeginAsync();
            if (null != temperatureSensor) await temperatureSensor.BeginAsync();
            if (null != neoPixel) await neoPixel.BeginAsync();

            available = true;
            enable = true;
            return true;
        }
    }
}
