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
const iothub = require("./iothub.js");
const html = require("./html.js");
const device = require("./device.js");
const log = require("./logging.js");

var db = null;

var stats = {
  messageCount: {},
  sendErrorCount: 0,
  receiveErrorCount: 0,
  sqlErrorCount: 0,
  ackCount: 0,
  restarts: 0
};

function SaveAndExit() {
  log.out("\nNode is being terminated, saving stats\n", stats);
  fs.writeFileSync(path.resolve(".", "logs/stats.json"), JSON.stringify(stats), "utf8");
  process.exit();
};

// kill and forever both send SIGTERM signals to the process.
process.on("SIGTERM", SaveAndExit);

// A Ctrl-C in the terminal when running locally should also be handled.
process.on("SIGINT", SaveAndExit);

// Restore stats before we hookup more events to process
fs.readFile(path.resolve(".", "logs/stats.json"), "utf8", function(err, data) {
  if (err) {
    log.err("Failed to load stats\n", err);
  } else {
    stats = JSON.parse(data);
    log.out("Restored stats from logs/stats.json");
    stats.restarts += 1;
  }
})

const app = express();

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
}

// The root page of the web server displays
// - a list of devices registered with IoTHub
// - a button to register new devices
// - a list log files
app.get("/", function(req, res) {
  iothub.listDevices(function (err, deviceList) {
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

    res.send(html.applyLayout(
      html.renderTable(table) + "<br><br>" +
      html.makeForm("/create-device",
        html.makeTextInput("name", "Device Name:") +
        html.makeSubmitButton("Create Device")) + "<br><br>" +
      html.renderValue(stats) + "<br><br>" +
      html.renderTable([["Logs"], [EnumLogs()]])
    ));
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

// This is the backend processing part of the code that
// processes messages from the IoTHub and gets them into
// the Azure SQL database.
iothub.on("message", function (msg) {
  stats.messageCount[msg.deviceId] = stats.messageCount[msg.deviceId] || 0;
  stats.messageCount[msg.deviceId] += 1;

  // format a zulu time string for MSSQL
  var timestamp = JSON.stringify(msg.datestamp).slice(1,-1);

  if (msg.response) {
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
          stats.sqlErrorCount += 1;
          log.err("execute failed\n", err, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        } else {
          if (returnValue) {
            stats.sqlErrorCount += 1;
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
          stats.sqlErrorCount += 1;
          log.err("execute failed\n", err, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        } else {
          if (returnValue) {
            stats.sqlErrorCount += 1;
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
          stats.sqlErrorCount += 1;
          log.err("execute failed\n", err, "\nfor message\n", msg, "\nwith timestamp", timestamp);
        } else {
          if (returnValue) {
            stats.sqlErrorCount += 1;
            log.err("execute failed\n", returnValue, "\nfor message\n", msg, "\nwith timestamp", timestamp);
          }
        }
      });
      break;
    default:
      log.err("Unrecognized message\n", msg);
      break;
    }
  }
});

iothub.on("sendError", function (err) {
  stats.sendErrorCount += 1;
  log.err("sendError\n", err);
});

iothub.on("receiveError", function (err) {
  stats.receiveErrorCount += 1;
  log.err("receiveError\n", err);
});

iothub.on("acknowledge", function (err) {
  stats.ackCount += 1;
  if (err) {
    log.err("acknowledge\n", err);
  }
});

//
// Before we start the server lets create our Azure SQL connection
//
function CreateConnection() {
  var con = mssql.connect(process.env.SQL_CONNECTIONSTRING, function(err) {
      if (err) {
        log.err("connect\n", err);
        db = CreateConnection();
      }
  });

  con.on("error", function (err) {
    stats.sqlErrorCount += 1;
    log.err("error\n", err);
    db.close();
    db = CreateConnection();
  })

  return con;
}

db = CreateConnection();

const server = app.listen(4000, function() {
  log.out("\nExpress is listening to http://localhost:4000");
});
