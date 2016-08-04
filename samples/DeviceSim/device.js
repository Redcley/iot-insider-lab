'use strict';

require("dotenv").config();
const Protocol = require("azure-iot-device-http").Http;
const Client = require("azure-iot-device").Client;
const Message = require("azure-iot-common").Message;
const uuid = require("uuid");
const log = require("./logging.js");

// Create IoT Hub client
var client = Client.fromConnectionString(process.env.IOT_DEVICE_CONNECTIONSTRING, Protocol);

var minCadence = 24*60*60;
var messageCadence = 5*60;
var messageCurrent = 0;

var messageQueue = [];

var cache = [
  0, // temperatureBoard
  0, // temperatureAmbient
  0, // temperatureBattery
  0, // currentSolarOut
  0, // currentBatteryIn
  0, // currentBatteryOut
  0, // voltageBattery
  0, // voltageACOut
  0, // energyRealACOut
  0, // energyReactiveACOut
  0, // powerRealACOut
  0, // powerReactiveACOut
  0, // powerApparentACOut
  0, // powerFactorACOut
  0, // frequencyACOut
  0 // currentACOut
];

var TEMP1 =    0x1;
var TEMP2 =    0x2;
var TEMP3 =    0x4;
var CURRENT =  0x8;
var POWER =   0x10;

var tags = [
  { tag: "temperatureBoard",    sensor:   TEMP1, index:  0, min: -40, max:  120, cadence:  30, current: 0 },
  { tag: "temperatureAmbient",  sensor:   TEMP2, index:  1, min: -20, max:   50, cadence: 300, current: 0 },
  { tag: "temperatureBattery",  sensor:   TEMP3, index:  2, min:   0, max:   50, cadence: 300, current: 0 },
  { tag: "currentSolarOut",     sensor: CURRENT, index:  3, min:   0, max:   30, cadence:  15, current: 0 },
  { tag: "currentBatteryIn",    sensor: CURRENT, index:  4, min:   0, max:   50, cadence:  15, current: 0 },
  { tag: "currentBatteryOut",   sensor: CURRENT, index:  5, min:   0, max:   75, cadence:  15, current: 0 },
  { tag: "voltageBattery",      sensor: CURRENT, index:  6, min:  44, max:   62, cadence:  15, current: 0 },
  { tag: "voltageACOut",        sensor:   POWER, index:  7, min: 200, max:  235, cadence:   5, current: 0 },
  { tag: "energyRealACOut",     sensor:   POWER, index:  8, min:   0, max:   -1, cadence: 900, current: 0 },
  { tag: "energyReactiveACOut", sensor:   POWER, index:  9, min:   0, max:   -1, cadence: 900, current: 0 },
  { tag: "powerRealACOut",      sensor:   POWER, index: 10, min:   0, max: 8000, cadence:   5, current: 0 },
  { tag: "powerReactiveACOut",  sensor:   POWER, index: 11, min:   0, max:  500, cadence:   5, current: 0 },
  { tag: "powerApparentACOut",  sensor:   POWER, index: 12, min:   0, max: 8000, cadence:   5, current: 0 },
  { tag: "powerFactorACOut",    sensor:   POWER, index: 13, min: 0.2, max: 0.95, cadence:   5, current: 0 },
  { tag: "frequencyACOut",      sensor:   POWER, index: 14, min:  49, max:   65, cadence:   5, current: 0 },
  { tag: "currentACOut",        sensor:   POWER, index: 15, min:   0, max:   20, cadence:   5, current: 0 },
];

// Message format
//
// {
//   "deviceId": "from envelope"
//   "messageId": "from envelope"
//   "timestamp": ""
//   "tag": ""
//      "temperatureBoard"   -40..120      30
//      "temperatureAmbient" -20..50      300
//      "temperatureBattery"   0..50      300
//      "currentSolarOut"      0..30       15
//      "currentBatteryIn"     0..50       15
//      "currentBatteryOut"    0..75       15
//      "voltageBattery"      44..62       15
//      "voltageACOut"       200..235       5
//      "energyRealACOut"    Increasing   900
//      "energyRectiveACOut" Increasing   900
//      "powerRealACOut"       0..8000      5
//      "powerReactiveACOut"   0..500       5
//      "powerApparentACOut"   0..8000      5
//      "powerFactorACOut"   0.2..0.95      5
//      "frequencyACOut"      49..65        5
//      "currentACOut"         0..20        5
//   "value": number
// }
function sendMessage(index, timestamp) {
  var msg = {
    timestamp: timestamp.valueOf(),
    tag: tags[index].tag,
    value: cache[tags[index].index]
  };

  var message = new Message(JSON.stringify(msg));
  //BUGBUG client lib does not include messageId for batched messages
  //message.messageId = uuid.v4();
  messageQueue.push(message);
};

