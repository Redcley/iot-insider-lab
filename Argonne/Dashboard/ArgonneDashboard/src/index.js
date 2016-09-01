import 'reflect-metadata';
import 'zone.js';
import 'jquery';
import 'materialize-css';

import {bootstrap} from '@angular/platform-browser-dynamic';

import 'materialize-css/dist/css/materialize.css';
import './index.scss';

import {provideRouter} from '@angular/router';
import {enableProdMode} from '@angular/core';
import {routes, RootComponent} from './routes';

if (process.env.NODE_ENV === 'production') {
  enableProdMode();
}

bootstrap(RootComponent, [
  provideRouter(routes)
]);
