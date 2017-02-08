# Project Argonne
This project demonstrates campaign management and analytics for smart ads. User impressions are taken during the display of ads and those impressions are correlated to the active ad and campaign. That data can also be related to location information of the device and demographic information of the viewers.

## Overview

1. Devices diplay the ads in a campaign and capture images of viewers with a camera.
2. Captured images are sent to Azure Cognitive services for demographic and sentiment analysis
3. The results from Cognitive services are sent to the cloud via IotHub
4. An Azure Function reads the incoming messages and writes their content to SQL Azure
5. A Web API deployed as an Azure App Service connects to SQL azure and provides CRUD access to the data model. This API also serves as the integration point to tie in external services such as third party add services.
6. A Web App deployed as an Azure App Service connects to the Web APi and provides and administrative dashboard
7. PowerBI connects to SQL Azure to allow users to view, slice, analyze impressions by campaign, ad, location, and demographic 

## Components
- [Client App](https://github.com/IotInsiderLab/iotil-argonne-client)
- [Client Simulator](https://github.com/IotInsiderLab/iotil-argonne-simulation)
- [Azure Function](https://github.com/IotInsiderLab/iotil-argonne-simulation/tree/master/AzureFunctionHarness)
- [Web Api](https://github.com/IotInsiderLab/iotil-argonne-api)
- [Dashboard](https://github.com/IotInsiderLab/iotil-argonne-dashboard)
- [Database](https://github.com/IotInsiderLab/iotil-argonne-database)
- [PowerBI](https://github.com/IotInsiderLab/iotil-argonne-database/tree/master/PowerBI)
