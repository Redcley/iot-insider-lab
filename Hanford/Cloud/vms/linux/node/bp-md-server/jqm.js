'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

const helpers = require("./helpers.js");

function renderMainPage(res, deviceList) {
  var devices = {
    connected: [],
    disconnected: [],
    disabled: []
  };

  deviceList.forEach(function (device) {
    if (device.status === "enabled") {
      if (device.connectionState === "Connected") {
        devices.connected.push(device);
      } else {
        devices.disconnected.push(device);
      }
    } else {
      devices.disabled.push(device);
    }
  });

  var page = "" +
    "<!DOCTYPE html>" +
    "<html>" +
    "<head>" +
    "<meta name='viewport' content='width=device-width,initial-scale=1'>" +
    "<script src='http://ajax.aspnetcdn.com/ajax/jQuery/jquery-2.1.4.min.js'></script>" +
    "<script src='http://ajax.aspnetcdn.com/ajax/jquery.mobile/1.4.5/jquery.mobile-1.4.5.min.js'></script>" +
    "<script src='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.1.3/Chart.min.js'></script>" +
    "<link rel='stylesheet prefetch' href='http://ajax.aspnetcdn.com/ajax/jquery.mobile/1.4.5/jquery.mobile-1.4.5.min.css'>" +
    "</head>" +
    "<body>" +
    "<section id='home-page' data-role='page'>" +
    "<div data-role='header' data-position='fixed' data-theme='a'>" +
    "<h1>Management Portal</h1>" +
    "</div>" +
    "<div class='ui-content'>" +
    "<ul data-role='listview' data-inset='true'>";

  if (devices.connected.length > 0) {
    page += `<li data-role='list-divider'><h3>Connected Devices</h3><span class='ui-li-count'>${devices.connected.length}</span></li>`;

    devices.connected.forEach(function (device) {
      var messageCount = helpers.getMessageCount(device.deviceId);
      var averageTemp = helpers.getLastAverage(device.deviceId);

      page += `<li><a data-ajax='false' href='/device?id=${device.deviceId}'>` +
        `<h4>${device.deviceId}</h4>` +
        `<p style='font-weight:bold'>Last Message ${device.lastActivityTime}</p>` +
        `<p class='ui-li-aside'>${messageCount} messages processed</p>`;
      if (averageTemp) {
        page += `<p>Rolling average temperature ${averageTemp}&deg;C</p>`;
      }
      page += "</a></li>";
    });
  }

  if (devices.disconnected.length > 0) {
    page += `<li data-role='list-divider'><h3>Disconnected Devices</h3><span class='ui-li-count'>${devices.disconnected.length}</span></li>`;

    devices.disconnected.forEach(function (device) {
      var messageCount = helpers.getMessageCount(device.deviceId);

      page += "<li>" +
        `<h4>${device.deviceId}</h4>` +
        `<p style='font-weight:bold'>Last Message ${device.lastActivityTime}</p>` +
        `<p class='ui-li-aside'>${messageCount} messages processed</p>` +
        "</li>";
    });
  }

  if (devices.disabled.length > 0) {
    page += `<li data-role='list-divider'><h3>Disabled Devices</h3><span class='ui-li-count'>${devices.disabled.length}</span></li>`;

    devices.disabled.forEach(function (device) {
      var messageCount = helpers.getMessageCount(device.deviceId);

      page += "<li>" +
        `<h4>${device.deviceId}</h4>` +
        `<p style='font-weight:bold'>Last Message ${device.lastActivityTime}</p>` +
        `<p class='ui-li-aside'>${messageCount} messages processed</p>` +
        "</li>";
    });
  }

  page += `<li data-role='list-divider'><h3>Miscellaneous Data</h3><span class='ui-li-count'>1</span></li>`;
  page += "<li>" +
    `<h4>Aggregate Total</h4>` +
    `<p style='font-weight:bold'>Last Message ${helpers.getLastMessageTime()}</p>` +
    `<p class='ui-li-aside'>${helpers.getTotalMessageCount()} messages processed</p>` +
    "</li>";

  page += "" +
    "</ul>" +
    "<a href='https://msit.powerbi.com/view?r=eyJrIjoiYWE0N2U3ZDgtMjBmNi00NzBlLWI5YTctMDZjNmY2OTEzNDQzIiwidCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsImMiOjV9' class='ui-btn'>PowerBI Dashboard</a>" +
    "</div>" +
    "<div data-role='footer' data-position='fixed' data-theme='a'>" +
    "<h4>IoT Insider Lab</h4>" +
    "</div>" +
    "</section>" + // perhaps scripts need to be here
    "<script>" +
    "$(document).on('mobileinit', function () {" +
    "$.mobile.defaultPageTransition = 'slide';" +
    "});" +
    "</script>" +
    "</body>" +
    "</html>";

  res.send(page);
};

