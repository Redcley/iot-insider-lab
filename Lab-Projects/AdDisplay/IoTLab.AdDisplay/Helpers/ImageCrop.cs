using System;
using System.IO;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Graphics.Imaging;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;

namespace IoTLab.AdDisplay.Helpers
{
    internal static class ImageCrop
    {
        public static async Task<ImageSource> GetCroppedBitmapAsync(StorageFile originalImgFile, Point startPoint, Size corpSize)
        {
            // Convert start point and size to integer 
            uint startPointX = (uint)Math.Floor(startPoint.X);
            uint startPointY = (uint)Math.Floor(startPoint.Y);
            uint height = (uint)Math.Floor(corpSize.Height);
            uint width = (uint)Math.Floor(corpSize.Width);

            using (IRandomAccessStream stream = await originalImgFile.OpenReadAsync())
            {
                // Create a decoder from the stream. With the decoder, we can get the properties of the image. 
                BitmapDecoder decoder = await BitmapDecoder.CreateAsync(stream);

                // The scaledSize of original image. 
                uint scaledWidth = (uint)Math.Floor(Convert.ToDouble(decoder.PixelWidth));
                uint scaledHeight = (uint)Math.Floor(Convert.ToDouble(decoder.PixelHeight));

                // Refine the start point and the size.  
                if (startPointX + width > scaledWidth)
                {
                    startPointX = scaledWidth - width;
                }


                if (startPointY + height > scaledHeight)
                {
                    startPointY = scaledHeight - height;
                }

                // Create cropping BitmapTransform and define the bounds. 
                BitmapTransform transform = new BitmapTransform();
                BitmapBounds bounds = new BitmapBounds
                {
                    X = startPointX,
                    Y = startPointY,
                    Height = height,
                    Width = width
                };
                transform.Bounds = bounds;
                transform.ScaledWidth = scaledWidth;
                transform.ScaledHeight = scaledHeight;

                // Get the cropped pixels within the bounds of transform. 
                PixelDataProvider pix = await decoder.GetPixelDataAsync(
                    BitmapPixelFormat.Bgra8,
                    BitmapAlphaMode.Straight,
                    transform,
                    ExifOrientationMode.IgnoreExifOrientation,
                    ColorManagementMode.ColorManageToSRgb);
                byte[] pixels = pix.DetachPixelData();

                // Stream the bytes into a WriteableBitmap 
                WriteableBitmap cropBmp = new WriteableBitmap((int)width, (int)height);
                Stream pixStream = cropBmp.PixelBuffer.AsStream();
                pixStream.Write(pixels, 0, (int)(width * height * 4));

                return cropBmp;
            }

        }
    }
}
