'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

const fs = require("fs");
const path = require("path");
const querystring = require("querystring");
const log = require("./logging.js");

var stats;

function ensureStats() {
  var data;

  if (global.stats_instance === undefined) {
    try {
      data = fs.readFileSync(path.resolve(".", "logs/stats.json"), "utf8");
      if (data) {
        stats = JSON.parse(data);
        log.out("Restored stats from logs/stats.json");
        stats.restarts += 1;
      } else {
        log.err("Failed to load stats\n", err);
      }
    }
    catch (e) {
      log.err("Failed to load stats\n", e);
      stats = {
        messageCount: { "total": 0 },
        sendErrorCount: 0,
        receiveErrorCount: 0,
        sqlErrorCount: 0,
        ackCount: 0,
        restarts: 0,
        analytics: {
        }
      };
    }
    global.stats_instance = stats;
  }
  stats = global.stats_instance;
};

function ensureDevice(deviceId) {
  stats.messageCount[deviceId] = stats.messageCount[deviceId] || 0;
  stats.analytics[deviceId] = stats.analytics[deviceId] || {};
  stats.analytics[deviceId].temperature = stats.analytics[deviceId].temperature || [];
  stats.analytics[deviceId].average = stats.analytics[deviceId].average || [];
};

function isAdmin(req) {
  if (req.hostname === "hanford.iotinsiderlab.com") {
    return true;
  }
  return false;
};

function saveAndExit() {
  ensureStats();

  log.out("\nNode is being terminated, saving stats\n", stats);
  fs.writeFileSync(path.resolve(".", "logs/stats.json"), JSON.stringify(stats), "utf8");
  process.exit();
};

function updateStats(msg) {
  var t = 0, c = 0;

  ensureStats();
  ensureDevice(msg.deviceId);
  var timestamp = JSON.stringify(msg.datestamp).slice(1,-1);
  stats.lastMessageTime = timestamp;
  stats.messageCount[msg.deviceId] += 1;

  Object.keys(stats.messageCount).forEach(function(key) {
    if (key !== "total") {
      t += stats.messageCount[key];
    }
  });
  stats.messageCount["total"] = t;

  if (msg.response === "environment") {
    stats.analytics[msg.deviceId].temperature.push(msg.temperature);

    t = 0; c= 0;
    stats.analytics[msg.deviceId].temperature.forEach(function (val) {
      t += val;
      c += 1;
    });

    stats.analytics[msg.deviceId].average.push(t / c);

    if (stats.analytics[msg.deviceId].temperature.length > 60) {
      stats.analytics[msg.deviceId].temperature.splice(0, 1);
      stats.analytics[msg.deviceId].average.splice(0, 1);
    }
  }
};

function getStats() {
  ensureStats();
  return stats;
};

function getMessageCount(deviceId) {
  ensureStats();
  ensureDevice(deviceId);

  return stats.messageCount[deviceId];
};

function getLastAverage(deviceId) {
  ensureStats();
  ensureDevice(deviceId);

  var averages = stats.analytics[deviceId].average;
  if (averages.length) {
    return averages[averages.length-1];
  }
  return null;
};

function getAnalytics(deviceId) {
  ensureStats();
  ensureDevice(deviceId);

  return stats.analytics[deviceId];
};

function getLastMessageTime() {
  ensureStats();
  return stats.lastMessageTime;
};

function getTotalMessageCount() {
  ensureStats();
  return stats.messageCount["total"];
}

function incSQLErrorCount() {
  ensureStats();
  stats.sqlErrorCount += 1;
};

function incSendErrorCount() {
  ensureStats();
  stats.sendErrorCount += 1;
};

function incReceiveErrorCount() {
  ensureStats();
  stats.receiveErrorCount += 1;
};

function incACKCount() {
  ensureStats();
  stats.ackCount += 1;
};

function getDeviceUri(id, cmd, confirm) {
  var qp = { id: id };
  if (cmd) qp.cmd = cmd;
  if (confirm) qp.confirm = confirm;

  return "/device?" + querystring.stringify(qp);
};

module.exports.isAdmin = isAdmin;
module.exports.saveAndExit = saveAndExit;
module.exports.updateStats =  updateStats;
module.exports.getStats = getStats;
module.exports.getMessageCount = getMessageCount;
module.exports.getLastAverage = getLastAverage;
module.exports.getAnalytics = getAnalytics;
module.exports.getLastMessageTime = getLastMessageTime;
module.exports.getTotalMessageCount = getTotalMessageCount;
module.exports.incSQLErrorCount = incSQLErrorCount;
module.exports.incSendErrorCount = incSendErrorCount;
module.exports.incReceiveErrorCount = incReceiveErrorCount;
module.exports.incACKCount = incACKCount;
module.exports.getDeviceUri = getDeviceUri;
