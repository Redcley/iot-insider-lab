using Windows.Foundation;

namespace Redcley.Sensors.I2C.Interfaces
{
    public interface IBarometer
    {
        float Altitude
        {
            get;
        }

        float Pressure
        {
            get;
        }

        IAsyncOperation<bool> BeginAsync();
    }

    public interface IHumidity
    {
        float Humidity
        {
            get;
        }

        float DewPoint
        {
            get;
        }

        IAsyncOperation<bool> BeginAsync();

    }

    public interface ITemperature
    {
        float Temperature
        {
            get;
        }

        IAsyncOperation<bool> BeginAsync();
    }


}