import * as angular from 'angular';

import {preloader} from './preloader.ts';
import {PreloaderService} from './preloaderService.ts';

export const preloaderModule = 'preloaderModule';

angular
    .module(preloaderModule, [])    
    //.component('preloader', preloader)
    .service('preloader', PreloaderService)
    ;
