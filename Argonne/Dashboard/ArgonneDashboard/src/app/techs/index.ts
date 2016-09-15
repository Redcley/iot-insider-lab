import * as angular from 'angular';

import {tech} from './tech.ts';
import {techs} from './techs.ts';

export const techsModule = 'techs';

angular
  .module(techsModule, [])
  .component('fountainTech', tech)
  .component('fountainTechs', techs);
