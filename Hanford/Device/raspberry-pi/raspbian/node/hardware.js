'use strict';
// Change this one flag to toggle between real and fake device
const FAKE = true;
const i2c = FAKE ? null : require("i2c-bus");
const util = require('util');
const EventEmitter = require('events');

// Temporary State data
var lights = [];
var sound = "";
var dials = [];
var switches = [];

// Real State data
var MPL3115A2_temperature = 0;
var MPL3115A2_pressure = 0;
var HTU21D_temperature = 0;
var HTU21D_humidity = 0;

if (FAKE) {
  MPL3115A2_temperature = 50.0;
  MPL3115A2_pressure = 101000.0;
  HTU21D_temperature = 22.22;
  HTU21D_humidity = 50.0;
}

//Helpers
const ADDR1 = 0x60;
const CMD_WHO_AM_I = 0x0C;
const CTRL_REG1 = 0x26;
const PT_DATA_CFG = 0x13;

function readMPL3115A2() {
  var bus = i2c.openSync(1);

  var who_am_i = bus.readByteSync(ADDR1, CMD_WHO_AM_I);
  if (who_am_i === 0xc4) {
    // 128 oversampling
    bus.writeByteSync(ADDR1, CTRL_REG1, 0x38);

    // Enable Data Flags in PT_DATA_CFG
    bus.writeByteSync(ADDR1, PT_DATA_CFG, 0x07);

    // toggle one shot
    var cfg = bus.readByteSync(ADDR1, CTRL_REG1);
    bus.writeByteSync(ADDR1, CTRL_REG1, cfg | 0x02);

    // Read Status Register
    while ((bus.readByteSync(ADDR1, 0x00) & 0x08) == 0);

    var buf = new Buffer(5);
    bus.readI2cBlockSync(ADDR1, 0x01, 5, buf);
    var p_msb = buf[0]; //bus.readByteSync(ADDR, 0x01);
    var p_csb = buf[1]; //bus.readByteSync(ADDR, 0x02);
    var p_lsb = buf[2]; //bus.readByteSync(ADDR, 0x03);
    var t_msb = buf[3]; //bus.readByteSync(ADDR, 0x04);
    var t_lsb = buf[4]; //bus.readByteSync(ADDR, 0x05);

    MPL3115A2_pressure = ((p_msb << 16) | (p_csb << 8) | (p_lsb & 0xF0))/64;
    MPL3115A2_temperature = ((t_msb << 8) | (t_lsb & 0xF0))/256;
  }
  bus.closeSync();
};

const ADDR2 = 0x40;
const TRIGGER_TEMP = 0xF3;
const TRIGGER_HUM = 0xF5;

function readHTU21D() {
  var bus = i2c.openSync(1);

  bus.sendByteSync(ADDR2, TRIGGER_TEMP);

  var end = Date.now() + 55;
  while(Date.now() <= end);

  var buf = new Buffer(3);
  bus.i2cReadSync(ADDR2, 3, buf);

  var t_msb = buf[0];
  var t_lsb = buf[1];
  var chksum = buf[2];

  bus.sendByteSync(ADDR2, TRIGGER_HUM);

  end = Date.now() + 55;
  while(Date.now() <= end);

  bus.i2cReadSync(ADDR2, 3, buf);

  var h_msb = buf[0];
  var h_lsb = buf[1];
  chksum = buf[2];

  HTU21D_temperature = ((((t_msb << 8) | (t_lsb & 0xFC))/65536)*175.72)-46.85;
  HTU21D_humidity = ((((h_msb << 8) | (h_lsb & 0xFC))/65536)*125)-6;

  bus.closeSync();
};

function Hardware() {};
util.inherits(Hardware, EventEmitter);

Hardware.prototype.getEnvironment = function() {
  if (FAKE) {
    HTU21D_humidity += ((Math.random() * 2) - 1);
    MPL3115A2_pressure += ((Math.random() * 2) - 1);
    HTU21D_temperature += ((Math.random() * 2) - 1);
    MPL3115A2_temperature += ((Math.random() * 2) - 1);
  } else {
    readMPL3115A2();
    readHTU21D();
  }

  return {
    "humidity": HTU21D_humidity,
    "pressure": MPL3115A2_pressure,
    "temperature": HTU21D_temperature || MPL3115A2_temperature
  };
};

Hardware.prototype.getDials = function() {
  var result = []
  dials.forEach(function (v) {
    result.push(v);
  });
  return result;
};

Hardware.prototype.getSwitches = function() {
  var result = []
  switches.forEach(function (v) {
    result.push(v);
  });
  return result;
};

Hardware.prototype.getLights = function() {
  var result = []
  lights.forEach(function (v) {
    if (v === "off") {
      result.push({ power: false });
    } else {
      result.push({ power: true, color: v });
    }
  });
  return result;
};

Hardware.prototype.toggleLight = function (index, power, color) {
  if (index >= 0 && index < lights.length) {
      if (power) {
        lights[index] = color;
        log.out("Barron put code here to turn on light #" + index + " and make it " + color);
      } else {
        lights[index] = "off";
        log.out("Barron put code here to turn off light #" + index);
      }
  }
};

Hardware.prototype.getSound = function() {
  if (sound) {
    if (sound === "off") {
      return { play: false };
    } else {
      return { play:true, name: sound };
    }
  } else {
    return null;
  }
};

Hardware.prototype.toggleSound = function (play, name, loop) {
  if (play) {
    sound = name;
    if (loop) {
      log.out("Barron put code here to play sound " + name + " continuously");
    } else {
      log.out("Barron put code here to play sound " + name + " once");
    }
  } else {
    sound = "off";
    log.out("Barron put code here to stop playing any sound");
  }
};

module.exports = new Hardware();

// change to true to generate fake input
// and enable fake output
if (FAKE) {
  // Temporary State data
  lights = [
    "off",
    "off",
    "off"
  ];

  sound = "off";

  dials = [
    50,
    50,
    50
  ];

  switches = [
    false,
    false,
    false
  ];

  setInterval(function() {
   if (Math.random() > 0.5) {
     dials.forEach(function (v,i) {
       dials[i] = Math.random();
     });
     module.exports.emit("dials", dials);
   } else {
     switches.forEach(function (v,i) {
       switches[i] = (Math.random() > 0.5);
     });
     module.exports.emit("switches", switches);
   }
  }, 60 * 1000);
}
