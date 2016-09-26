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
const Protocol = require("azure-iot-device-amqp").Amqp;
const Client = require("azure-iot-device").Client;
const Message = require("azure-iot-common").Message;
const uuid = require("uuid");
const Hardware = require("./hardware.js");
const log = require("./logging.js");

var environmentUpdateInterval = 5*1000; // every 5 seconds
var sendInterval = null;

log.out("Connecting using ", process.env.IOT_DEVICE_CONNECTIONSTRING);

// Create IoT Hub client
var client = Client.fromConnectionString(process.env.IOT_DEVICE_CONNECTIONSTRING, Protocol);

//
// sendMessage
//
// helper to be consistent about how we send messages
//
function sendMessage(msg) {
  if (typeof msg !== "object") {
      log.err("programmer error: msg is not an object");
  }

  var message = new Message(JSON.stringify(msg));
  message.messageId = uuid.v4();

  client.sendEvent(message, function (err, result) {
    if (err) {
      log.err("send error:", err);
    }
  });
};

//
// sendEnvironment
//
// send the following device to hub message
//
// {
//   "response": "environment",
//   "humidity": 50,
//   "pressure": 101000,
//   "temperature": 22.22
// }
//
function sendEnvironment() {
  var msg = Object.assign(
    { "response": "environment" },
    Hardware.getEnvironment()
  );

  log.out("Sending environment response:", msg);
  sendMessage(msg);
};

//
// parseConfigure
//
// parses the following hub to device message
//
// {
//   "request": "configure",
//   "environmentUpdateFrequency": 30
// }
//
function parseConfigure(msg) {
  if (!msg || !msg.request || !msg.environmentUpdateFrequency || msg.request !== "configure") {
    throw new Error("parseConfigure error: invalid message format");
    return;
  }
  environmentUpdateInterval = msg.environmentUpdateFrequency * 1000;
  if (sendInterval) {
    clearInterval(sendInterval);
  }
  log.out("setting environmentUpdateInterval = ", environmentUpdateInterval);
  sendInterval = setInterval(sendEnvironment, environmentUpdateInterval);
};

//
// sendInput
//
// send the following device to hub message
//
// {
//   "response": "input",
//   "dials": [
//     50.00
//   ],
//   "switches": [
//     true
//   ]
// }
//
function sendInput(dials, switches) {
  dials = dials || [];
  switches = switches || [];

  var msg = {
    "response": "input",
    "dials": dials,
    "switches": switches
  };

  log.out("Sending input response:", msg);
  sendMessage(msg);
};

// listen for hardware events
Hardware.on("dials", function (dials) {
  sendInput(dials, Hardware.getSwitches());
});

Hardware.on("switches", function (switches) {
  sendInput(Hardware.getDials(), switches);
});

// helpers to turn off lights and sounds
// when a duration is specified.
function scheduleLightOff(index, duration) {
  setTimeout(function () {
    log.out("turning off light #", index);
    Hardware.toggleLight(index, false);
  }, duration * 1000);
}

function scheduleSoundOff(duration) {
  setTimeout(function () {
    log.out("turning off sound");
    Hardware.toggleSound(false);
  }, duration * 1000);
}

//
// parseOutput
//
// parses the following hub to device message
//
// {
//   "request": "output",
//   "lights": [
//     {
//       "color": "blue",
//       "power": true,
//       "duration": 30
//     }
//   ]
//   "sound": {
//     "play": true,
//     "name": "alarm",
//     "duration": 30
//   }
// }
//
function parseOutput(msg) {
  if (!msg || !msg.request || msg.request !== "output" ||
      !msg.lights || !msg.sound) {
    throw new Error("parseOutput error: invalid message format");
    return;
  }
  msg.lights.forEach(function (light, index) {
    // defautl power is off
    light.color = light.color || "default";
    // default duration is forever

    log.out("toggleLight(index =", index, "power =", light.power, "color =", light.color, ")");
    Hardware.toggleLight(index, light.power, light.color);

    if (!!light.power && !!light.duration) {
      scheduleLightOff(index, light.duration);
    }
  });

  // default play is off
  msg.sound.name = msg.sound.name || "default";
  // default duration is once

  log.out("toggleSound(play =", msg.sound.play, "name =", msg.sound.name, "loop =", !!msg.sound.duration, ")");
  Hardware.toggleSound(msg.sound.play, msg.sound.name, !!msg.sound.duration);
  if (!!msg.sound.play && !!msg.sound.duration) {
    scheduleSoundOff(msg.sound.duration);
  }
};

//
// sendStatus
//
// sends the following device to hub message
//
// {
//   "response": "status"
//   "humidity": 50,
//   "pressure": 101000,
//   "temperature": 22.22,
//   "dials": [
//     50.00
//   ],
//   "switches": [
//     true
//   ],
//   "lights": [
//     {
//       power: true,
//       color: v
//     }
//   ],
//   "sound": {
//     "play": true,
//     "name": "alarm"
//   },
//   "environmentUpdateFrequency": 30
// }
//
function sendStatus(responseId) {
  var msg = Object.assign(
    {
      "response": "status",
    },
    Hardware.getEnvironment(),
    {
      "environmentUpdateFrequency": environmentUpdateInterval / 1000
    }
  );

  var dials = Hardware.getDials();
  var switches = Hardware.getSwitches();
  var lights = Hardware.getLights();
  var sound = Hardware.getSound();

  if (dials) {
    msg["dials"] = dials;
  }

  if (switches) {
    msg["switches"] = switches;
  }

  if (lights) {
    msg["lights"] = lights;
  }

  if (sound) {
    msg["sound"] = sound;
  }

  if (responseId) {
    msg.responseId = responseId;
  }

  log.out("Sending status response:", msg);
  sendMessage(msg);
};

//
// parseStatus
//
// parses the following hub to device message
//
// {
//   "request": "status"
// }
//
function parseStatus(msg) {
  if (!msg || !msg.request || msg.request !== "status") {
    throw new Error("parseStatus: invalid message format");
    return;
  }

  sendStatus(msg.messageId);
};

client.open(function (err, result) {
  if (err) {
    log.err("open error:", err);
  } else {

    log.out("Setting reporting interval every ", environmentUpdateInterval, "ms");

    sendInterval = setInterval(sendEnvironment, environmentUpdateInterval);

    client.on("message", function (message) {
      var msg = {
        messageId: message.messageId
      };
      Object.assign(msg, JSON.parse(message.getData()));

      try {
        if (!!msg && !!msg.request) {
          switch(msg.request) {
          case "configure":
            parseConfigure(msg);
            break;
          case "output":
            parseOutput(msg);
            break;
          case "status":
            parseStatus(msg);
            break;
          default:
            throw new Error("request not recognized");
            break;
          }
        } else {
          throw new Error("json does not contain request");
        }
        client.complete(message, function (err) {
          if (err) {
            log.err("complete error:", err);
          }
        });
      }
      catch (err) {
        log.err('client message error:', err);
        client.reject(message, function (err) {
          if (err) {
            log.err("reject error:", err);
          }
        });
      }
    });

    client.on("error", function (err) {
      log.err("client error:", err);
      if (sendInterval) clearInterval(sendInterval);
      client.close();
    });
  }
});