function flushMessageQueue() {
  var q = messageQueue;
  messageQueue = [];

  client.sendEventBatch(messageQueue, function (err, result) {
    if (err) {
      log.err("send error:", err);
    } else {
      log.out("sent message:", q);
    }
  });
}

function initSimulation() {
  var i;

  for (i=0;i<tags.length;i+=1) {
    cache[tags[i].index] = (tags[i].max > 0) ? (tags[i].min + tags[i].max) / 2 : 0;
    log.out("Init cache[" + tags[i].index + "] = " + cache[tags[i].index]);

    minCadence = Math.min(minCadence, tags[i].cadence);
  }
  log.out("Init minCadence = " + minCadence);
};

function GenerateRandomValue(index) {
  var previous = cache[tags[index].index];
  var min = tags[index].min;
  var max = tags[index].max;
  var step = (max - min) / 100;

  previous += (Math.random() * step) - (step / 2);
  if (previous < min) {
    previous = min + (Math.random() * (step / 2));
  } else if (previous > max) {
    previous = max - (Math.random() * (step / 2));
  }
  return previous;
}

function GetBoardTemperature() {
  cache[0] = GenerateRandomValue(0);
}

function GetAmbientTemperature() {
  cache[1] = GenerateRandomValue(1);
}

function GetBatteryTemperature() {
  cache[2] = GenerateRandomValue(2);
}

function GetCurrentReadings() {
  cache[3] = GenerateRandomValue(3);
  cache[4] = GenerateRandomValue(4);
  cache[5] = GenerateRandomValue(5);
  cache[6] = GenerateRandomValue(6);
}

function GetPowerReadings() {
  cache[7] = GenerateRandomValue(7);
  cache[8] += cache[7] * (tags[8].cadence / tags[7].cadence) * Math.random();
  cache[9] += cache[7] * (tags[9].cadence / tags[7].cadence) * Math.random();
  cache[10] = GenerateRandomValue(10);
  cache[11] = GenerateRandomValue(11);
  cache[12] = GenerateRandomValue(12);
  cache[13] = GenerateRandomValue(13);
  cache[14] = GenerateRandomValue(14);
  cache[15] = GenerateRandomValue(15);
}

function loop() {
  var i, timestamp = null, sensor = 0;

  for (i=0;i<tags.length;i+=1) {
    tags[i].current += minCadence;
    if (tags[i].current >= tags[i].cadence) {
      sensor |= tags[i].sensor;
    }
  }

  timestamp = new Date();

  if (sensor & TEMP1) {
    GetBoardTemperature();
  }
  if (sensor & TEMP2) {
    GetAmbientTemperature();
  }
  if (sensor & TEMP3) {
    GetBatteryTemperature();
  }
  if (sensor & CURRENT) {
    GetCurrentReadings();
  }
  if (sensor & POWER) {
    GetPowerReadings();
  }

  for (i=0;i<tags.length;i+=1) {
    if (tags[i].current >= tags[i].cadence) {
      sendMessage(i, timestamp);
      tags[i].current = 0;
    }
  }

  messageCurrent += minCadence;
  if (messageCurrent >= messageCadence || messageQueue.length > 450) {
    messageCurrent = 0;
    flushMessageQueue();
  }
};

initSimulation();

client.open(function (err, result) {
  if (err) {
    log.err("open error:", err);
  } else {

  var sendInterval = setInterval(loop, minCadence * 1000);

  client.on("message", function (message) {
    var msg = {
      messageId: message.messageId
    };
    Object.assign(msg, JSON.parse(message.getData()));

      try {
        if (!!msg && !!msg.messageId) {
          log.out("received command:", msg);
        } else {
          throw new Error("json does not contain messageId");
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
