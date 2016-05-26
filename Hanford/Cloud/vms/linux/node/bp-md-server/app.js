'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

// When running in production, forever doesn't set the working directory
// correctly so we need to adjust it before trying to load files from the
// requires below. Since we know we are run as the node user in production
// this is an easy way to detect that state.
if (process.env.USER === "node") {
  process.chdir("/var/node");
}

require("dotenv").config();
const fs = require("fs");
const path = require("path");
const express = require("express");
const bodyParser = require("body-parser");
const mssql = require("mssql");
const log = require("./logging.js");
const helpers = require("./helpers.js");
const html = require("./html.js");
const jqm = require("./jqm.js");

const iothub = require("./iothub.js")(helpers.getLastMessageTime());
const device = require("./device.js");

var db = null;

// kill and forever both send SIGTERM signals to the process.
process.on("SIGTERM", helpers.saveAndExit);

// A Ctrl-C in the terminal when running locally should also be handled.
process.on("SIGINT", helpers.saveAndExit);

const app = express();

// for linux server we want this
app.set('trust proxy', 'loopback')
// bodyParser is needed so we can get querystring parameters from req.query
app.use(bodyParser.urlencoded({extended:true}));
// It also decodes json in the body which we are not using yet but is
// useful for creating microservice apis so we will likely use it soon.
app.use(bodyParser.json());
// This tells express that any urls in the /logs path can just be statisifed
// with files in the logs directory. Note: this doesn't generate a directory
// list when the url just requests the /logs directory.
app.use("/logs", express.static('logs'));

// Enumerates all the files in the logs directory and builds html links
// to each of them, which the line above enable express to serve on demand.
function EnumLogs() {
  var result = "";
  fs.readdirSync(path.resolve(".", "logs")).forEach(function (val){
    result += html.makeLink("/logs/" + val, val) + "<br>";
  });
  return result;
};

function renderMainPage(res, deviceList) {
  var table = [];
  table.push([
    "Name",
    "Status",
    "Last Update",
    "MessageCount"
  ]);

  deviceList.forEach(function (device) {
    table.push([
      html.makeLink(`/device?id=${device.deviceId}`, device.deviceId),
      ((device.status === "enabled") ? device.connectionState : device.status),
      device.lastActivityTime,
      device.cloudToDeviceMessageCount,
    ]);
  });

  // use single quotes so we don't have to
  // escape the double quotes
  var page = '<iframe width="800" height="600" ' +
    'src="https://msit.powerbi.com/view?r=eyJrIjoiYzAwMTIwMzA' +
    'tOTk2My00MzkwLWI5NGItNjViZDFiYWZlOTA0IiwidCI6IjcyZjk4OGJ' +
    'mLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsImMiOjV9" ' +
    'frameborder="0" allowFullScreen="true"></iframe><br><br>';

  page += html.renderTable(table) + "<br><br>";
  page += html.makeForm("/create-device",
    html.makeTextInput("name", "Device Name:") +
    html.makeSubmitButton("Create Device")) + "<br><br>";
  page += html.renderValue(helpers.getStats());
  page += "<br><br>" + html.renderTable([["Logs"], [EnumLogs()]]);

  res.send(html.applyLayout(page, 5));
};

// The root page of the web server displays
// - a list of devices registered with IoTHub
// - a button to register new devices
// - a list log files
app.get("/", function(req, res) {
  var isAdmin = helpers.isAdmin(req);

  iothub.listDevices(function (err, deviceList) {
    if (err) {
      log.err("listDevices failed\n", err);
      helpers.saveAndExit();
    }

    if (!isAdmin) {
      jqm.renderMainPage(res, deviceList);
    } else {
      renderMainPage(res, deviceList);
    }
  });
});

app.post("/create-device", function(req, res) {
  iothub.createDevice(req.body.name, function (err) {
    if (err) {
      log.err("creatDevice failed\n", err);
    }
    res.redirect("/");
  });
});

app.use('/device', device);

function DemoExcitement(msg) {
  if (msg.deviceId !== "shen-lab1" && msg.deviceId !== "shen-lab2") {
    return;
  }

  var analytics = helpers.getAnalytics(msg.deviceId);
  if (analytics.temperature.length > 2) {
    var lastTemp = analytics.temperature[analytics.temperature.length - 2];
    var lastAvg = analytics.average[analytics.average.length - 2];
    var temp = analytics.temperature[analytics.temperature.length - 1];
    var avg = analytics.average[analytics.average.length - 1];

    var color = null;
    if ((lastTemp <= (lastAvg+5)) && (temp > (avg+5))) {
      color = "red";
    } else if ((lastTemp <= (lastAvg+3)) && (temp > (avg+3))) {
      color = "green";
    } else if ((lastTemp <= (lastAvg+1)) && (temp > (avg+1))) {
      color = "blue";
    } else if ((lastTemp >= (lastAvg+5)) && (temp < (avg+5))) {
      color = "green";
    } else if ((lastTemp >= (lastAvg+3)) && (temp < (avg+3))) {
      color = "blue";
    } else if ((lastTemp >= (lastAvg+1)) && (temp < (avg+1))) {
      color = "off";
    }

    if (color) {
      var id = (msg.deviceId === "shen-lab1") ? "shen-lab2" : "shen-lab1";
      var power = (color === "off") ? false : true;
      var cmd = {
        request: "output",
        lights: [
          {
            power: power,
            color: color
          }
        ],
        sound : {
          play: false
        }
      };

      if (!cmd.lights[0].power) {
        delete cmd.lights[0].color;
      }

      iothub.sendToDevice(id, cmd, function (err, msgId) {
        if (err) {
          log.err("sendToDevice failed\n", err);
        }
      });
    }
  }
};

