using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Ioc;
using GalaSoft.MvvmLight.Views;
using Microsoft.Practices.ServiceLocation;
using ArgonneAdDisplay.Model;
using Argonne.Common.ArgonneService;
using System;
using System.Threading.Tasks;

namespace ArgonneAdDisplay.ViewModel
{
    public class ViewModelLocator
    {
        public const string SecondPageKey = "SecondPage";
        //private const string ARGONNE_SVC_URI = "http://localhost:44685/";

        static ViewModelLocator()
        {
            ServiceLocator.SetLocatorProvider(() => SimpleIoc.Default);

            var nav = new NavigationService();
            nav.Configure(SecondPageKey, typeof(SecondPage));
            SimpleIoc.Default.Register<INavigationService>(() => nav);

            SimpleIoc.Default.Register<IDialogService, DialogService>();

            if (ViewModelBase.IsInDesignModeStatic)
            {
                SimpleIoc.Default.Register<IDataService, Design.DesignDataService>();
            }
            else
            {
                SimpleIoc.Default.Register<IDataService, DataService>();
            }

            SimpleIoc.Default.Register<IArgonneServiceClient>(() => new ArgonneServiceClient(), true);

            SimpleIoc.Default.Register<MainViewModel>(true);

            SimpleIoc.Default.Register<CampaignViewModel>();

            //SimpleIoc.Default.GetInstance<CampaignViewModel>().Initialize();

            // initialize
            //Task.Run(async () =>
            //{
            //    await SimpleIoc.Default.GetInstance<CampaignViewModel>().Initialize();
            //});
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Performance",
            "CA1822:MarkMembersAsStatic",
            Justification = "This non-static member is needed for data binding purposes.")]
        public MainViewModel Main => ServiceLocator.Current.GetInstance<MainViewModel>();        
    }
}
