import { enableProdMode } from '@angular/core';
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

import { AppModule } from './app/app.module';
import { environment } from './environments/environment';

import { datadogRum } from '@datadog/browser-rum';

datadogRum.init({
    applicationId: 'f5e7a0aa-78d9-42ca-896d-39f322e6331c',
    clientToken: 'pub069c6eaabcebff66413a20cf1420b359',
    site: 'us5.datadoghq.com',
    service: 'frontend',
    env: 'production',
    sessionSampleRate: 100,
    sessionReplaySampleRate: 20,
    defaultPrivacyLevel: 'mask-user-input',
    trackResources: true,
    trackLongTasks: true,
    trackUserInteractions: true,
    version: '1.0.0',

});
datadogRum.startSessionReplayRecording();
if (environment.production) {
  enableProdMode();
}

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));