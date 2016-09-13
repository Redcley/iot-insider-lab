export class ArgonneService {
    static $inject = ["$http"];

    private BASE_URI: string = 'http://localhost:44685';
    //private BASE_URI: string = 'http://api-argonne.azurewebsites.net/';

    private URI_GET_IMPRESSION: string = '/api/admin/Campaign/{campaignid}/Impressions';


    constructor(private $http: ng.IHttpService) {
    }

    public getImpressionsForCampaign(campaignId: string, showAfter: string = null): ng.IPromise<Argonne.Services.ArgonneService.Models.ImpressionDto[]> {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/Impressions/After';

        return this.$http.get(url,
            {
                params: {
                    after: showAfter,
                    PageSize: 1000
                }
            })
            .then(response => {
                return response.data as Argonne.Services.ArgonneService.Models.ImpressionDto[];
            });

        //return this.$http.get('/data/impressions.json')
        //    .then((response) => {
        //        debugger;
        //        this.impressions = response.data as Argonne.Services.ArgonneService.Models.ImpressionDto[];
        //        return this.impressions;
        //    });

        //var list: Models.List;
        //$http
        //    .get('src/app/techs/techs.json')
        //    .then(response => {
        //        this.techs = response.data as Tech[];
        //    });
    }    

    public getAllCampaigns(): ng.IPromise<Argonne.Services.ArgonneService.Models.CampaignDto[]> {
        var url = this.BASE_URI + '/api/admin/Campaign/';

        return this.$http.get(url,
            {                
            })
            .then(response => {                
                return response.data as Argonne.Services.ArgonneService.Models.CampaignDto[];                
            });        
    }    

    public getCampaignAds(campaignId: string): ng.IPromise<Argonne.Services.ArgonneService.Models.AdDto[]> {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/Ads';

        return this.$http.get(url,
            {
            })
            .then(response => {
                return response.data as Argonne.Services.ArgonneService.Models.AdDto[];
            });
    }    

    public getCampaignDetails(campaignId: string): ng.IPromise<Argonne.Services.ArgonneService.Models.CampaignDto> {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId;

        return this.$http.get(url)
            .then(response => {
                return response.data as Argonne.Services.ArgonneService.Models.CampaignDto;
            });
    }    

    public getAdDetails(adId: string): ng.IPromise<Argonne.Services.ArgonneService.Models.AdDto> {
        var url = this.BASE_URI + '/api/admin/Ad/' + adId;

        return this.$http.get(url)
            .then(response => {
                return response.data as Argonne.Services.ArgonneService.Models.AdDto;
            });
    }
}