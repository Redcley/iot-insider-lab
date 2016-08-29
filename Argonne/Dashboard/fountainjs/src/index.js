import angular from 'angular';

import {techsModule} from './app/techs/index.js';
import 'angular-ui-router';
import routesConfig from './routes.js';

import {main} from './app/main.js';
import {header} from './app/header.js';
import {title} from './app/title.js';
import {footer} from './app/footer.js';

angular
  .module('app', [techsModule, 'ui.router'])
  .config(routesConfig)
  .component('app', main)
  .component('fountainHeader', header)
  .component('fountainTitle', title)
  .component('fountainFooter', footer);
