using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Foundation;

namespace DeviceTypeInterfaceLibrary
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