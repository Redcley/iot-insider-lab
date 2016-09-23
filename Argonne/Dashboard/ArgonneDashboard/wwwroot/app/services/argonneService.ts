export class ArgonneService {
    // replace with valid service URL
    private BASE_URI: string = <Service API>;

    constructor(private $http: ng.IHttpService) {
    }

    public getImpressionsForCampaign(campaignId: string, showAfter: string = null): ng.IPromise<ArgonneService.Models.ImpressionDto[]> {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/Impressions/After';

        return this.$http.get(url,
            {
                params: {
                    after: showAfter,
                    PageSize: 1000
                }
            })
            .then(response => {
                return response.data as ArgonneService.Models.ImpressionDto[];
            });        
    }

    public getAllCampaigns(): ng.IPromise<ArgonneService.Models.CampaignDto[]> {
        var url = this.BASE_URI + '/api/admin/Campaign/';

        return this.$http.get(url,
            {
            })
            .then(response => {
                return response.data as ArgonneService.Models.CampaignDto[];
            });
    }

    public getCampaignAds(campaignId: string): ng.IPromise<ArgonneService.Models.AdInCampaignDto[]> {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/Ads';

        return this.$http.get(url,
            {
            })
            .then(response => {
                return response.data as ArgonneService.Models.AdInCampaignDto[];
            });
    }

    public getCampaignDetails(campaignId: string): ng.IPromise<ArgonneService.Models.CampaignDto> {
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId;

        return this.$http.get(url)
            .then(response => {
                return response.data as ArgonneService.Models.CampaignDto;
            });
    }

    public getAdDetails(adId: string): ng.IPromise<ArgonneService.Models.AdDto> {
        var url = this.BASE_URI + '/api/admin/Ad/' + adId;

        return this.$http.get(url)
            .then(response => {
                return response.data as ArgonneService.Models.AdDto;
            });
    }

    public getCampaignAggregate(campaignId: string, start: string = null, end: string = null): ng.IPromise<ArgonneService.Models.AdAggregateData[]> {
        //var url = '/api/campaign/aggregate/' + campaignId;
        var url = this.BASE_URI + '/api/admin/Campaign/' + campaignId + '/impressions/aggregate';

        return this.$http.get(url,
            {
                params: {
                    start: start,
                    end: end
                }
            })
            .then(response => {
                return response.data as ArgonneService.Models.AdAggregateData[];
            });
    }

    public getAllAds(): ng.IPromise<ArgonneService.Models.AdDto[]> {
        var url = this.BASE_URI + '/api/admin/Ad';

        return this.$http.get(url,
            {            
            })
            .then(response => {
                return response.data as ArgonneService.Models.AdDto[];
            });
    }
}