function renderDevicePage(res, device) {

  var page = "" +
    "<!DOCTYPE html>" +
    "<html>" +
    "<head>" +
    "<meta name='viewport' content='width=device-width,initial-scale=1'>" +
    "<script src='http://ajax.aspnetcdn.com/ajax/jQuery/jquery-2.1.4.min.js'></script>" +
    "<script src='http://ajax.aspnetcdn.com/ajax/jquery.mobile/1.4.5/jquery.mobile-1.4.5.min.js'></script>" +
    "<script src='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.1.3/Chart.min.js'></script>" +
    "<link rel='stylesheet prefetch' href='http://ajax.aspnetcdn.com/ajax/jquery.mobile/1.4.5/jquery.mobile-1.4.5.min.css'>" +
    "</head>" +
    "<body>" +
    "<section id='device-page' data-role='page'>" +
    "<div data-role='header' data-position='fixed' data-theme='a'>" +
    "<a href='/' data-ajax='false' class='ui-btn ui-icon-arrow-l ui-btn-icon-left ui-corner-all' style='background: rgba(0, 0, 0, 0.2);'>Back</a>" +
    `<h1>${device.deviceId}</h1>` +
    "</div>" +
    "<div class='ui-content'>" +
    "<canvas id='deviceChart' width='200' height='100'></canvas>" +
    "</div>" +
    "<div data-role='footer' data-position='fixed' data-theme='a'>" +
    "<h4>IoT Insider Lab</h4>" +
    "</div>" +
    "</section>" + // perhaps scripts need to be here
    "<script>" +
    "$(document).on('mobileinit', function () {" +
    "$.mobile.defaultPageTransition = 'slide';" +
    "});" +
    "$(function() {" +
    "var ctx = document.getElementById('deviceChart');" +
    "var deviceChart = Chart.Line(ctx, {" +
    "data: {" +
    "labels: [" +
    "'', '', '', '', '', '', '', '', '', ''," +
    "'', '', '', '', '', '', '', '', '', ''," +
    "'', '', '', '', '', '', '', '', '', ''," +
    "'', '', '', '', '', '', '', '', '', ''," +
    "'', '', '', '', '', '', '', '', '', ''," +
    "'', '', '', '', '', '', '', '', '', ''," +
    "]," +
    "datasets: [" +
    "{" +
    "label: 'Temperature'," +
    "fill: false," +
    "lineTension: 0.1," +
    "backgroundColor: 'rgba(75,192,192,0.4)'," +
    "borderColor: 'rgba(75,192,192,1)'," +
    "data: []," +
    "}," +
    "{" +
    "label: 'Average Temperature'," +
    "fill: true," +
    "lineTension: 0.1," +
    "backgroundColor: 'rgba(192,75,75,0.4)'," +
    "borderColor: 'rgba(192,75,75,1)'," +
    "data: []," +
    "}" +
    "]" +
    "}" +
    "});" +
    "function UpdateChart() {" +
    "$.getJSON('" + helpers.getDeviceUri(device.deviceId, "json") + "', function (device) {" +
    "deviceChart.config.data.datasets[0].data = device.analytics.temperature;" +
    "deviceChart.config.data.datasets[1].data = device.analytics.average;" +
    "deviceChart.update();" +
    "});" +
    "};" +
    "UpdateChart();" +
    "window.setInterval(function () {" +
    "UpdateChart();" +
    "}, 5000);" +
    "});" +
    "</script>" +
    "</body>" +
    "</html>";

  res.send(page);
};

module.exports.renderMainPage = renderMainPage;
module.exports.renderDevicePage = renderDevicePage;
