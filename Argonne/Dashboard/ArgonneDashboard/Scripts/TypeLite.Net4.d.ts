﻿
 
 

 

/// <reference path="Enums.ts" />

declare module ArgonneService.Models {
	interface AdAggregateData {
		adId: string;
		ageBracket1: number;
		ageBracket2: number;
		ageBracket3: number;
		ageBracket4: number;
		ageBracket5: number;
		ageBracket6: number;
		females: number;
		males: number;
		totalFaces: number;
		uniqueFaces: number;
	}
	interface AdDto {
		adId: string;
		adName: string;
		url: string;
	}
	interface AdInCampaignDto {
		adId: string;
		campaignId: string;
		duration: number;
		firstImpression: number;
		impressionInterval: number;
		sequence: number;
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
		faces: ArgonneService.Models.FaceForImpressionDto[];
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