function ResetConnection() {
  if (db) {
    db.close();
  }

  var con = mssql.connect(process.env.SQL_CONNECTIONSTRING, function(err) {
    if (err) {
      log.err("connect\n", err);
      ResetConnection();
    }
  });

  con.on("error", function (err) {
    helpers.incSQLErrorCount();
    log.err("error\n", err);
    ResetConnection();
  })

  db = con;
};

// This is the backend processing part of the code that
// processes messages from the IoTHub and gets them into
// the Azure SQL database.
iothub.on("message", function (msg) {
  // format a zulu time string for MSSQL
  var timestamp = JSON.stringify(msg.datestamp).slice(1,-1);

  helpers.updateStats(msg);

  DemoExcitement(msg);

  switch(msg.response) {
  case "environment":
    new mssql.Request(db)
    .input("messageGUID", mssql.NVarChar(50), msg.messageId)
    .input("deviceId", mssql.NVarChar(50), msg.deviceId)
    .input("timestamp", mssql.NVarChar(50), timestamp)
    .input("humidity", mssql.NVarChar(50), msg.humidity)
    .input("pressure", mssql.NVarChar(50), msg.pressure)
    .input("temperature", mssql.NVarChar(50), msg.temperature)
    .execute("dbo.PersistEnvironment", function (err, recordsets, returnValue, rowsAffected) {
      if (err) {
        helpers.incSQLErrorCount();
        log.err("execute failed\n", err, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        ResetConnection();
      } else {
        if (returnValue) {
          helpers.incSQLErrorCount();
          log.err("execute failed", returnValue, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        }
      }
    });
    break;
  case "input":
    new mssql.Request(db)
    .input("messageGUID", mssql.NVarChar(50), msg.messageId)
    .input("deviceId", mssql.NVarChar(50), msg.deviceId)
    .input("timestamp", mssql.NVarChar(50), timestamp)
    .input("dials", mssql.NVarChar(1000), JSON.stringify(msg.dials))
    .input("switches", mssql.NVarChar(1000), JSON.stringify(msg.switches))
    .execute("dbo.PersistInput", function (err, recordsets, returnValue, rowsAffected) {
      if (err) {
        helpers.incSQLErrorCount();
        log.err("execute failed\n", err, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        ResetConnection();
      } else {
        if (returnValue) {
          helpers.incSQLErrorCount();
          log.err("execute failed", returnValue, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        }
      }
    });
    break;
  case "status":
    new mssql.Request(db)
    .input("messageGUID", mssql.NVarChar(50), msg.messageId)
    .input("deviceId", mssql.NVarChar(50), msg.deviceId)
    .input("timestamp", mssql.NVarChar(50), timestamp)
    .input("humidity", mssql.NVarChar(50), msg.humidity)
    .input("pressure", mssql.NVarChar(50), msg.pressure)
    .input("temperature", mssql.NVarChar(50), msg.temperature)
    .input("dials", mssql.NVarChar(1000), JSON.stringify(msg.dials))
    .input("switches", mssql.NVarChar(1000), JSON.stringify(msg.switches))
    .input("lights", mssql.NVarChar(1000), JSON.stringify(msg.lights))
    .input("soundPlay", mssql.NVarChar(20), msg.sound.play.toString())
    .input("soundName", mssql.NVarChar(50), msg.sound.play.name)
    .input("updateFrequency", mssql.NVarChar(50), msg.environmentUpdateFrequency)
    .execute("dbo.PersistStatus", function (err, recordsets, returnValue, rowsAffected) {
      if (err) {
        helpers.incSQLErrorCount();
        log.err("execute failed\n", err, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        ResetConnection();
      } else {
        if (returnValue) {
          helpers.incSQLErrorCount();
          log.err("execute failed\n", returnValue, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        }
      }
    });
    break;
  default:
    log.err("Unrecognized or badly formatted message\n", msg);
    break;
  }
});

iothub.on("sendError", function (err) {
  helpers.incSendErrorCount();
  log.err("sendError\n", err);

  // Most likely reason is expired token. Exiting
  // will cause us to restart and acquire a new token
  helpers.saveAndExit();
});

iothub.on("receiveError", function (err) {
  helpers.incReceiveErrorCount();
  log.err("receiveError\n", err);
  helpers.saveAndExit();
});

iothub.on("acknowledge", function (msg) {
  helpers.incACKCount();
  log.out("acknowledge\n", msg);
});

//
// Before we start the server lets create our Azure SQL connection
//

ResetConnection();

const server = app.listen(4000, function() {
  log.out("\nExpress is listening to http://localhost:4000");
});
