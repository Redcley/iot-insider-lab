'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

const util = require("util");
const EventEmitter = require("events");
const iothub = require('azure-iothub');
const eventhub = require("azure-event-hubs");
const iotCommon = require("azure-iot-common");
const uuid = require("uuid");
const log = require("./logging.js");

const connectionString = process.env.IOT_HUB_CONNECTIONSTRING;

//
// On the server side of an IoTHub, you need to interact with it
// using two different interfaces. azure-iothub handles
// - device registration
// - device enumeration
// - cloud to device messages
// - cloud to device message acknowledgment events
// Meanwhile, azure-event-hubs handles
// - device to cloud messages
//
// This helper class merges the two interfaces and attempts to
// provide a consistent single interface
//

// privates members
var iotRegistry = null;
var iotClient = null;
var ehClient = null;
var failure = null;

//constructor
function IoTHub() {
  var self = this;
  var receiveAfterTime = Date.now() - 5000;

  iotRegistry = iothub.Registry.fromConnectionString(connectionString);
  iotClient = iothub.Client.fromConnectionString(connectionString);
  ehClient = eventhub.Client.fromConnectionString(connectionString);

  iotClient.open(function (err) {
    if (err) {
      log.err("open\n", err);
      failure = err;
      iotClient = null;
    } else {
      iotClient.getFeedbackReceiver(function (err, receiver) {
        if (err) {
          log.err("getFeedbackReceiver\n", err);
          failure = err;
          iotClient.close();
          iotClient = null;
        } else {
          receiver.on("errorReceived", function (err) {
            self.emit("sendError", err);
          });

          receiver.on("message", function (response) {
            var msg = {};

            response = JSON.parse(response.data.toString())[0];
            msg.messageId = response.originalMessageId;
            msg.ack = response.description;

            self.emit("acknowledge", msg);
          });
        }
      })
    }
  });
  ehClient.open()
  .then(function () {
    return ehClient.getPartitionIds();
  })
  .then(function (partitionIds) {
    return partitionIds.map(function (partitionId) {
      return ehClient.createReceiver(
        "$Default"
        , partitionId
        , { "startAfterTime": receiveAfterTime }
      )
      .then(function (receiver) {
        receiver.on("errorReceived", function (err) {
          self.emit("receiveError", err);
        });

        receiver.on("message", function (eventData) {
            var message = Object.assign({
              "messageId": eventData.properties["messageId"],
              "datestamp": eventData.enqueuedTimeUtc,
              "deviceId": eventData.systemProperties["iothub-connection-device-id"]
            }, eventData.body);
            self.emit("message", message);
        });
      });
    });
  })
  .catch(function (err) {
    log.err("catch\n", err);
    failure = err;
    ehClient.close();
    ehClient = null;
  });
};
util.inherits(IoTHub, EventEmitter);

// Since errors can occur inside the callbacks and promise chains
// of opening connections before any api is called, every api will
// call this function first to see if an error occured. If so
// we get ready to call the given callback with the error and
// return true so the caller can exit immediately.
function Failed(callback) {
  if (failure) {
    setImmediate(function () {
      callback(failure);
    });
    return true;
  }
  return false;
}

// public
IoTHub.prototype.listDevices = function (callback) {
  if (Failed(callback)) {
    return;
  }

  iotRegistry.list(callback);
};

IoTHub.prototype.getDevice = function (id, callback) {
  if (Failed(callback)) {
    return;
  }

  iotRegistry.get(id, callback);
};

IoTHub.prototype.createDevice = function (id, callback) {
  if (Failed(callback)) {
    return;
  }

  var device = new iothub.Device(null);

  device.deviceId = id;
  log.out("\nCreating device", id);
  iotRegistry.create(device, callback);
};

IoTHub.prototype.deleteDevice = function (id, callback) {
  if (Failed(callback)) {
    return;
  }

  iotRegistry.delete(id, callback);
};

IoTHub.prototype.enableDevice = function (id, enabled, callback) {
  if (Failed(callback)) {
    return;
  }

  iotRegistry.get(id, function (err, device) {
    if (err) {
      callback(error);
    } else {
      device.status = enabled ? "enabled" : "disabled";
      device.statusReason = "Set from management console on " + Date.now();
      iotRegistry.update(device, callback);
    }
  })
};

IoTHub.prototype.sendToDevice = function (id, msg, callback) {
  if (Failed(callback)) {
    return;
  }
  var data = (typeof msg === "object") ? JSON.stringify(msg) : msg;
  var message = new iotCommon.Message(data);
  message.messageId = uuid.v4();
  message.ack = "full";

  iotClient.send(id, message, function (err) {
    if (err) {
      callback(err);
    } else {
      callback(null, message.messageId);
    }
  });
};

IoTHub.prototype.getDeviceConnectionString = function (device) {
  var hostName = iothub.ConnectionString.parse(connectionString).HostName;
  return `HostName=${hostName};DeviceId=${device.deviceId};SharedAccessKey=${device.authentication.SymmetricKey.primaryKey}`;
};

// Since you cannot have multiple connections to the azure-iothub, we
// need to manage a single global instance and return that if it has
// already been created.
function getInstance() {
  if (global.iothub_instance === undefined) {
    global.iothub_instance = new IoTHub();
  }
  return global.iothub_instance;
}

module.exports = getInstance();
