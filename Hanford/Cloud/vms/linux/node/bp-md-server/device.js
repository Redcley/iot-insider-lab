'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

const express = require("express");
const iothub = require("./iothub.js")();
const html = require("./html.js");
const jqm = require("./jqm.js");
const log = require("./logging.js");
const helpers = require("./helpers.js");

var pending = {};

var router = express.Router();

// During initial testing we were seeing the response come from the
// device before the callback in iothub.sendToDevice would get called
// so this kind of machanism was needed so that the response message,
// the acknowledge event and the iothub.sendToDevice callback could
// happen in any order and the session would wait for all of them
// before completing the session
function resolvePending(msgId, ack, msg, res) {
  if (!pending[msgId]) {
    pending[msgId] = {};
    pending[msgId].ts = Date.now();
  }
  if (ack) pending[msgId].ack = ack;
  if (msg) pending[msgId].msg = msg;
  if (res) pending[msgId].res = res;

  if (!!pending[msgId].ack && !!pending[msgId].msg && !!pending[msgId].res) {
    pending[msgId].res(pending[msgId].ack, pending[msgId].msg);
    delete pending[msgId];
  }

  // Prune pending completions longer then 5 minutes.
  // Since the request timeout is 2 minutes, these are
  // sure to be dead.
  setImmediate(function () {
    var ts = Date.now() - (5 * 60 * 1000);
    Object.keys(pending).forEach(function (id) {
      if (pending[id].ts < ts) {
        delete pending[id];
      }
    })
  })
};

function makeDeviceLink(id, cmd, confirm, title) {
  title = title || ((!!cmd) ? cmd.charAt(0).toUpperCase() + cmd.slice(1) : id);
  return html.makeLink(helpers.getDeviceUri(id, cmd, confirm), title);
}

function renderDialog(id, cmd) {
  return html.makeTable(
    html.makeRow(html.makeCol(`Are you sure you want to ${cmd} ${id}?`, 2)) +
    html.makeRow(
      html.makeCol(makeDeviceLink(id, cmd, true, "Confirm")) +
      html.makeCol(html.makeLink(helpers.getDeviceUri(id), "Cancel"))));
}

function renderDeviceJson(req, res) {
  var id = req.query.id;

  iothub.getDevice(id, function (err, device) {
    if (err) {
      log.err("getDevice failed\n", err);
      return res.redirect("/");
    }

    device = Object.assign({}, device, { "analytics": helpers.getAnalytics(id)});

    res.json(device);
  });
};

// Renders the main management view of the device when
// the user clisks on a device link from the root page
function renderDevicePage(req, res) {
  var id = req.query.id;
  var isAdmin = helpers.isAdmin(req);

  iothub.getDevice(id, function (err, device) {
    if (err) {
      log.err("getDevice failed\n", err);
      return res.redirect("/");
    }

    device = Object.assign({}, device);

    if (isAdmin) {
      device.connectionString = iothub.getDeviceConnectionString(device);

      var content = html.makeLink("/", "Back") +
        "<br><br>" +
        html.renderValue(device) +
        "<br><br>";

      if (device.status === "enabled") {
        content += makeDeviceLink(id, "disable") + ", ";
      } else {
        content += makeDeviceLink(id, "enable") + ", ";
      }
      content += makeDeviceLink(id, "delete");
      if (device.connectionState === "Connected") {
        content += ", " + makeDeviceLink(id, "connect");
      }

      res.send(html.applyLayout(content));
    } else {
      delete device.authentication;
      jqm.renderDevicePage(res, device);
    }
  });
};

// When a user clicks to enable a device,
// confirm they really meant it then do it.
function renderEnablePage(req, res) {
  var id = req.query.id;

  if (req.query.confirm) {
    iothub.enableDevice(id, true, function (err) {
      if (err) {
        log.err("enableDevice failed\n", err);
      }
      res.redirect(helpers.getDeviceUri(id));
    });
  } else {
    res.send(html.applyLayout(renderDialog(id, "enable")));
  }
};

// When a user clicks to disable a device,
// confirm they really meant it then do it.
function renderDisablePage(req, res) {
  var id = req.query.id;

  if (req.query.confirm) {
    iothub.enableDevice(id, false, function (err) {
      if (err) {
        log.err("enableDevice failed\n", err);
      }
      res.redirect(helpers.getDeviceUri(id));
    });
  } else {
    res.send(html.applyLayout(renderDialog(id, "disable")));
  }
};

// When a user clicks to delete a device,
// confirm they really meant it then do it.
function renderDeletePage(req, res) {
  var id = req.query.id;

  if (req.query.confirm) {
    iothub.deleteDevice(id, function (err) {
      if (err) {
        log.err("deleteDevice failed\n", err);
      }
      res.redirect("/");
    });
  } else {
    res.send(html.applyLayout(renderDialog(id, "delete")));
  }
};

