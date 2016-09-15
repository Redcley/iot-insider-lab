
 
 

 

/// <reference path="Enums.ts" />

declare module Argonne.Services.ArgonneService.Models {
	interface AdDto {
		adId: string;
		adName: string;
		url: string;
	}
	interface CampaignDto {
		campaignId: string;
		campaignName: string;
	}
	interface DeviceDto {
		activeFrom: Date;
		activeTo: Date;
		address: string;
		address2: string;
		address3: string;
		campaignId: string;
		city: string;
		deviceId: string;
		deviceName: string;
		postalCode: string;
		primaryKey: string;
		stateProvince: string;
		timezone: string;
	}
	interface FaceForImpressionDto {
		age: number;
		faceId: string;
		gender: string;
		impressionId: number;
		scoreAnger: number;
		scoreContempt: number;
		scoreDisgust: number;
		scoreFear: number;
		scoreHappiness: number;
		scoreNeutral: number;
		scoreSadness: number;
		scoreSurprise: number;
		sequence: number;
	}
	interface ImpressionDto {
		campaignId: string;
		deviceId: string;
		deviceTimestamp: Date;
		displayedAdId: string;
		faces: Argonne.Services.ArgonneService.Models.FaceForImpressionDto[];
		impressionId: number;
		insertTimestamp: Date;
		messageId: string;
	}
}
declare module Models {
	interface List {
		count: number;
		countEnded: number;
		id: number;
		name: string;
		tasks: Models.Task[];
	}
	interface Task {
		ended: boolean;
		id: number;
		listId: number;
		name: string;
	}
}


