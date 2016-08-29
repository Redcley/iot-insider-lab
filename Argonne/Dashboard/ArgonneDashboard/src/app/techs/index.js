import angular from 'angular';

import {tech} from './tech.js';
import {techs} from './techs.js';

export const techsModule = 'techs';

angular
  .module(techsModule, [])
  .component('fountainTech', tech)
  .component('fountainTechs', techs);