// When a user clicks to connect to a device,
// send a status request and display the results.
function renderConnectPage(req, res) {
  var id = req.query.id;
  var msg = {
    request: "status"
  };

  iothub.sendToDevice(id, msg, function (err, msgId) {
    if (err) {
      log.err("sendToDevice failed\n", err);
      res.redirect(helpers.getDeviceUri(id));
    } else {
      resolvePending(msgId, null, null, function (ack, msg) {
        var content = html.makeLink(helpers.getDeviceUri(id), "Back") +
        "<br><br>" +
        html.renderValue(msg) +
        "<br><br>";

        var form = "";
        var inputs = "";
        var hasLights = msg.lights || msg.lights.length;
        if (hasLights || msg.sound) {
          if (hasLights) {
            form = html.makeRow(html.makeCol("Change Display Output"))
            msg.lights.forEach(function(val, i) {
              inputs += html.makeChoice(`light${i}`, `Light #${i}:`, [
                "off",
                "red",
                "orange",
                "yellow",
                "green",
                "blue",
                "purple"
              ]) + "<br>";
            });
            form += html.makeRow(html.makeCol(inputs));
          }
          if (msg.sound) {
            form += html.makeRow(html.makeCol(html.makeChoice("sound", "Sound:", [
              "off",
              "alarm",
              "panic",
              "smoke",
              "r2-d2"
            ]) + "<br>"));
          }
          form += html.makeRow(html.makeCol(html.makeSubmitButton("Set Output")));
          content += html.makeForm(helpers.getDeviceUri(id, "output"), html.makeTable(form)) + "<br><br>";
        }

        form = html.makeRow(html.makeCol("Configure Device")) +
          html.makeRow(html.makeCol(html.makeTextInput("updateSecs", "Environment Updata Frequency:"))) +
          html.makeRow(html.makeCol(html.makeSubmitButton("Configure")));
        content += html.makeForm(helpers.getDeviceUri(id, "configure"), html.makeTable(form));

        res.send(html.applyLayout(content));
      });
    }
  });
};

// When a user clicks configure, send a configure request,
// wait for completion and return to connect page.
function renderConfigurePage(req, res) {
  var id = req.query.id,
    updateSecs = Number(req.body.updateSecs),
    msg = {
      request: "configure",
      environmentUpdateFrequency: 5
    };

  if (!isNaN(updateSecs) && updateSecs > 0) {
    msg.environmentUpdateFrequency = updateSecs;
    iothub.sendToDevice(id, msg, function (err, msgId) {
      if (err) {
        log.err("sendToDevice failed\n", err);
        res.redirect(helpers.getDeviceUri(id));
      } else {
        resolvePending(msgId, null, {}, function (ack, msg) {
          res.redirect(helpers.getDeviceUri(id, "connect"));
        });
      }
    });
  } else {
    res.send(html.applyLayout("You must specify a positive number."))
  }
};

// When a user clicks output, send an output request,
// wait for completion and return to connect page.
function renderOutputPage(req, res) {
  var id = req.query.id,
    msg = {
      request: "output",
      lights: [],
      sound: {
        play: true,
        name: req.body.sound || "off"
      }
    },
    color = "",
    index = 0;

  while (req.body["light" + index]) {
    color = req.body["light" + index];
    msg.lights.push({});
    if (color === "off") {
      msg.lights[index].power = false;
    } else {
      msg.lights[index].power = true;
      msg.lights[index].color = color;
      msg.lights[index].duration = 10;
    }
    index = msg.lights.length;
  }

  if (msg.sound.name === "off") {
    msg.sound.play = false;
    delete msg.sound.name;
  }

  iothub.sendToDevice(id, msg, function (err, msgId) {
    if (err) {
      log.err("sendToDevice failed\n", err);
      res.redirect(helpers.getDeviceUri(id));
    } else {
      resolvePending(msgId, null, {}, function (ack, msg) {
        res.redirect(helpers.getDeviceUri(id, "connect"));
      });
    }
  });
};

// When the user comes to a /device page,
// determine which on to render.
router.use("/", function(req, res) {
  var isAdmin = helpers.isAdmin(req);

  if (isAdmin) {
    switch(req.query.cmd) {
    case "disable":
      renderDisablePage(req, res);
      break;
    case "enable":
      renderEnablePage(req, res);
      break;
    case "delete":
      renderDeletePage(req, res);
      break;
    case "connect":
      renderConnectPage(req, res);
      break;
    case "configure":
      renderConfigurePage(req, res);
      break;
    case "output":
      renderOutputPage(req, res);
      break;
    case "json":
      renderDeviceJson(req, res);
      break;
    default:
      renderDevicePage(req, res);
      break;
    }
  } else {
    if (req.query.cmd === "json") {
      renderDeviceJson(req, res);
    } else {
      renderDevicePage(req, res);
    }
  }
});

// Listen to the other two events that indicate successful completion of
// a cloud to device message. See resolvePending above for more information.
iothub.on("message", function (message) {
  if (message.responseId) {
    resolvePending(message.responseId, null, message, null);
  }
});

iothub.on("acknowledge", function (message) {
  resolvePending(message.messageId, message.ack, null, null);
})

module.exports = router;