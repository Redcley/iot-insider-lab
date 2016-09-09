import {Component} from '@angular/core';
import {ROUTER_DIRECTIVES} from '@angular/router';
import {MainComponent} from './app/main';

@Component({
  selector: 'fountain-root',
  template: '<router-outlet></router-outlet>',
  directives: [ROUTER_DIRECTIVES]
})
export class RootComponent {
}

export const routes = [
  {
    path: '',
    component: MainComponent
  }
];
