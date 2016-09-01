require('reflect-metadata');
const context = require.context('./app', true, /\.(js|ts|tsx)$/);
context.keys().forEach(context);
const testing = require('@angular/core/testing');
const testingBrowser = require('@angular/platform-browser-dynamic/testing');

testing.setBaseTestProviders(testingBrowser.TEST_BROWSER_DYNAMIC_PLATFORM_PROVIDERS, testingBrowser.TEST_BROWSER_DYNAMIC_APPLICATION_PROVIDERS);
